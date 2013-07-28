#include <stdio.h>
#include <stdbool.h>
#include <ruby.h>
#include <phidget21.h>
#include <math.h>

typedef struct phidget_data {
  CPhidgetHandle handle;
  int  serial;
  bool is_attached;
  const char *type;
  const char *name;
  const char *label;
  int version;
  int accelerometer_axes;
  int compass_axes;
  int gyro_axes;
  CPhidget_DeviceClass device_class;
  CPhidget_DeviceID device_id;

  // Sample tracking.
  double sample_rate;       // NOTE: These are in Hz
  int samples_last_second;  // This is the prior second value in our sampling loop
  int samples_in_second;    // A counter which resets when the second changes
  
  // Accelerometer
  double acceleration_min;
  double acceleration_max;
  double compass_min;
  double compass_max;
  double gyroscope_min;
  double gyroscope_max;

  double acceleration_x;
  double acceleration_y;
  double acceleration_z;
  double compass_x;
  double compass_y;
  double compass_z;
  double gyroscope_x;
  double gyroscope_y;
  double gyroscope_z;

} PhidgetInfo;

void Init_ruby_phidget_native();
VALUE spatial_new(VALUE self, VALUE serial);
VALUE spatial_initialize(VALUE self, VALUE serial);
VALUE spatial_close(VALUE self);
VALUE spatial_wait_for_attachment(VALUE self, VALUE timeout);

VALUE spatial_device_class(VALUE self);
VALUE spatial_device_id(VALUE self);
VALUE spatial_type(VALUE self);
VALUE spatial_name(VALUE self);
VALUE spatial_label(VALUE self);
VALUE spatial_serial_number(VALUE self);
VALUE spatial_version(VALUE self);
VALUE spatial_sample_rate(VALUE self);

VALUE spatial_accelerometer_axes(VALUE self);
VALUE spatial_compass_axes(VALUE self);
VALUE spatial_gyro_axes(VALUE self);

VALUE spatial_accelerometer_min(VALUE self);
VALUE spatial_accelerometer_max(VALUE self);
VALUE spatial_gyro_min(VALUE self);
VALUE spatial_gyro_max(VALUE self);
VALUE spatial_compass_min(VALUE self);
VALUE spatial_compass_max(VALUE self);

static void free_phidget_data(PhidgetInfo *info) {
  printf("Inside free_phidget_data\n");
  if (info) {
    if (info->handle) {
	    CPhidget_close((CPhidgetHandle)info->handle);
	    CPhidget_delete((CPhidgetHandle)info->handle);
    }
    ruby_xfree(info);
  }
}

//callback that will run if the Spatial is attached to the computer
int CCONV AttachHandler(CPhidgetHandle phid, void *userptr)
{
  int serialNo;
  CPhidget_getSerialNumber(phid, &serialNo);
  printf("Spatial %10d attached!", serialNo);

  // Populate our data structures with what we know about this device:
  PhidgetInfo *info = userptr;
  info->is_attached = true;

  // Phidget Attributes:
  CPhidget_getDeviceType(phid, &info->type);
  CPhidget_getDeviceVersion(phid, &info->version);
  CPhidget_getDeviceClass(phid, &info->device_class);
  CPhidget_getDeviceID(phid, &info->device_id);
  CPhidget_getDeviceLabel(phid, &info->label);
  CPhidget_getDeviceName(phid, &info->name);

  // Accelerometer Attributes:
  CPhidgetSpatial_getAccelerationAxisCount((CPhidgetSpatialHandle)phid, &info->accelerometer_axes);
  CPhidgetSpatial_getGyroAxisCount((CPhidgetSpatialHandle)phid, &info->gyro_axes);
  CPhidgetSpatial_getCompassAxisCount((CPhidgetSpatialHandle)phid, &info->compass_axes);

  // Accelerometer
  CPhidgetSpatial_getAccelerationMin((CPhidgetSpatialHandle)phid, 0, &info->acceleration_min);
  CPhidgetSpatial_getAccelerationMax((CPhidgetSpatialHandle)phid, 0, &info->acceleration_max);
  CPhidgetSpatial_getMagneticFieldMin((CPhidgetSpatialHandle)phid, 0, &info->compass_min);
  CPhidgetSpatial_getMagneticFieldMax((CPhidgetSpatialHandle)phid, 0, &info->compass_max);
  CPhidgetSpatial_getAngularRateMin((CPhidgetSpatialHandle)phid, 0, &info->gyroscope_min);
  CPhidgetSpatial_getAngularRateMax((CPhidgetSpatialHandle)phid, 0, &info->gyroscope_max);

	// Set the data rate for the spatial events in milliseconds. 
  // Note that 1000/16 = 62.5 Hz
  // TODO: set this from the info param
	CPhidgetSpatial_setDataRate((CPhidgetSpatialHandle)phid, 16);

  return 0;
}

