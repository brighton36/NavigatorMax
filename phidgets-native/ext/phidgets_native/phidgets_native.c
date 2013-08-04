#include "phidgets_native.h"

void Init_phidgets_native() {
  VALUE Phidget = rb_define_module("Phidget");
  VALUE Device = rb_define_class_under(Phidget,"Device",rb_cObject);

  rb_define_singleton_method(Device, "new", phidget_new, -1);
  rb_define_method(Device, "initialize", phidget_initialize, 1);
  rb_define_method(Device, "close", phidget_close, 0);

  // Phidget::Device
  rb_define_method(Device, "wait_for_attachment", phidget_wait_for_attachment, 1);
  rb_define_method(Device, "is_attached?", phidget_is_attached, 0);
  rb_define_method(Device, "device_class", phidget_device_class, 0);
  rb_define_method(Device, "device_id", phidget_device_id, 0);
  rb_define_method(Device, "type", phidget_type, 0);
  rb_define_method(Device, "name", phidget_name, 0);
  rb_define_method(Device, "label", phidget_label, 0);
  rb_define_method(Device, "serial_number", phidget_serial_number, 0);
  rb_define_method(Device, "version", phidget_version, 0);
  rb_define_method(Device, "sample_rate", phidget_sample_rate, 0);
  
  // Phidget::Spatial
  VALUE Spatial = rb_define_class_under(Phidget,"Spatial",Device);
  rb_define_method(Spatial, "initialize", spatial_initialize, 3);
  rb_define_method(Spatial, "close", spatial_close, 0);

  rb_define_method(Spatial, "accelerometer_axes", spatial_accelerometer_axes, 0);
  rb_define_method(Spatial, "compass_axes", spatial_compass_axes, 0);
  rb_define_method(Spatial, "gyro_axes", spatial_gyro_axes, 0);

  rb_define_method(Spatial, "gyro_min", spatial_gyro_min, 0);
  rb_define_method(Spatial, "gyro_max", spatial_gyro_max, 0);
  rb_define_method(Spatial, "accelerometer_min", spatial_accelerometer_min, 0);
  rb_define_method(Spatial, "accelerometer_max", spatial_accelerometer_max, 0);
  rb_define_method(Spatial, "compass_min", spatial_compass_min, 0);
  rb_define_method(Spatial, "compass_max", spatial_compass_max, 0);
  rb_define_method(Spatial, "gyro", spatial_gyro, 0);
  rb_define_method(Spatial, "compass", spatial_compass, 0);
  rb_define_method(Spatial, "accelerometer", spatial_accelerometer, 0);
}

