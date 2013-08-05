#include <stdio.h>
#include <stdbool.h>
#include <ruby.h>
#include <phidget21.h>
#include <math.h>

static int const microseconds_in_second = 1000000;
static int const degrees_in_circle = 360;

static int const compass_correction_length = 13;
static int const default_spatial_data_rate = 16;

typedef struct phidget_info {
  CPhidgetHandle handle;
  int  serial;
  bool is_attached;
  const char *type;
  const char *name;
  const char *label;
  int version;
  CPhidget_DeviceClass device_class;
  CPhidget_DeviceID device_id;

  // Sample tracking.
  double sample_rate;       // NOTE: These are in Hz
  int samples_in_second;    // A counter which resets when the second changes

  // This is used for calculating deltas for both sample tracking, and gyro adjustment
  int last_second;
  int last_microsecond;

  // Used by the device drivers to track state:
  void *type_info;

  // Event Handlers
  int (*on_type_attach)(CPhidgetHandle phid, void *userptr);
  int (*on_type_detach)(CPhidgetHandle phid, void *userptr);
  void (*on_type_free)(void *type_info);

} PhidgetInfo;

typedef struct spatial_info {
  // Compass Correction Params:
  bool has_compass_correction;
  double compass_correction[compass_correction_length];

  // Poll interval
  int data_rate;

  // Device limits:
  int accelerometer_axes;
  int compass_axes;
  int gyro_axes;

  double *acceleration_min;
  double *acceleration_max;
  double *compass_min;
  double *compass_max;
  double *gyroscope_min;
  double *gyroscope_max;

  // Runtime Values
  double *acceleration;
  double *compass;
  double *gyroscope;

} SpatialInfo;

void Init_phidgets_native();
VALUE double_array_to_rb(double *dbl_array, int length);

// Phidget::Device
PhidgetInfo *get_info(VALUE self);
void phidget_free(PhidgetInfo *info);
int CCONV phidget_on_attach(CPhidgetHandle phid, void *userptr);
int CCONV phidget_on_detach(CPhidgetHandle phid, void *userptr);
int CCONV phidget_on_error(CPhidgetHandle phid, void *userptr, int ErrorCode, const char *unknown);

VALUE phidget_new(int argc, VALUE* argv, VALUE class);
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

// Phidget::Spatial
void spatial_on_free(void *type_info);
int CCONV spatial_on_attach(CPhidgetHandle phid, void *userptr);
int CCONV spatial_on_detach(CPhidgetHandle phid, void *userptr);
int CCONV spatial_on_data(CPhidgetSpatialHandle spatial, void *userptr, CPhidgetSpatial_SpatialEventDataHandle *data, int count);
VALUE spatial_initialize(VALUE self, VALUE serial, VALUE data_rate, VALUE compass_correction);
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

VALUE spatial_zero_gyro(VALUE self);