//callback that will run if the Spatial is detached from the computer
int CCONV DetachHandler(CPhidgetHandle spatial, void *userptr)
{
  int serialNo;
  CPhidget_getSerialNumber(spatial, &serialNo);
  printf("Spatial %10d detached! \n", serialNo);

  PhidgetInfo *info = userptr;
  info->is_attached = false;
  printf("User ptr serial %10d!", info->serial);

  return 0;
}

//callback that will run if the Spatial generates an error
int CCONV ErrorHandler(CPhidgetHandle spatial, void *userptr, int ErrorCode, const char *unknown)
{
  printf("Error handled. %d - %s \n", ErrorCode, unknown);
  return 0;
}

//callback that will run at datarate
//data - array of spatial event data structures that holds the spatial data packets that were sent in this event
//count - the number of spatial data event packets included in this event
int CCONV SpatialDataHandler(CPhidgetSpatialHandle spatial, void *userptr, CPhidgetSpatial_SpatialEventDataHandle *data, int count)
{
  PhidgetInfo *info = userptr;
  info->is_attached = false;

  int i;
  for(i = 0; i < count; i++) {
    info->samples_in_second++;

    // Sample tracking
    if ( info->samples_last_second == 0 )
      info->samples_last_second = data[i]->timestamp.seconds;
    else if ( info->samples_last_second != data[i]->timestamp.seconds ) {
      info->sample_rate = (double) info->samples_in_second / 
          (double) (data[i]->timestamp.seconds - info->samples_last_second);
      info->samples_in_second = 0;
      info->samples_last_second = data[i]->timestamp.seconds;

      printf("Sample rate: %f\n", info->sample_rate);
    }

    // Set the values to where they need to be:
    info->acceleration_x = data[i]->acceleration[0];
    info->acceleration_y = data[i]->acceleration[1];
    info->acceleration_z = data[i]->acceleration[2];
    info->compass_x = data[i]->magneticField[0];
    info->compass_y = data[i]->magneticField[1];
    info->compass_z = data[i]->magneticField[2];

    // Gyros get handled slightly different:
    info->gyroscope_x += data[i]->angularRate[0];
    info->gyroscope_y += data[i]->angularRate[1];
    info->gyroscope_z += data[i]->angularRate[2];
  }

  return 0;
}

void Init_ruby_phidget_native() {
  VALUE Phidget = rb_define_module("Phidget");
  VALUE Spatial = rb_define_class_under(Phidget, "Spatial",rb_cObject);

  rb_define_singleton_method(Spatial, "new", spatial_new, 1);
  rb_define_method(Spatial, "initialize", spatial_initialize, 1);
  rb_define_method(Spatial, "close", spatial_close, 0);
  rb_define_method(Spatial, "wait_for_attachment", spatial_wait_for_attachment, 1);

  // Phidget Accessors
  rb_define_method(Spatial, "device_class", spatial_device_class, 0);
  rb_define_method(Spatial, "device_id", spatial_device_id, 0);
  rb_define_method(Spatial, "type", spatial_type, 0);
  rb_define_method(Spatial, "name", spatial_name, 0);
  rb_define_method(Spatial, "label", spatial_label, 0);
  rb_define_method(Spatial, "serial_number", spatial_serial_number, 0);
  rb_define_method(Spatial, "version", spatial_version, 0);
  rb_define_method(Spatial, "sample_rate", spatial_sample_rate, 0);
  
  // Spatial Accessors
  rb_define_method(Spatial, "accelerometer_axes", spatial_accelerometer_axes, 0);
  rb_define_method(Spatial, "compass_axes", spatial_compass_axes, 0);
  rb_define_method(Spatial, "gyro_axes", spatial_gyro_axes, 0);

  rb_define_method(Spatial, "gyro_min", spatial_gyro_min, 0);
  rb_define_method(Spatial, "gyro_max", spatial_gyro_max, 0);
  rb_define_method(Spatial, "accelerometer_min", spatial_accelerometer_min, 0);
  rb_define_method(Spatial, "accelerometer_max", spatial_accelerometer_max, 0);
  rb_define_method(Spatial, "compass_min", spatial_compass_min, 0);
  rb_define_method(Spatial, "compass_max", spatial_compass_max, 0);
}

