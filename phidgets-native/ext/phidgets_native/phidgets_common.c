#include "phidgets_native.h"

PhidgetInfo *get_info(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return info;
}

int CCONV phidget_on_attach(CPhidgetHandle phid, void *userptr)
{
  int serialNo;
  CPhidget_getSerialNumber(phid, &serialNo);
  printf("Phidget %10d attached!\n", serialNo);

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

  return (info->on_type_attach) ? (*info->on_type_attach)(phid, info) : 0;
}

int CCONV phidget_on_detach(CPhidgetHandle phid, void *userptr) {
  int serialNo;
  CPhidget_getSerialNumber(phid, &serialNo);
  printf("Phidget %10d detached! \n", serialNo);

  PhidgetInfo *info = userptr;
  info->is_attached = false;
  printf("User ptr serial %10d!", info->serial);

  if (info->on_type_detach)
    (*info->on_type_detach)(phid, info);

  return (info->on_type_detach) ? (*info->on_type_detach)(phid, info) : 0;
}

int CCONV phidget_on_error(CPhidgetHandle phid, void *userptr, int ErrorCode, const char *unknown) {
  printf("Error handled. %d - %s \n", ErrorCode, unknown);
  return 0;
}

void phidget_free(PhidgetInfo *info) {
  printf("Inside phidget_free\n");
  if (info) {
    if (info->handle) {
	    CPhidget_close((CPhidgetHandle)info->handle);
	    CPhidget_delete((CPhidgetHandle)info->handle);
    }

    if (info->on_type_free)
      (*info->on_type_free)(info->type_info);

    ruby_xfree(info);
  }
}


VALUE phidget_new(int argc, VALUE* argv, VALUE class) {
  printf("Inside phidget_new\n");

  // We'll need this all over the place later:
  PhidgetInfo *info;
  VALUE self = Data_Make_Struct(class, PhidgetInfo, 0, phidget_free, info);
  memset(info, 0, sizeof(PhidgetInfo));
  info->is_attached = false;

  // Call the object's constructor:
  rb_obj_call_init(self, argc, argv);

  return self;
}  

VALUE phidget_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);

  printf("Inside phidget_init\n");
 
  info->serial = FIX2INT(serial);

  // TODO Initialize info->handle if it's not already initialized 

  // Register the event handlers:
	CPhidget_set_OnAttach_Handler((CPhidgetHandle)info->handle, phidget_on_attach, info);
	CPhidget_set_OnDetach_Handler((CPhidgetHandle)info->handle, phidget_on_detach, info);
	CPhidget_set_OnError_Handler((CPhidgetHandle)info->handle, phidget_on_error, info);

	CPhidget_open((CPhidgetHandle)info->handle, FIX2INT(serial)); 
  
  return self;
}

VALUE phidget_close(VALUE self) {
  PhidgetInfo *info = get_info(self);

  printf("Inside phidget_close \n");

  CPhidget_set_OnAttach_Handler((CPhidgetHandle)info->handle, NULL, NULL);
  CPhidget_set_OnDetach_Handler((CPhidgetHandle)info->handle, NULL, NULL);
  CPhidget_set_OnError_Handler((CPhidgetHandle)info->handle, NULL, NULL);

  return Qnil;
}

VALUE phidget_wait_for_attachment(VALUE self, VALUE timeout) {
  PhidgetInfo *info = get_info(self);

	//get the program to wait for a phidget device to be attached
	printf("Waiting for phidget to be attached.... \n");

  int result;
  const char *err;

	if(result = CPhidget_waitForAttachment((CPhidgetHandle)info->handle, FIX2UINT(timeout))) {
		CPhidget_getErrorDescription(result, &err);
		printf("Problem waiting for attachment: %s\n", err);
    return Qfalse;
	}

  return Qtrue;
}

VALUE phidget_is_attached(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->is_attached) ? Qtrue : Qfalse;
}

VALUE phidget_device_class(VALUE self) {
  PhidgetInfo *info = get_info(self);

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

VALUE phidget_device_id(VALUE self) {
  PhidgetInfo *info = get_info(self);

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

VALUE phidget_type(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->type == NULL) ? Qnil : rb_str_new2(info->type);
}

VALUE phidget_name(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->name == NULL) ? Qnil : rb_str_new2(info->name);
}

VALUE phidget_label(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->label == NULL) ? Qnil : rb_str_new2(info->label);
}

VALUE phidget_serial_number(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->serial == 0) ? Qnil : INT2FIX(info->serial);
}  

VALUE phidget_version(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->version == 0) ? Qnil : INT2FIX(info->version);
}  

VALUE phidget_sample_rate(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return DBL2NUM(info->sample_rate);
}  
