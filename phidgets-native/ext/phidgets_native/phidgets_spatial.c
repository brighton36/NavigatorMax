#include "phidgets_native.h"

void *get_type_info(VALUE self) {
  PhidgetInfo *info;
  Data_Get_Struct( self, PhidgetInfo, info );

  return info->type_info;
}

void spatial_on_free(void *type_info) {
  printf("here in the spatial free\n");

  SpatialInfo *spatial_info = type_info;
  free(spatial_info->acceleration);
  free(spatial_info->acceleration_min);
  free(spatial_info->acceleration_max);
  free(spatial_info->gyroscope);
  free(spatial_info->gyroscope_min);
  free(spatial_info->gyroscope_max);
  free(spatial_info->compass);
  free(spatial_info->compass_min);
  free(spatial_info->compass_max);
  free(spatial_info);

  return;
}

int CCONV spatial_on_attach(CPhidgetHandle phid, void *userptr) {
  printf("spatial_on_attach\n");

  PhidgetInfo *info = userptr;
  SpatialInfo *spatial_info = info->type_info;

  // Accelerometer Attributes:
  CPhidgetSpatial_getAccelerationAxisCount((CPhidgetSpatialHandle)phid, &spatial_info->accelerometer_axes);
  CPhidgetSpatial_getGyroAxisCount((CPhidgetSpatialHandle)phid, &spatial_info->gyro_axes);
  CPhidgetSpatial_getCompassAxisCount((CPhidgetSpatialHandle)phid, &spatial_info->compass_axes);

  // Dealloc if we're alloc'd, this will prevent memory leaks on device re-attachment:
  if (spatial_info->acceleration) free(spatial_info->acceleration);
  if (spatial_info->acceleration_min) free(spatial_info->acceleration_min);
  if (spatial_info->acceleration_max) free(spatial_info->acceleration_max);
  if (spatial_info->compass) free(spatial_info->compass);
  if (spatial_info->compass_min) free(spatial_info->compass_min);
  if (spatial_info->compass_max) free(spatial_info->compass_max);
  if (spatial_info->gyroscope) free(spatial_info->gyroscope);
  if (spatial_info->gyroscope_min) free(spatial_info->gyroscope_min);
  if (spatial_info->gyroscope_max) free(spatial_info->gyroscope_max);

  // Allocate space for our extents:
  spatial_info->acceleration = malloc(sizeof(double) * spatial_info->accelerometer_axes); 
  spatial_info->acceleration_min = malloc(sizeof(double) * spatial_info->accelerometer_axes); 
  spatial_info->acceleration_max = malloc(sizeof(double) * spatial_info->accelerometer_axes); 
  spatial_info->compass = malloc(sizeof(double) * spatial_info->compass_axes); 
  spatial_info->compass_min = malloc(sizeof(double) * spatial_info->compass_axes); 
  spatial_info->compass_max = malloc(sizeof(double) * spatial_info->compass_axes); 
  spatial_info->gyroscope = malloc(sizeof(double) * spatial_info->gyro_axes); 
  spatial_info->gyroscope_min = malloc(sizeof(double) * spatial_info->gyro_axes); 
  spatial_info->gyroscope_max = malloc(sizeof(double) * spatial_info->gyro_axes); 

  // Accelerometer
  for(int i=0; i < spatial_info->accelerometer_axes; i++) {
    CPhidgetSpatial_getAccelerationMin((CPhidgetSpatialHandle)phid, i, &spatial_info->acceleration_min[i]);
    CPhidgetSpatial_getAccelerationMax((CPhidgetSpatialHandle)phid, i, &spatial_info->acceleration_max[i]);
  }

  for(int i=0; i < spatial_info->compass_axes; i++) {
    CPhidgetSpatial_getMagneticFieldMin((CPhidgetSpatialHandle)phid, i, &spatial_info->compass_min[i]);
    CPhidgetSpatial_getMagneticFieldMax((CPhidgetSpatialHandle)phid, i, &spatial_info->compass_max[i]);
  }
  for(int i=0; i < spatial_info->gyro_axes; i++) {
    CPhidgetSpatial_getAngularRateMin((CPhidgetSpatialHandle)phid, i, &spatial_info->gyroscope_min[i]);
    CPhidgetSpatial_getAngularRateMax((CPhidgetSpatialHandle)phid, i, &spatial_info->gyroscope_max[i]);
  }

	// Set the data rate for the spatial events in milliseconds. 
  // Note that 1000/16 = 62.5 Hz
	CPhidgetSpatial_setDataRate((CPhidgetSpatialHandle)phid, spatial_info->data_rate);

  // Strictly speaking, this is entirely optional:
  if (spatial_info->has_compass_correction) {
    double *cc = spatial_info->compass_correction;

    CPhidgetSpatial_setCompassCorrectionParameters( (CPhidgetSpatialHandle) phid,
      cc[0], cc[1], cc[2], cc[3], cc[4], cc[5], cc[6], cc[7], cc[8], cc[9], 
      cc[10], cc[11], cc[12] );
  }

  return 0;
}

int CCONV spatial_on_detach(CPhidgetHandle phidget, void *userptr) {
  printf("Spatial_on_detach\n");
  PhidgetInfo *info = userptr;
  SpatialInfo *spatial_info = info->type_info;

  // These would be misleading to report if there's no device:
  info->sample_rate = 0;
  info->samples_in_second = 0;
  info->last_second = 0;
  info->last_microsecond = 0;

  // These would be misleading to report if there's no device:
  memset(spatial_info->acceleration, 0, sizeof(double) * spatial_info->accelerometer_axes);
  memset(spatial_info->gyroscope, 0, sizeof(double) * spatial_info->gyro_axes);
  memset(spatial_info->compass, 0, sizeof(double) * spatial_info->compass_axes);

  return 0;
}