VALUE spatial_new(VALUE class, VALUE serial) {
  // Setup a spatial handle
  CPhidgetSpatialHandle spatial = 0;
  CPhidgetSpatial_create(&spatial);

  // We'll need this all over the place later:
  PhidgetInfo *info;
  VALUE self = Data_Make_Struct(class, PhidgetInfo, 0, free_phidget_data, info);
  memset(info, 0, sizeof(PhidgetInfo));
  info->serial = FIX2INT(serial);
  info->is_attached = false;
  info->handle = (CPhidgetHandle)spatial;

  // Register the event handlers:
	CPhidget_set_OnAttach_Handler((CPhidgetHandle)spatial, AttachHandler, info);
	CPhidget_set_OnDetach_Handler((CPhidgetHandle)spatial, DetachHandler, info);
	CPhidget_set_OnError_Handler((CPhidgetHandle)spatial, ErrorHandler, info);
	CPhidgetSpatial_set_OnSpatialData_Handler(spatial, SpatialDataHandler, info);

	CPhidget_open((CPhidgetHandle)spatial, FIX2INT(serial)); 

  // Initialize our class instance
  VALUE argv[1];
  argv[0] = serial;
  rb_obj_call_init(self, 1, argv);

  return self;
}  

VALUE spatial_initialize(VALUE self, VALUE serial) {
  return self;
}

VALUE spatial_close(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  printf("Inside close \n");

  CPhidget_set_OnAttach_Handler((CPhidgetHandle)info->handle, NULL, NULL);
  CPhidget_set_OnDetach_Handler((CPhidgetHandle)info->handle, NULL, NULL);
  CPhidget_set_OnError_Handler((CPhidgetHandle)info->handle, NULL, NULL);
  CPhidgetSpatial_set_OnSpatialData_Handler((CPhidgetSpatialHandle)info->handle, NULL, NULL);

  return Qnil;
}

VALUE spatial_wait_for_attachment(VALUE self, VALUE timeout) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

	//get the program to wait for a spatial device to be attached
	printf("Waiting for spatial to be attached.... \n");

  int result;
  const char *err;

	if(result = CPhidget_waitForAttachment((CPhidgetHandle)info->handle, FIX2UINT(timeout))) {
		CPhidget_getErrorDescription(result, &err);
		printf("Problem waiting for attachment: %s\n", err);
    return Qfalse;
	}

  return Qtrue;
}

VALUE spatial_device_class(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  switch (info->device_class) {
    case PHIDCLASS_ACCELEROMETER:
        return rb_str_new2("Phidget Accelerometer");
    case PHIDCLASS_ADVANCEDSERVO:
        return rb_str_new2("Phidget Advanced Servo");
    case PHIDCLASS_ANALOG:
      return rb_str_new2("Phidget Analog");
    case PHIDCLASS_BRIDGE:
      return rb_str_new2("Phidget Bridge");
    case PHIDCLASS_ENCODER:
      return rb_str_new2("Phidget Encoder");
    case PHIDCLASS_FREQUENCYCOUNTER:
      return rb_str_new2("Phidget Frequency Counter");
    case PHIDCLASS_GPS:
      return rb_str_new2("Phidget GPS");
    case PHIDCLASS_INTERFACEKIT:
      return rb_str_new2("Phidget Interface Kit");
    case PHIDCLASS_IR:
      return rb_str_new2("Phidget IR");
    case PHIDCLASS_LED:
      return rb_str_new2("Phidget LED");
    case PHIDCLASS_MOTORCONTROL:
      return rb_str_new2("Phidget Motor Control");
    case PHIDCLASS_PHSENSOR:
      return rb_str_new2("Phidget PH Sensor");
    case PHIDCLASS_RFID:
      return rb_str_new2("Phidget RFID");
    case PHIDCLASS_SERVO:
      return rb_str_new2("Phidget Servo");
    case PHIDCLASS_SPATIAL:
      return rb_str_new2("Phidget Spatial");
    case PHIDCLASS_STEPPER:
      return rb_str_new2("Phidget Stepper");
    case PHIDCLASS_TEMPERATURESENSOR:
      return rb_str_new2("Phidget Temperature Sensor");
    case PHIDCLASS_TEXTLCD:
      return rb_str_new2("Phidget TextLCD");
    case PHIDCLASS_TEXTLED:
      return rb_str_new2("Phidget TextLED");
    case PHIDCLASS_WEIGHTSENSOR:
      return rb_str_new2("Phidget Weight Sensor");
    default:
      return rb_str_new2("Unknown Phidget");
      break;
  }

  return (info->device_class == 0) ? Qnil : Qnil;
}

