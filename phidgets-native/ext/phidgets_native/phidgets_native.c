#include "phidgets_native.h"

/* 
 * Document-class: Phidget::Device
 *
 * This class is the base class from which all phidget devices will inherit.
 * Basic functionality related to the management of any device can be found
 * in here. These methods are all available to all phidgets.
 */

/*
 * Document-class: Phidget::Spatial
 *
 * This class provides functionality specific to the "Spatial" device class. 
 * Primarily, this includes reporting of acceleration, compass, and orientation 
 * vectors.
 */

/*
 * Document-class: Phidget::PhidgetNotFoundError
 *
 * This exception is raised when the library receives a EPHIDGET_NOTFOUNDERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetNoMemoryError
 *
 * This exception is raised when the library receives a EPHIDGET_NOMEMORYERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetUnexpectedError
 *
 * This exception is raised when the library receives a EPHIDGET_UNEXPECTEDERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetInvalidArgError
 *
 * This exception is raised when the library receives a EPHIDGET_INVALIDARGERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetNotAttachedError
 *
 * This exception is raised when the library receives a EPHIDGET_NOTATTACHEDERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetInterruptedError
 *
 * This exception is raised when the library receives a EPHIDGET_INTERRUPTEDERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetInvalidError
 *
 * This exception is raised when the library receives a EPHIDGET_INVALIDERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetNetworkError
 *
 * This exception is raised when the library receives a EPHIDGET_NETWORKERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetUnknownValError
 *
 * This exception is raised when the library receives a EPHIDGET_UNKNOWNVALERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetBadPasswordError
 *
 * This exception is raised when the library receives a EPHIDGET_BADPASSWORDERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetUnsupportedError
 *
 * This exception is raised when the library receives a EPHIDGET_UNSUPPORTEDERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetDuplicateError
 *
 * This exception is raised when the library receives a EPHIDGET_DUPLICATEERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetTimeoutError
 *
 * This exception is raised when the library receives a EPHIDGET_TIMEOUTERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetOutOfBoundsError
 *
 * This exception is raised when the library receives a EPHIDGET_OUTOFBOUNDSERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetEventError
 *
 * This exception is raised when the library receives a EPHIDGET_EVENTERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetNetworkNotConnectedError
 *
 * This exception is raised when the library receives a EPHIDGET_NETWORKNOTCONNECTEDERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetWrongDeviceError
 *
 * This exception is raised when the library receives a EPHIDGET_WRONGDEVICEERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetClosedError
 *
 * This exception is raised when the library receives a EPHIDGET_CLOSEDERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetBadVersionError
 *
 * This exception is raised when the library receives a EPHIDGET_BADVERSIONERROR
 * error.
 */

/*
 * Document-class: Phidget::PhidgetUnhandledError
 *
 * This exception is raised when the library receives a EPHIDGET_UNHANDLEDERROR
 * error.
 */

