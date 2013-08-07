#include "phidgets_native.h"

void Init_phidgets_native() {
  VALUE m_Phidget = rb_define_module("Phidget");
 
  // Phidget Library Exceptions : 
  rb_define_class_under(m_Phidget, "PhidgetTimeout", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetNotFound", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetNoMemory", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetUnexpected", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetInvalidArg", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetNotAttached", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetInterrupted", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetInvalid", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetNetwork", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetUnknownVal", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetBadPassword", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetUnsupported", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetDuplicate", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetTimeout", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetOutOfBounds", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetEvent", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetNetworkNotConnected", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetWrongDevice", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetClosed", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetBadVersion", rb_eStandardError);
  rb_define_class_under(m_Phidget, "PhidgetUnhandled", rb_eStandardError);

  // Phidget::Device
  VALUE c_Device = rb_define_class_under(m_Phidget,"Device",rb_cObject);
  rb_define_singleton_method(c_Device, "new", phidget_new, -1);
  rb_define_method(c_Device, "initialize", phidget_initialize, 1);
  rb_define_method(c_Device, "close", phidget_close, 0);

  rb_define_method(c_Device, "wait_for_attachment", phidget_wait_for_attachment, 1);
  rb_define_method(c_Device, "is_attached?", phidget_is_attached, 0);
  rb_define_method(c_Device, "device_class", phidget_device_class, 0);
  rb_define_method(c_Device, "device_id", phidget_device_id, 0);
  rb_define_method(c_Device, "type", phidget_type, 0);
  rb_define_method(c_Device, "name", phidget_name, 0);
  rb_define_method(c_Device, "label", phidget_label, 0);
  rb_define_method(c_Device, "serial_number", phidget_serial_number, 0);
  rb_define_method(c_Device, "version", phidget_version, 0);
  rb_define_method(c_Device, "sample_rate", phidget_sample_rate, 0);
  
  // Phidget::Spatial
  VALUE c_Spatial = rb_define_class_under(m_Phidget,"Spatial",c_Device);
  rb_define_method(c_Spatial, "initialize", spatial_initialize, 1);
  rb_define_method(c_Spatial, "close", spatial_close, 0);

  rb_define_method(c_Spatial, "accelerometer_axes", spatial_accelerometer_axes, 0);
  rb_define_method(c_Spatial, "compass_axes", spatial_compass_axes, 0);
  rb_define_method(c_Spatial, "gyro_axes", spatial_gyro_axes, 0);

  rb_define_method(c_Spatial, "gyro_min", spatial_gyro_min, 0);
  rb_define_method(c_Spatial, "gyro_max", spatial_gyro_max, 0);
  rb_define_method(c_Spatial, "accelerometer_min", spatial_accelerometer_min, 0);
  rb_define_method(c_Spatial, "accelerometer_max", spatial_accelerometer_max, 0);
  rb_define_method(c_Spatial, "compass_min", spatial_compass_min, 0);
  rb_define_method(c_Spatial, "compass_max", spatial_compass_max, 0);

  rb_define_method(c_Spatial, "gyro", spatial_gyro, 0);
  rb_define_method(c_Spatial, "compass", spatial_compass, 0);
  rb_define_method(c_Spatial, "accelerometer", spatial_accelerometer, 0);

  rb_define_method(c_Spatial, "zero_gyro!", spatial_zero_gyro, 0);
  rb_define_method(c_Spatial, "compass_correction=", spatial_compass_correction_set, 1);
  rb_define_method(c_Spatial, "compass_correction", spatial_compass_correction_get, 0);
  rb_define_method(c_Spatial, "data_rate=", spatial_data_rate_set, 1);
  rb_define_method(c_Spatial, "data_rate", spatial_data_rate_get, 0);
}

// This converts an array of doubles into a ruby array of numbers, or into
// nil for the case of an invalid dbl_array
VALUE double_array_to_rb(double *dbl_array, int length) {
  if (!dbl_array) return Qnil;

  VALUE rb_ary = rb_ary_new2(length);

  for(int i=0; i<length; i++) rb_ary_store(rb_ary, i, DBL2NUM(dbl_array[i]));

  return rb_ary;
}