VALUE spatial_device_id(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  switch (info->device_id) {
    case PHIDID_ACCELEROMETER_3AXIS:
      return rb_str_new2("Phidget 3-axis Accelerometer (1059)");
    case PHIDID_ADVANCEDSERVO_1MOTOR:
      return rb_str_new2("Phidget 1 Motor Advanced Servo (1066)");
    case PHIDID_ADVANCEDSERVO_8MOTOR:
      return rb_str_new2("Phidget 8 Motor Advanced Servo (1061)");
    case PHIDID_ANALOG_4OUTPUT:
      return rb_str_new2("Phidget Analog 4-output (1002)");
    case PHIDID_BIPOLAR_STEPPER_1MOTOR:
      return rb_str_new2("Phidget 1 Motor Bipolar Stepper Controller with 4 Digital Inputs (1063)");
    case PHIDID_BRIDGE_4INPUT:
      return rb_str_new2("Phidget Bridge 4-input (1046)");
    case PHIDID_ENCODER_1ENCODER_1INPUT:
      return rb_str_new2("Phidget Encoder - Mechanical (1052)");
    case PHIDID_ENCODER_HS_1ENCODER:
      return rb_str_new2("Phidget High Speed Encoder (1057)");
    case PHIDID_ENCODER_HS_4ENCODER_4INPUT:
      return rb_str_new2("Phidget High Speed Encoder - 4 Encoder (1047)");
    case PHIDID_FREQUENCYCOUNTER_2INPUT:
      return rb_str_new2("Phidget Frequency Counter 2-input (1054)");
    case PHIDID_GPS:
      return rb_str_new2("Phidget GPS (1040)");
    case PHIDID_INTERFACEKIT_0_0_4:
      return rb_str_new2("Phidget Interface Kit 0/0/4 (1014)");
    case PHIDID_INTERFACEKIT_0_0_8:
      return rb_str_new2("Phidget Interface Kit 0/0/8 (1017)");
    case PHIDID_INTERFACEKIT_0_16_16:
      return rb_str_new2("Phidget Interface Kit 0/16/16 (1012)");
    case PHIDID_INTERFACEKIT_2_2_2:
      return rb_str_new2("Phidget Interface Kit 2/2/2 (1011)");
    case PHIDID_INTERFACEKIT_8_8_8:
      return rb_str_new2("Phidget Interface Kit 8/8/8 (1013, 1018, 1019)");
    case PHIDID_INTERFACEKIT_8_8_8_w_LCD:
      return rb_str_new2("Phidget Interface Kit 8/8/8 with TextLCD (1201, 1202, 1203)");
    case PHIDID_IR:
      return rb_str_new2("Phidget IR Receiver Transmitter (1055)");
    case PHIDID_LED_64_ADV:
      return rb_str_new2("Phidget LED 64 Advanced (1031)");
    case PHIDID_LINEAR_TOUCH:
      return rb_str_new2("Phidget Linear Touch (1015)");
    case PHIDID_MOTORCONTROL_1MOTOR:
      return rb_str_new2("Phidget 1 Motor Motor Controller (1065)");
    case PHIDID_MOTORCONTROL_HC_2MOTOR:
      return rb_str_new2("Phidget 2 Motor High Current Motor Controller (1064)");
    case PHIDID_RFID_2OUTPUT:
      return rb_str_new2("Phidget RFID with Digital Outputs and Onboard LED (1023)");
    case PHIDID_RFID_2OUTPUT_READ_WRITE:
      return rb_str_new2("Phidget RFID with R/W support (1024)");
    case PHIDID_ROTARY_TOUCH:
      return rb_str_new2("Phidget Rotary Touch (1016)");
    case PHIDID_SPATIAL_ACCEL_3AXIS:
      return rb_str_new2("Phidget Spatial 3-axis accel (1049, 1041, 1043)");
    case PHIDID_SPATIAL_ACCEL_GYRO_COMPASS:
      return rb_str_new2("Phidget Spatial 3/3/3 (1056, 1042, 1044)");
    case PHIDID_TEMPERATURESENSOR:
      return rb_str_new2("Phidget Temperature Sensor (1051)");
    case PHIDID_TEMPERATURESENSOR_4:
      return rb_str_new2("Phidget Temperature Sensor 4-input (1048)");
    case PHIDID_TEMPERATURESENSOR_IR:
      return rb_str_new2("Phidget Temperature Sensor IR (1045)");
    case PHIDID_TEXTLCD_2x20_w_8_8_8:
      return rb_str_new2("Phidget TextLCD with Interface Kit 8/8/8 (1201, 1202, 1203)");
    case PHIDID_TEXTLCD_ADAPTER:
      return rb_str_new2("Phidget TextLCD Adapter (1204)");
    case PHIDID_UNIPOLAR_STEPPER_4MOTOR:
      return rb_str_new2("Phidget 4 Motor Unipolar Stepper Controller (1062)");
    case PHIDID_ACCELEROMETER_2AXIS:
      return rb_str_new2("Phidget 2-axis Accelerometer (1053, 1054)");
    case PHIDID_INTERFACEKIT_0_8_8_w_LCD:
      return rb_str_new2("Phidget Interface Kit 0/8/8 with TextLCD (1219, 1220, 1221)");
    case PHIDID_INTERFACEKIT_4_8_8:
      return rb_str_new2("Phidget Interface Kit 4/8/8");
    case PHIDID_LED_64:
      return rb_str_new2("Phidget LED 64 (1030)");
    case PHIDID_MOTORCONTROL_LV_2MOTOR_4INPUT:
      return rb_str_new2("Phidget 2 Motor Low Voltage Motor Controller with 4 Digital Inputs (1060)");
    case PHIDID_PHSENSOR:
      return rb_str_new2("Phidget PH Sensor (1058)");
    case PHIDID_RFID:
      return rb_str_new2("Phidget RFID without Digital Outputs");
    case PHIDID_SERVO_1MOTOR:
      return rb_str_new2("Phidget 1 Motor Servo Controller (1000)");
    case PHIDID_SERVO_1MOTOR_OLD:
      return rb_str_new2("Phidget 1 Motor Servo Controller - Old Version");
    case PHIDID_SERVO_4MOTOR:
      return rb_str_new2("Phidget 4 Motor Servo Controller (1001)");
    case PHIDID_SERVO_4MOTOR_OLD:
      return rb_str_new2("Phidget 4 Motor Servo Controller - Old Version");
    case PHIDID_TEXTLCD_2x20:
      return rb_str_new2("Phidget TextLCD without Interface Kit (1210)");
    case PHIDID_TEXTLCD_2x20_w_0_8_8:
      return rb_str_new2("Phidget TextLCD with Interface Kit 0/8/8 (1219, 1220, 1221)");
    case PHIDID_TEXTLED_1x8:
      return rb_str_new2("Phidget TextLED 1x8");
    case PHIDID_TEXTLED_4x8:
      return rb_str_new2("Phidget TextLED 4x8 (1040)");
    case PHIDID_WEIGHTSENSOR:
      return rb_str_new2("Phidget Weight Sensor (1050)");
    default:
      return rb_str_new2("Unknown Phidget");
  }
}

