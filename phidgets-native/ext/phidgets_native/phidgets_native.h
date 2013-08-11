#include <stdio.h>
#include <stdbool.h>
#include <ruby.h>
#include <phidget21.h>
#include <math.h>

static int const MICROSECONDS_IN_SECOND = 1000000;
static int const COMPASS_CORRECTION_LENGTH = 13;
static int const DEGREES_IN_CIRCLE = 360;
static int const DEFAULT_SPATIAL_DATA_RATE = 16;

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
  double compass_correction[COMPASS_CORRECTION_LENGTH];

  // Poll interval
  int data_rate;

  // Device limits:
  int accelerometer_axes;
  int compass_axes;
  int gyro_axes;
  int data_rate_max;
  int data_rate_min;

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

// Common:
VALUE double_array_to_rb(double *dbl_array, int length);
int ensure(int result);

// Phidget Module
VALUE phidget_enable_logging(int argc, VALUE *argv, VALUE class);
VALUE phidget_disable_logging(VALUE class);
VALUE phidget_log(VALUE class, VALUE log_level, VALUE message);
VALUE phidget_all(VALUE class);

// Phidget::Device
PhidgetInfo *device_info(VALUE self);
void *device_type_info(VALUE self);
void device_free(PhidgetInfo *info);
void device_sample(PhidgetInfo *info, CPhidget_Timestamp *ts);
int CCONV device_on_attach(CPhidgetHandle phid, void *userptr);
int CCONV device_on_detach(CPhidgetHandle phid, void *userptr);
int CCONV device_on_error(CPhidgetHandle phid, void *userptr, int ErrorCode, const char *unknown);

VALUE device_allocate(VALUE class);
VALUE device_initialize(VALUE self, VALUE serial);
VALUE device_close(VALUE self);
VALUE device_wait_for_attachment(VALUE self, VALUE timeout);
VALUE device_is_attached(VALUE self);
VALUE device_device_class(VALUE self);
VALUE device_device_id(VALUE self);
VALUE device_type(VALUE self);
VALUE device_name(VALUE self);
VALUE device_label(VALUE self);
VALUE device_serial_number(VALUE self);
VALUE device_version(VALUE self);
VALUE device_sample_rate(VALUE self);

// Phidget::Spatial
void spatial_on_free(void *type_info);
int CCONV spatial_on_attach(CPhidgetHandle phid, void *userptr);
int CCONV spatial_on_detach(CPhidgetHandle phid, void *userptr);
int CCONV spatial_on_data(CPhidgetSpatialHandle spatial, void *userptr, CPhidgetSpatial_SpatialEventDataHandle *data, int count);
int spatial_set_compass_correction_by_array(CPhidgetSpatialHandle phid, double *correction);
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

VALUE spatial_zero_gyro(VALUE self);
VALUE spatial_compass_correction_set(VALUE self, VALUE compass_correction);
VALUE spatial_compass_correction_get(VALUE self);
VALUE spatial_reset_compass_correction(VALUE self);

VALUE spatial_data_rate_min(VALUE self);
VALUE spatial_data_rate_max(VALUE self);
VALUE spatial_data_rate_set(VALUE self, VALUE data_rate);
VALUE spatial_data_rate_get(VALUE self);

// Phidget::InterfaceKit
VALUE interfacekit_initialize(VALUE self, VALUE serial);

// Phidget::Gps
VALUE gps_initialize(VALUE self, VALUE serial);

// Stub initializers:
VALUE accelerometer_initialize(VALUE self, VALUE serial);
VALUE advancedservo_initialize(VALUE self, VALUE serial);
VALUE encoder_initialize(VALUE self, VALUE serial);
VALUE ir_initialize(VALUE self, VALUE serial);
VALUE led_initialize(VALUE self, VALUE serial);
VALUE motorcontrol_initialize(VALUE self, VALUE serial);
VALUE phsensor_initialize(VALUE self, VALUE serial);
VALUE rfid_initialize(VALUE self, VALUE serial);
VALUE servo_initialize(VALUE self, VALUE serial);
VALUE stepper_initialize(VALUE self, VALUE serial);
VALUE temperaturesensor_initialize(VALUE self, VALUE serial);
VALUE textlcd_initialize(VALUE self, VALUE serial);
VALUE textled_initialize(VALUE self, VALUE serial);
VALUE weightsensor_initialize(VALUE self, VALUE serial);
VALUE analog_initialize(VALUE self, VALUE serial);
VALUE bridge_initialize(VALUE self, VALUE serial);
VALUE frequencycounter_initialize(VALUE self, VALUE serial);
