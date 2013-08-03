#include "phidgets_native.h"

//callback that will run at datarate
//data - array of spatial event data structures that holds the spatial data packets that were sent in this event
//count - the number of spatial data event packets included in this event
int CCONV spatial_on_data(CPhidgetSpatialHandle spatial, void *userptr, CPhidgetSpatial_SpatialEventDataHandle *data, int count)
{
  PhidgetInfo *info = userptr;

  int i;
  for(i = 0; i < count; i++) {
    info->samples_in_second++;

    // Sample tracking
    // We need the > 0 for the case of the first time we've ever entered this loop
    if ( ( info->last_second > 0 ) && ( info->last_second != data[i]->timestamp.seconds ) ) {
      info->sample_rate = (double) info->samples_in_second / 
          (double) (data[i]->timestamp.seconds - info->last_second);
      info->samples_in_second = 0;

      printf("Sample rate: %f\n", info->sample_rate);
    }
    
    // Here's where we calculate how much time was between the last sample and
    // this one, expressed as a percentage of a second:
    double fractional_second = (double) ( 
      (data[i]->timestamp.seconds - info->last_second) * microseconds_in_second + 
      data[i]->timestamp.microseconds - 
      info->last_microsecond) / microseconds_in_second;


    // Now record the last timestamp components:
    info->last_second = data[i]->timestamp.seconds;
    info->last_microsecond = data[i]->timestamp.microseconds;

    // Set the values to where they need to be:
    info->acceleration_x = data[i]->acceleration[0];
    info->acceleration_y = data[i]->acceleration[1];
    info->acceleration_z = data[i]->acceleration[2];
    info->compass_x = data[i]->magneticField[0];
    info->compass_y = data[i]->magneticField[1];
    info->compass_z = data[i]->magneticField[2];

    // Gyros get handled slightly different:
    // NOTE: Other people may have a better way to do this, but this is the method
    // I grabbed from the phidget sample. Maybe I should report these in radians...
    info->gyroscope_x = fmod(info->gyroscope_x + data[i]->angularRate[0] * fractional_second, degrees_in_circle);
    info->gyroscope_y = fmod(info->gyroscope_y + data[i]->angularRate[1] * fractional_second, degrees_in_circle);
    info->gyroscope_z = fmod(info->gyroscope_z + data[i]->angularRate[2] * fractional_second, degrees_in_circle);
  }

  return 0;
}

VALUE spatial_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);

  printf("Inside spatial_init\n");

  // Setup a spatial handle
  CPhidgetSpatialHandle spatial = 0;
  CPhidgetSpatial_create(&spatial);

  info->handle = (CPhidgetHandle)spatial;

  // Register the event handlers:
	CPhidget_set_OnAttach_Handler((CPhidgetHandle)spatial, phidget_on_attach, info);
	CPhidget_set_OnDetach_Handler((CPhidgetHandle)spatial, phidget_on_dettach, info);
	CPhidget_set_OnError_Handler((CPhidgetHandle)spatial, phidget_on_error, info);
	CPhidgetSpatial_set_OnSpatialData_Handler(spatial, spatial_on_data, info);

	CPhidget_open((CPhidgetHandle)spatial, FIX2INT(serial)); 

  rb_call_super(1, &serial);
  
  return self;
}

VALUE spatial_close(VALUE self) {
  PhidgetInfo *info = get_info(self);

  printf("Inside spatial_close \n");

  CPhidget_set_OnAttach_Handler((CPhidgetHandle)info->handle, NULL, NULL);
  CPhidget_set_OnDetach_Handler((CPhidgetHandle)info->handle, NULL, NULL);
  CPhidget_set_OnError_Handler((CPhidgetHandle)info->handle, NULL, NULL);
  CPhidgetSpatial_set_OnSpatialData_Handler((CPhidgetSpatialHandle)info->handle, NULL, NULL);

  rb_call_super(0,NULL);

  return Qnil;
}


VALUE spatial_accelerometer_axes(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->accelerometer_axes == 0) ? Qnil : INT2FIX(info->accelerometer_axes);
}  

VALUE spatial_compass_axes(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->compass_axes == 0) ? Qnil : INT2FIX(info->compass_axes);
}  

VALUE spatial_gyro_axes(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->gyro_axes == 0) ? Qnil : INT2FIX(info->gyro_axes);
}  

VALUE spatial_accelerometer_min(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->acceleration_min == 0) ? Qnil : DBL2NUM(info->acceleration_min);
}  

VALUE spatial_accelerometer_max(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->acceleration_max == 0) ? Qnil : DBL2NUM(info->acceleration_max);
}  

VALUE spatial_gyro_min(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->gyroscope_min == 0) ? Qnil : DBL2NUM(info->gyroscope_min);
}  

VALUE spatial_gyro_max(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->gyroscope_max == 0) ? Qnil : DBL2NUM(info->gyroscope_max);
}  

VALUE spatial_compass_min(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->compass_min == 0) ? Qnil : DBL2NUM(info->compass_min);
}  

VALUE spatial_compass_max(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return (info->compass_max == 0) ? Qnil : DBL2NUM(info->compass_max);
}  

VALUE spatial_accelerometer(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return rb_ary_new3(3, DBL2NUM(info->acceleration_x), 
    DBL2NUM(info->acceleration_y), DBL2NUM(info->acceleration_z) );
}  

VALUE spatial_compass(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return rb_ary_new3(3, DBL2NUM(info->compass_x), DBL2NUM(info->compass_y),
    DBL2NUM(info->compass_z) );
}  

VALUE spatial_gyro(VALUE self) {
  PhidgetInfo *info = get_info(self);

  return rb_ary_new3(3, DBL2NUM(info->gyroscope_x), DBL2NUM(info->gyroscope_y),
    DBL2NUM(info->gyroscope_z) );
}  