VALUE spatial_type(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->type == NULL) ? Qnil : rb_str_new2(info->type);
}

VALUE spatial_name(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->name == NULL) ? Qnil : rb_str_new2(info->name);
}

VALUE spatial_label(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->label == NULL) ? Qnil : rb_str_new2(info->label);
}

VALUE spatial_serial_number(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->serial == 0) ? Qnil : INT2FIX(info->serial);
}  

VALUE spatial_version(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->version == 0) ? Qnil : INT2FIX(info->version);
}  

VALUE spatial_accelerometer_axes(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->accelerometer_axes == 0) ? Qnil : INT2FIX(info->accelerometer_axes);
}  

VALUE spatial_compass_axes(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->compass_axes == 0) ? Qnil : INT2FIX(info->compass_axes);
}  

VALUE spatial_gyro_axes(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->gyro_axes == 0) ? Qnil : INT2FIX(info->gyro_axes);
}  

VALUE spatial_sample_rate(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return DBL2NUM(info->sample_rate);
}  

VALUE spatial_accelerometer_min(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->acceleration_min == 0) ? Qnil : DBL2NUM(info->acceleration_min);
}  

VALUE spatial_accelerometer_max(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->acceleration_max == 0) ? Qnil : DBL2NUM(info->acceleration_max);
}  

VALUE spatial_gyro_min(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->gyroscope_min == 0) ? Qnil : DBL2NUM(info->gyroscope_min);
}  

VALUE spatial_gyro_max(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->gyroscope_max == 0) ? Qnil : DBL2NUM(info->gyroscope_max);
}  

VALUE spatial_compass_min(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->compass_min == 0) ? Qnil : DBL2NUM(info->compass_min);
}  

VALUE spatial_compass_max(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return (info->compass_max == 0) ? Qnil : DBL2NUM(info->compass_max);
}  