void Init_phidgets_native() {
  const char *phidget_library_version;

  ensure(CPhidget_getLibraryVersion(&phidget_library_version));	
  /*
   * Just a container module for all of our objects
   */
  VALUE m_Phidget = rb_define_module("Phidget");

  /*
   * This constant is a string which reflects the version of the phidget library being used.
   */
  rb_define_const(m_Phidget, "LIBRARY_VERSION", rb_str_new2(phidget_library_version));
 
  // Phidget Library Exceptions : 
  VALUE c_PhidgetNotFound = rb_define_class_under(m_Phidget, "PhidgetNotFoundError", rb_eStandardError);
  VALUE c_PhidgetNoMemory = rb_define_class_under(m_Phidget, "PhidgetNoMemoryError", rb_eStandardError);
  VALUE c_PhidgetUnexpected = rb_define_class_under(m_Phidget, "PhidgetUnexpectedError", rb_eStandardError);
  VALUE c_PhidgetInvalidArg = rb_define_class_under(m_Phidget, "PhidgetInvalidArgError", rb_eStandardError);
  VALUE c_PhidgetNotAttached = rb_define_class_under(m_Phidget, "PhidgetNotAttachedError", rb_eStandardError);
  VALUE c_PhidgetInterrupted = rb_define_class_under(m_Phidget, "PhidgetInterruptedError", rb_eStandardError);
  VALUE c_PhidgetInvalid = rb_define_class_under(m_Phidget, "PhidgetInvalidError", rb_eStandardError);
  VALUE c_PhidgetNetwork = rb_define_class_under(m_Phidget, "PhidgetNetworkError", rb_eStandardError);
  VALUE c_PhidgetUnknownVal = rb_define_class_under(m_Phidget, "PhidgetUnknownValError", rb_eStandardError);
  VALUE c_PhidgetBadPassword = rb_define_class_under(m_Phidget, "PhidgetBadPasswordError", rb_eStandardError);
  VALUE c_PhidgetUnsupported = rb_define_class_under(m_Phidget, "PhidgetUnsupportedError", rb_eStandardError);
  VALUE c_PhidgetDuplicate = rb_define_class_under(m_Phidget, "PhidgetDuplicateError", rb_eStandardError);
  VALUE c_PhidgetTimeout = rb_define_class_under(m_Phidget, "PhidgetTimeoutError", rb_eStandardError);
  VALUE c_PhidgetOutOfBounds = rb_define_class_under(m_Phidget, "PhidgetOutOfBoundsError", rb_eStandardError);
  VALUE c_PhidgetEvent = rb_define_class_under(m_Phidget, "PhidgetEventError", rb_eStandardError);
  VALUE c_PhidgetNetworkNotConnected = rb_define_class_under(m_Phidget, "PhidgetNetworkNotConnectedError", rb_eStandardError);
  VALUE c_PhidgetWrongDevice = rb_define_class_under(m_Phidget, "PhidgetWrongDeviceError", rb_eStandardError);
  VALUE c_PhidgetClosed = rb_define_class_under(m_Phidget, "PhidgetClosedError", rb_eStandardError);
  VALUE c_PhidgetBadVersion = rb_define_class_under(m_Phidget, "PhidgetBadVersionError", rb_eStandardError);
  VALUE c_PhidgetUnhandled = rb_define_class_under(m_Phidget, "PhidgetUnhandledError", rb_eStandardError);

  // Phidget::Device
  VALUE c_Device = rb_define_class_under(m_Phidget,"Device",rb_cObject);
  rb_define_singleton_method(c_Device, "new", phidget_new, -1);

  /*
   * Document-method: initialize
   * call-seq:
   *   initialize(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_Device, "initialize", phidget_initialize, 1);

  /*
   * Document-method: close
   * call-seq:
   *   close -> nil
   *
   * This method will unregister the phidget event handlers, and free up all
   * API resources associated with the phidget. This is an optional, but useful
   * way to remove the object's overhead before the GC kicks in and actually 
   * frees the resource.
   */
  rb_define_method(c_Device, "close", phidget_close, 0);

  /*
   * Document-method: wait_for_attachment
   * call-seq:
   *   wait_for_attachment(timeout) -> FixNum
   *
   * Call CPhidget_waitForAttachment[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html]
   * to execute wait_for_attachment.  Given a timeout, this method will pause 
   * execution until this device is attached, or timeout milliseconds expires.
   * The method returns the provided timeout parameter.
   */
  rb_define_method(c_Device, "wait_for_attachment", phidget_wait_for_attachment, 1);

  /*
   * Document-method: is_attached?
   * call-seq:
   *   is_attached? -> boolean
   *
   * Returns true if the device is connected, false if otherwise. 
   */
  rb_define_method(c_Device, "is_attached?", phidget_is_attached, 0);

  /*
   * Document-method: device_class
   * call-seq:
   *   device_class -> String
   *
   * Returns a string indicating the "class" of the device. This string comes 
   * directly from the CPhidget_getDeviceClass[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function.
   */
  rb_define_method(c_Device, "device_class", phidget_device_class, 0);

  /*
   * Document-method: device_id
   * call-seq:
   *   device_id -> String
   *
   * Returns a string indicating the "identifier" of the device. Seemingly, this
   * is the product name and part number. This string comes directly from the 
   * CPhidget_getDeviceID[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function.
   */
  rb_define_method(c_Device, "device_id", phidget_device_id, 0);

  /*
   * Document-method: type
   * call-seq:
   *   type -> String
   *
   * Returns a string indicating the "type" of the device. This doesn't appear 
   * to differ much from the device_closs. This string comes directly from the 
   * CPhidget_getDeviceType[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function.
   */
  rb_define_method(c_Device, "type", phidget_type, 0);

  /*
   * Document-method: name
   * call-seq:
   *   name -> String
   *
   * Returns a string indicating the "name" of the device. This seems to be just
   * the product name. This string comes directly from the 
   * CPhidget_getDeviceName[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function.
   */
  rb_define_method(c_Device, "name", phidget_name, 0);

  /*
   * Document-method: label
   * call-seq:
   *   label -> String
   *
   * Returns a string which contains the device label. This string comes directly 
   * from the CPhidget_getDeviceLabel[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function.
   */
  rb_define_method(c_Device, "label", phidget_label, 0);

  /*
   * Document-method: serial_number
   * call-seq:
   *   serial_number -> FixNum
   *
   * Returns a string which contains the device's serial number. This string comes 
   * from what was provided in the object initializer
   */
  rb_define_method(c_Device, "serial_number", phidget_serial_number, 0);

  /*
   * Document-method: version
   * call-seq:
   *   version -> FixNum
   *
   * Returns an FixNum containing the device firmware version. This number comes
   * from the CPhidget_getDeviceVersion[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function.
   */
  rb_define_method(c_Device, "version", phidget_version, 0);

  /*
   * Document-method: version
   * call-seq:
   *   sample_rate -> Float
   *
   * For most Phidgets, an event handler processes the device state changes at
   * some regular interval. For these devices, this method will return the rate
   * of state changes measured in Hz.
   */
  rb_define_method(c_Device, "sample_rate", phidget_sample_rate, 0);
  
  // Phidget::Spatial
  VALUE c_Spatial = rb_define_class_under(m_Phidget,"Spatial",c_Device);

  /*
   * Document-method: initialize
   * call-seq:
   *   initialize(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_Spatial, "initialize", spatial_initialize, 1);

  /*
   * Document-method: close
   * call-seq:
   *   close -> nil
   *
   * This method will unregister the phidget event handlers, and free up all
   * API resources associated with the phidget. This is an optional, but useful
   * way to remove the object's overhead before the GC kicks in and actually 
   * frees the resource.
   */
  rb_define_method(c_Spatial, "close", spatial_close, 0);

  /*
   * Document-method: accelerometer_axes
   * call-seq:
   *   accelerometer_axes -> Fixnum
   *
   * This method returns the number of axis reported by the accelerometer. This 
   * number comes from the 
   * CPhidgetSpatial_getAccelerationAxisCount[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html] 
   * function.
   */
  rb_define_method(c_Spatial, "accelerometer_axes", spatial_accelerometer_axes, 0);

  /*
   * Document-method: compass_axes
   * call-seq:
   *   compass_axes -> Fixnum
   *
   * This method returns the number of axis reported by the compass. This 
   * number comes from the 
   * CPhidgetSpatial_getCompassAxisCount[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html] 
   * function.
   */
  rb_define_method(c_Spatial, "compass_axes", spatial_compass_axes, 0);

  /*
   * Document-method: gyro_axes
   * call-seq:
   *   gyro_axes -> Fixnum
   *
   * This method returns the number of axis reported by the gyroscope. This 
   * number comes from the 
   * CPhidgetSpatial_getGyroAxisCount[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html] 
   * function.
   */
  rb_define_method(c_Spatial, "gyro_axes", spatial_gyro_axes, 0);

  /*
   * Document-method: gyro_min
   * call-seq:
   *   gyro_min -> Array
   *
   * This method returns an array of Float(s) which represent the minimal value
   * that an axis will report during a sample interval. These values come from the
   * CPhidgetSpatial_getAngularRateMin[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html] 
   * function.
   */
  rb_define_method(c_Spatial, "gyro_min", spatial_gyro_min, 0);

  /*
   * Document-method: gyro_max
   * call-seq:
   *   gyro_max -> Array
   *
   * This method returns an array of Float(s) which represent the maximal value
   * that an axis will report during a sample interval. These values come from the
   * CPhidgetSpatial_getAngularRateMax[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html] 
   * function.
   */
  rb_define_method(c_Spatial, "gyro_max", spatial_gyro_max, 0);

  /*
   * Document-method: accelerometer_min
   * call-seq:
   *   accelerometer_min -> Array
   *
   * This method returns an array of Float(s) which represent the minimal value
   * that an axis will report during a sample interval. These values come from the
   * CPhidgetSpatial_getAccelerationMin[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html] 
   * function.
   */
  rb_define_method(c_Spatial, "accelerometer_min", spatial_accelerometer_min, 0);

  /*
   * Document-method: accelerometer_max
   * call-seq:
   *   accelerometer_max -> Array
   *
   * This method returns an array of Float(s) which represent the maximal value
   * that an axis will report during a sample interval. These values come from the
   * CPhidgetSpatial_getAccelerationMax[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html] 
   * function.
   */
  rb_define_method(c_Spatial, "accelerometer_max", spatial_accelerometer_max, 0);

  /*
   * Document-method: compass_min
   * call-seq:
   *   compass_min -> Array
   *
   * This method returns an array of Float(s) which represent the minimal value
   * that an axis will report during a sample interval. These values come from the
   * CPhidgetSpatial_getMagneticFieldMin[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html] 
   * function.
   */
  rb_define_method(c_Spatial, "compass_min", spatial_compass_min, 0);

  /*
   * Document-method: compass_max
   * call-seq:
   *   compass_max -> Array
   *
   * This method returns an array of Float(s) which represent the maximal value
   * that an axis will report during a sample interval. These values come from the
   * CPhidgetSpatial_getMagneticFieldMax[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html] 
   * function.
   */
  rb_define_method(c_Spatial, "compass_max", spatial_compass_max, 0);

  /*
   * Document-method: gyro
   * call-seq:
   *   gyro -> Array
   *
   * This method returns an array of Float(s) which represent the normalized value 
   * of each axis on the gyro in degrees (0-359.9). These values are calculated 
   * by accumulating the delta measurements which are reported inside the
   * CPhidgetSpatial_set_OnSpatialData_Handler[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html]
   * event handler. 
   *
   * NOTE: There's probably better algorithms to calculate this value than the 
   * one being used by this library. The algorithm used was merely the one found 
   * in the phidget-provided examples. Feel free to submit your algorithm for 
   * inclusion in this library if you know of a better way to do this.
   */
  rb_define_method(c_Spatial, "gyro", spatial_gyro, 0);

  /*
   * Document-method: compass
   * call-seq:
   *   compass -> Array
   *
   * This method returns an array of Float(s) which represent the relative magnetic 
   * attraction of each axis. These values are merely those which were most 
   * recently reported via the 
   * CPhidgetSpatial_set_OnSpatialData_Handler[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html]
   * event handler.
   *
   * NOTE: Sometimes the phidget library won't have values to report on this
   * measurement due to "EPHIDGET_UNKNOWNVAL" errors. When we come up against 
   * this case, we return the last values that were reported successfully.
   *
   * NOTE: You probably want this value in degrees. This is difficult, primarily
   * due to the pre-requisite of knowing what the cross-product is of the ground
   * plane (aka, the ground's surface normal). I might add a 'bad estimate'
   * of this vector in a future version of the library. E-mail the author if you 
   * need some sample code based on the accelerometer's inverse vector.
   */
  rb_define_method(c_Spatial, "compass", spatial_compass, 0);

  /*
   * Document-method: accelerometer
   * call-seq:
   *   accelerometer -> Array
   *
   * This method returns an array of Float(s) which represent the accelerometer 
   * magnitude of each axis, in meters per second. These values are merely those
   * which were most recently reported via the 
   * CPhidgetSpatial_set_OnSpatialData_Handler[http://www.phidgets.com/documentation/web/cdoc/group__phidspatial.html]
   * event handler.
   */
  rb_define_method(c_Spatial, "accelerometer", spatial_accelerometer, 0);

  /*
   * Document-method: zero_gyro!
   * call-seq:
   *   zero_gyro! -> nil
   *
   * Zero's the gyro values, and reference point. Once this method is executed
   * it takes approximately two seconds for the gyro to zero, and start returning
   * its offsets. This method zero's out the current gyro state vector and calls the 
   * CPhidgetSpatial_zeroGyro[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function.
   */
  rb_define_method(c_Spatial, "zero_gyro!", spatial_zero_gyro, 0);

  /*
   * Document-method: reset_compass_correction!
   * call-seq:
   *   reset_compass_correction! -> nil
   *
   * Zero's the compass correction parameters. This method calls the 
   * CPhidgetSpatial_resetCompassCorrectionParameters[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function.
   */
  rb_define_method(c_Spatial, "reset_compass_correction!", spatial_reset_compass_correction, 0);

  /*
   * Document-method: compass_correction=
   * call-seq:
   *   compass_correction=( Array correction_parameters ) -> Array
   *
   * This method expects a thirteen digit array of Floats, which are passed to the 
   * CPhidgetSpatial_setCompassCorrectionParameters[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function. It returns the provided array.
   */
  rb_define_method(c_Spatial, "compass_correction=", spatial_compass_correction_set, 1);

  /*
   * Document-method: compass_correction
   * call-seq:
   *   compass_correction -> Array
   *
   * This method returns the current compass_correction parameters, which were
   * previously supplied to the compass_correction= method. If no such corrections
   * were supplied, the return is nil.
   */
  rb_define_method(c_Spatial, "compass_correction", spatial_compass_correction_get, 0);

  /*
   * Document-method: data_rate_min
   * call-seq:
   *   data_rate_min -> Fixnum
   *
   * This method returns a Fixnum which represents the minimaly supported data rate
   * that is supported by the library. This value comes direct from the
   * CPhidgetSpatial_getDataRateMin[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function.
   *
   * NOTE: Keep in mind that the higher the value, the "lower" the rate. 
   */
  rb_define_method(c_Spatial, "data_rate_min", spatial_data_rate_min, 0);

  /*
   * Document-method: data_rate_max
   * call-seq:
   *   data_rate_max -> Fixnum
   *
   * This method returns a Fixnum which represents the maximum supported data rate
   * that is supported by the library. This value comes direct from the
   * CPhidgetSpatial_getDataRateMax[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function.
   *
   * NOTE: Keep in mind that the lower the value, the "higher" the rate. 
   */
  rb_define_method(c_Spatial, "data_rate_max", spatial_data_rate_max, 0);

  /*
   * Document-method: data_rate=
   * call-seq:
   *   data_rate=( FixNum rate_in_ms ) -> FixNum
   *
   * This method expects a FixNum, which is passed to the 
   * CPhidgetSpatial_setDataRate[http://www.phidgets.com/documentation/web/cdoc/group__phidcommon.html] 
   * function. This value is the number of milliseconds between device sampling
   * reports, and it defaults to 16.
   * 
   * NOTE: For the case of 16, the data_rate as would be measured in Hz is 62.5: 1000/16 = 62.5 Hz
   */
  rb_define_method(c_Spatial, "data_rate=", spatial_data_rate_set, 1);

  /*
   * Document-method: data_rate
   * call-seq:
   *   data_rate -> FixNum
   *
   * This method returns the current data_rate as was previously supplied to the 
   * data_rate= method. If no such rate was supplied, then this method returns
   * the default rate, which is 16.
   */
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

