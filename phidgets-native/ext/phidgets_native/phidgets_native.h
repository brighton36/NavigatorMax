#include <stdio.h>
#include <stdbool.h>
#include <ruby.h>
#include <phidget21.h>
#include <math.h>

static int const microseconds_in_second = 1000000;
static int const degrees_in_circle = 360;

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
  int samples_in_second;    // A counter which resets when the second changes

  // This is used for calculating deltas for both sample tracking, and gyro adjustment
  int last_second;
  int last_microsecond;
  
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

void Init_phidgets_native();

PhidgetInfo *get_info(VALUE self);
void phidget_free(PhidgetInfo *info);
int CCONV phidget_on_attach(CPhidgetHandle phid, void *userptr);
int CCONV phidget_on_dettach(CPhidgetHandle phidget, void *userptr);
int CCONV phidget_on_error(CPhidgetHandle phidget, void *userptr, int ErrorCode, const char *unknown);

VALUE phidget_new(VALUE self, VALUE serial);
VALUE phidget_initialize(VALUE self, VALUE serial);
VALUE phidget_close(VALUE self);
VALUE phidget_wait_for_attachment(VALUE self, VALUE timeout);
VALUE phidget_is_attached(VALUE self);
VALUE phidget_device_class(VALUE self);
VALUE phidget_device_id(VALUE self);
VALUE phidget_type(VALUE self);
VALUE phidget_name(VALUE self);
VALUE phidget_label(VALUE self);
VALUE phidget_serial_number(VALUE self);
VALUE phidget_version(VALUE self);
VALUE phidget_sample_rate(VALUE self);

int CCONV spatial_on_data(CPhidgetSpatialHandle spatial, void *userptr, CPhidgetSpatial_SpatialEventDataHandle *data, int count);
VALUE spatial_initialize(VALUE self, VALUE serial);
VALUE spatial_close(VALUE self);
VALUE spatial_accelerometer_axes(VALUE self);
VALUE spatial_compass_axes(VALUE self);
VALUE spatial_gyro_axes(VALUE self);

VALUE spatial_accelerometer_min(VALUE self);
VALUE spatial_accelerometer_max(VALUE self);
VALUE spatial_compass_min(VALUE self);
VALUE spatial_compass_max(VALUE self);
VALUE spatial_gyro_min(VALUE self);
VALUE spatial_gyro_max(VALUE self);

VALUE spatial_accelerometer(VALUE self);
VALUE spatial_compass(VALUE self);
VALUE spatial_gyro(VALUE self);

