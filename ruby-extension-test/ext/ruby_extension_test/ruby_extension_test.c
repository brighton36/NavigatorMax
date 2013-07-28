#include <stdio.h>
#include <stdbool.h>
#include <ruby.h>
#include <phidget21.h>

typedef struct phidget_data {
  CPhidgetHandle handle;
  int  serial;
  bool is_attached;
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

VALUE Phidget = Qnil;
VALUE Spatial = Qnil;

void Init_ruby_extension_test();
VALUE testing(VALUE self);
VALUE spatial_new(VALUE self, VALUE serial);
VALUE spatial_initialize(VALUE self, VALUE serial);

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
int CCONV AttachHandler(CPhidgetHandle spatial, void *userptr)
{
  int serialNo;
  CPhidget_getSerialNumber(spatial, &serialNo);
  printf("Spatial %10d attached!", serialNo);

  PhidgetInfo *info = userptr;
  info->is_attached = true;
  printf("User ptr serial %10d!", info->serial);

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
  printf("Number of Data Packets in this event: %d\n", count);

  PhidgetInfo *info = userptr;
  info->is_attached = false;

  int i;
  for(i = 0; i < count; i++) {
    info->acceleration_x = data[i]->acceleration[0];
    info->acceleration_y = data[i]->acceleration[1];
    info->acceleration_z = data[i]->acceleration[2];
    info->compass_x = data[i]->magneticField[0];
    info->compass_y = data[i]->magneticField[1];
    info->compass_z = data[i]->magneticField[2];
    info->gyroscope_x = data[i]->angularRate[0];
    info->gyroscope_y = data[i]->angularRate[1];
    info->gyroscope_z = data[i]->angularRate[2];

    //printf("=== Data Set: %d ===\n", i);
    //printf("Acceleration> x: %6f  y: %6f  x: %6f\n", data[i]->acceleration[0], data[i]->acceleration[1], data[i]->acceleration[2]);
    //printf("Angular Rate> x: %6f  y: %6f  x: %6f\n", data[i]->angularRate[0], data[i]->angularRate[1], data[i]->angularRate[2]);
    //printf("Magnetic Field> x: %6f  y: %6f  x: %6f\n", data[i]->magneticField[0], data[i]->magneticField[1], data[i]->magneticField[2]);

    // TODO
    // printf("Timestamp> seconds: %d -- microseconds: %d\n", data[i]->timestamp.seconds, data[i]->timestamp.microseconds);
  }

  //printf("---------------------------------------------\n");

  return 0;
}

int display_properties(CPhidgetHandle phid)
{
  int serialNo, version;
  const char* ptr;
  int numAccelAxes, numGyroAxes, numCompassAxes, dataRateMax, dataRateMin;

  CPhidget_getDeviceType(phid, &ptr);
  CPhidget_getSerialNumber(phid, &serialNo);
  CPhidget_getDeviceVersion(phid, &version);
  CPhidgetSpatial_getAccelerationAxisCount((CPhidgetSpatialHandle)phid, &numAccelAxes);
  CPhidgetSpatial_getGyroAxisCount((CPhidgetSpatialHandle)phid, &numGyroAxes);
  CPhidgetSpatial_getCompassAxisCount((CPhidgetSpatialHandle)phid, &numCompassAxes);
  CPhidgetSpatial_getDataRateMax((CPhidgetSpatialHandle)phid, &dataRateMax);
  CPhidgetSpatial_getDataRateMin((CPhidgetSpatialHandle)phid, &dataRateMin);

  printf("%s\n", ptr);
  printf("Serial Number: %10d\nVersion: %8d\n", serialNo, version);
  printf("Number of Accel Axes: %i\n", numAccelAxes);
  printf("Number of Gyro Axes: %i\n", numGyroAxes);
  printf("Number of Compass Axes: %i\n", numCompassAxes);
  printf("datarate> Max: %d  Min: %d\n", dataRateMax, dataRateMin);

  return 0;
}

void Init_ruby_extension_test() {
  Phidget = rb_define_module("Phidget");
  Spatial = rb_define_class_under(Phidget, "Spatial",rb_cObject);
  rb_define_singleton_method(Spatial, "new", spatial_new, 1);
  rb_define_singleton_method(Spatial, "testing", testing, 0);
  rb_define_method(Spatial, "initialize", spatial_initialize, 1);
}

VALUE testing(VALUE self) {
  return rb_str_new2("hello world");
}  

VALUE spatial_new(VALUE class, VALUE serial) {
  int result;
  const char *err;

  // Setup a spatial handle
  CPhidgetSpatialHandle spatial = 0;
  CPhidgetSpatial_create(&spatial);

  // We'll need this all over the place later:
  PhidgetInfo *info;
  VALUE phidget_info = Data_Make_Struct(class, PhidgetInfo, 0, free_phidget_data, info);
  info->serial = FIX2INT(serial);
  info->is_attached = false;
  info->handle = (CPhidgetHandle)spatial;

  // Register the event handlers:
	CPhidget_set_OnAttach_Handler((CPhidgetHandle)spatial, AttachHandler, info);
	CPhidget_set_OnDetach_Handler((CPhidgetHandle)spatial, DetachHandler, info);
	CPhidget_set_OnError_Handler((CPhidgetHandle)spatial, ErrorHandler, info);

	//Registers a callback that will run according to the set data rate that will return the spatial data changes
	//Requires the handle for the Spatial, the callback handler function that will be called, 
	//and an arbitrary pointer that will be supplied to the callback function (may be NULL)
	CPhidgetSpatial_set_OnSpatialData_Handler(spatial, SpatialDataHandler, info);

	CPhidget_open((CPhidgetHandle)spatial, FIX2INT(serial)); 

	//get the program to wait for a spatial device to be attached
	printf("Waiting for spatial to be attached.... \n");
	if((result = CPhidget_waitForAttachment((CPhidgetHandle)spatial, 10000))) {
		CPhidget_getErrorDescription(result, &err);
		printf("Problem waiting for attachment: %s\n", err);
	}

	//Display the properties of the attached spatial device
	display_properties((CPhidgetHandle)spatial);

	//Set the data rate for the spatial events
	CPhidgetSpatial_setDataRate(spatial, 16);

  // Initialize our class instance
  VALUE argv[1];
  argv[0] = serial;
  rb_obj_call_init(phidget_info, 1, argv);

  return Qnil;
}  

VALUE spatial_initialize(VALUE self, VALUE serial) {
  rb_iv_set(self, "@serial", serial);
  return self;
}