//callback that will run at datarate
//data - array of spatial event data structures that holds the spatial data packets that were sent in this event
//count - the number of spatial data event packets included in this event
int CCONV spatial_on_data(CPhidgetSpatialHandle spatial, void *userptr, CPhidgetSpatial_SpatialEventDataHandle *data, int count)
{
  PhidgetInfo *info = userptr;
  SpatialInfo *spatial_info = info->type_info;

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
    spatial_info->acceleration[0] = data[i]->acceleration[0];
    spatial_info->acceleration[1] = data[i]->acceleration[1];
    spatial_info->acceleration[2] = data[i]->acceleration[2];
    spatial_info->compass[0] = data[i]->magneticField[0];
    spatial_info->compass[1] = data[i]->magneticField[1];
    spatial_info->compass[2] = data[i]->magneticField[2];

    // Gyros get handled slightly different:
    // NOTE: Other people may have a better way to do this, but this is the method
    // I grabbed from the phidget sample. Maybe I should report these in radians...
    spatial_info->gyroscope[0] = fmod(spatial_info->gyroscope[0] + data[i]->angularRate[0] * fractional_second, degrees_in_circle);
    spatial_info->gyroscope[1] = fmod(spatial_info->gyroscope[1] + data[i]->angularRate[1] * fractional_second, degrees_in_circle);
    spatial_info->gyroscope[2] = fmod(spatial_info->gyroscope[2] + data[i]->angularRate[2] * fractional_second, degrees_in_circle);
  }

  return 0;
}

VALUE spatial_initialize(VALUE self, VALUE serial, VALUE data_rate, VALUE compass_correction) {
  printf("Inside spatial_init\n");

  PhidgetInfo *info = get_info(self);

  SpatialInfo *spatial_info = malloc(sizeof(SpatialInfo)); 
  memset(spatial_info, 0, sizeof(SpatialInfo));

  spatial_info->data_rate = (TYPE(data_rate) == T_FIXNUM) ? FIX2INT(data_rate) : default_spatial_data_rate;

  if ( (TYPE(compass_correction) == T_ARRAY) && (RARRAY_LEN(compass_correction) == compass_correction_length) ) {
    for (int i=0; i<RARRAY_LEN(compass_correction); i++)
      spatial_info->compass_correction[i] = NUM2DBL(rb_ary_entry(compass_correction, i));

    spatial_info->has_compass_correction = true; 
  } else
    printf("TODO: Raise an exception? It'd be nice if this were optional..."); // TODO: Raise an exception

  // Setup a spatial handle
  CPhidgetSpatialHandle spatial = 0;
  CPhidgetSpatial_create(&spatial);
	CPhidgetSpatial_set_OnSpatialData_Handler(spatial, spatial_on_data, info);

  info->handle = (CPhidgetHandle)spatial;
  info->on_type_attach = spatial_on_attach;
  info->on_type_detach = spatial_on_detach;
  info->on_type_free = spatial_on_free;
  info->type_info = spatial_info;

  return rb_call_super(1, &serial);
}

VALUE spatial_close(VALUE self) {
  PhidgetInfo *info = get_info(self);

  printf("Inside spatial_close \n");

  CPhidgetSpatial_set_OnSpatialData_Handler((CPhidgetSpatialHandle)info->handle, NULL, NULL);

  return rb_call_super(0,NULL);
}

VALUE spatial_accelerometer_axes(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return (spatial_info->accelerometer_axes) ? 
    INT2FIX(spatial_info->accelerometer_axes) : Qnil;
}  

VALUE spatial_compass_axes(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return (spatial_info->compass_axes) ? INT2FIX(spatial_info->compass_axes) : Qnil;
}  

VALUE spatial_gyro_axes(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return (spatial_info->gyro_axes) ? INT2FIX(spatial_info->gyro_axes) : Qnil;
}  

VALUE spatial_accelerometer(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return double_array_to_rb(spatial_info->acceleration, spatial_info->accelerometer_axes);
}  

VALUE spatial_accelerometer_min(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return double_array_to_rb(spatial_info->acceleration_min, spatial_info->accelerometer_axes);
}  

VALUE spatial_accelerometer_max(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return double_array_to_rb(spatial_info->acceleration_max, spatial_info->accelerometer_axes);
}  

VALUE spatial_gyro(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return double_array_to_rb(spatial_info->gyroscope, spatial_info->gyro_axes);
}  

VALUE spatial_gyro_min(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return double_array_to_rb(spatial_info->gyroscope_min, spatial_info->gyro_axes);
}  

VALUE spatial_gyro_max(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return double_array_to_rb(spatial_info->gyroscope_max, spatial_info->gyro_axes);
}  

VALUE spatial_compass(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return double_array_to_rb(spatial_info->compass, spatial_info->compass_axes);
}  

VALUE spatial_compass_min(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return double_array_to_rb(spatial_info->compass_min, spatial_info->compass_axes);
}  

VALUE spatial_compass_max(VALUE self) {
  SpatialInfo *spatial_info = get_type_info(self);

  return double_array_to_rb(spatial_info->compass_max, spatial_info->compass_axes);
}  


VALUE spatial_zero_gyro(VALUE self) {
  PhidgetInfo *info = get_info(self);
  SpatialInfo *spatial_info = info->type_info;

  CPhidgetSpatial_zeroGyro((CPhidgetSpatialHandle) info->handle);
  memset(spatial_info->gyroscope, 0, sizeof(double) * spatial_info->gyro_axes);

  return Qnil;
}