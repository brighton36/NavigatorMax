#include <stdio.h>
#include <ruby.h>
#include <phidget21.h>

VALUE Phidget = Qnil;
VALUE Spatial = Qnil;

void Init_ruby_extension_test();
VALUE testing(VALUE self);
VALUE open(VALUE self, VALUE serial);

//callback that will run if the Spatial is attached to the computer
int CCONV AttachHandler(CPhidgetHandle spatial, void *userptr)
{
  int serialNo;
  CPhidget_getSerialNumber(spatial, &serialNo);
  printf("Spatial %10d attached!", serialNo);

  return 0;
}

//callback that will run if the Spatial is detached from the computer
int CCONV DetachHandler(CPhidgetHandle spatial, void *userptr)
{
  int serialNo;
  CPhidget_getSerialNumber(spatial, &serialNo);
  printf("Spatial %10d detached! \n", serialNo);

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
  int i;
  printf("Number of Data Packets in this event: %d\n", count);
  //for(i = 0; i < count; i++)
  //{
    //printf("=== Data Set: %d ===\n", i);
    //printf("Acceleration> x: %6f  y: %6f  x: %6f\n", data[i]->acceleration[0], data[i]->acceleration[1], data[i]->acceleration[2]);
    //printf("Angular Rate> x: %6f  y: %6f  x: %6f\n", data[i]->angularRate[0], data[i]->angularRate[1], data[i]->angularRate[2]);
    //printf("Magnetic Field> x: %6f  y: %6f  x: %6f\n", data[i]->magneticField[0], data[i]->magneticField[1], data[i]->magneticField[2]);
    //printf("Timestamp> seconds: %d -- microseconds: %d\n", data[i]->timestamp.seconds, data[i]->timestamp.microseconds);
  //}

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
  Spatial = rb_define_module_under(Phidget, "Spatial");
  rb_define_singleton_method(Spatial, "testing", testing, 0);
  rb_define_singleton_method(Spatial, "open", open, 1);

  printf("Hello");

}

VALUE testing(VALUE self) {
  return rb_str_new2("hello world");
}  

VALUE open(VALUE self, VALUE serial) {
  int result;
  const char *err;

  //Declare a spatial handle
  CPhidgetSpatialHandle spatial = 0;

  //create the spatial object
  CPhidgetSpatial_create(&spatial);

  //Set the handlers to be run when the device is plugged in or opened from software, unplugged or closed from software, or generates an error.
	CPhidget_set_OnAttach_Handler((CPhidgetHandle)spatial, AttachHandler, NULL);
	CPhidget_set_OnDetach_Handler((CPhidgetHandle)spatial, DetachHandler, NULL);
	CPhidget_set_OnError_Handler((CPhidgetHandle)spatial, ErrorHandler, NULL);

	//Registers a callback that will run according to the set data rate that will return the spatial data changes
	//Requires the handle for the Spatial, the callback handler function that will be called, 
	//and an arbitrary pointer that will be supplied to the callback function (may be NULL)
	CPhidgetSpatial_set_OnSpatialData_Handler(spatial, SpatialDataHandler, NULL);

	//open the spatial object for device connections
	CPhidget_open((CPhidgetHandle)spatial, FIX2INT(serial)); 

	//get the program to wait for a spatial device to be attached
	printf("Waiting for spatial to be attached.... \n");
	if((result = CPhidget_waitForAttachment((CPhidgetHandle)spatial, 10000)))
	{
		CPhidget_getErrorDescription(result, &err);
		printf("Problem waiting for attachment: %s\n", err);
	}

	//Display the properties of the attached spatial device
	display_properties((CPhidgetHandle)spatial);

	//read spatial event data
	printf("Reading.....\n");
	
	//Set the data rate for the spatial events
	CPhidgetSpatial_setDataRate(spatial, 16);

	//run until user input is read
	//printf("Press any key to end\n");
	//getchar();

	////since user input has been read, this is a signal to terminate the program so we will close the phidget and delete the object we created
	//printf("Closing...\n");
	//CPhidget_close((CPhidgetHandle)spatial);
	//CPhidget_delete((CPhidgetHandle)spatial);
  
  return Qnil;
}  

