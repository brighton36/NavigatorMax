#include "phidgets_native.h"

/* 
 * Document-class: Phidgets::Device
 *
 * This class is the base class from which all phidget devices will inherit.
 * Basic functionality related to the management of any device can be found
 * in here. These methods are all available to all phidgets.
 */

/*
 * Document-class: Phidgets::Spatial
 *
 * This class provides functionality specific to the "Spatial" device class. 
 * Primarily, this includes reporting of acceleration, compass, and orientation 
 * vectors.
 */

/*
 * Document-class: Phidgets::PhidgetNotFoundError
 *
 * This exception is raised when the library receives a EPHIDGET_NOTFOUNDERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetNoMemoryError
 *
 * This exception is raised when the library receives a EPHIDGET_NOMEMORYERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetUnexpectedError
 *
 * This exception is raised when the library receives a EPHIDGET_UNEXPECTEDERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetInvalidArgError
 *
 * This exception is raised when the library receives a EPHIDGET_INVALIDARGERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetNotAttachedError
 *
 * This exception is raised when the library receives a EPHIDGET_NOTATTACHEDERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetInterruptedError
 *
 * This exception is raised when the library receives a EPHIDGET_INTERRUPTEDERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetInvalidError
 *
 * This exception is raised when the library receives a EPHIDGET_INVALIDERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetNetworkError
 *
 * This exception is raised when the library receives a EPHIDGET_NETWORKERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetUnknownValError
 *
 * This exception is raised when the library receives a EPHIDGET_UNKNOWNVALERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetBadPasswordError
 *
 * This exception is raised when the library receives a EPHIDGET_BADPASSWORDERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetUnsupportedError
 *
 * This exception is raised when the library receives a EPHIDGET_UNSUPPORTEDERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetDuplicateError
 *
 * This exception is raised when the library receives a EPHIDGET_DUPLICATEERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetTimeoutError
 *
 * This exception is raised when the library receives a EPHIDGET_TIMEOUTERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetOutOfBoundsError
 *
 * This exception is raised when the library receives a EPHIDGET_OUTOFBOUNDSERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetEventError
 *
 * This exception is raised when the library receives a EPHIDGET_EVENTERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetNetworkNotConnectedError
 *
 * This exception is raised when the library receives a EPHIDGET_NETWORKNOTCONNECTEDERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetWrongDeviceError
 *
 * This exception is raised when the library receives a EPHIDGET_WRONGDEVICEERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetClosedError
 *
 * This exception is raised when the library receives a EPHIDGET_CLOSEDERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetBadVersionError
 *
 * This exception is raised when the library receives a EPHIDGET_BADVERSIONERROR
 * error.
 */

/*
 * Document-class: Phidgets::PhidgetUnhandledError
 *
 * This exception is raised when the library receives a EPHIDGET_UNHANDLEDERROR
 * error.
 */

/* 
 * Document-class: Phidgets::Accelerometer
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::AdvancedServo
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::Encoder
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::InterfaceKit
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::IR
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::LED
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::GPS
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::MotorControl
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::PHSensor
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::RFID
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::Servo
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::Stepper
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::TemperatureSensor
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::TextLCD
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::TextLED
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::WeightSensor
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::Analog
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::Bridge
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

/* 
 * Document-class: Phidgets::FrequencyCounter
 *
 * This class is a stub, and is currently in need of an actual implementation.
 * Nontheless, all of the methods from its parent class Phidgets::Device are 
 * available.
 */

void Init_phidgets_native() {
  const char *phidget_library_version;

  ensure(CPhidget_getLibraryVersion(&phidget_library_version));	
  /*
   * Just a container module for all of our objects
   */
  VALUE m_Phidget = rb_define_module("Phidgets");

  /*
   * This constant is a string which reflects the version of the phidget library being used.
   */
  rb_define_const(m_Phidget, "LIBRARY_VERSION", rb_str_new2(phidget_library_version));

  /*
   * Document-method: enable_logging!
   * call-seq:
   *   enable_logging!(log_level, file_path = nil) -> nil
   *
   * This method will enable logging within the Phidget library. The log_level
   * parameter indicates the highest degree of desired output verbosity. Logged
   * data will be that which is less than or equal to this level. Currently, the
   * supported verbosity levels, in ascending order of verbosity are as follows:
   *  :critical, :error, :warning, :debug, :info, :verbose
   * Be sure to specify a symbol, and not a string.
   *
   * The optional file_path parameter can be used to divert logging output to a
   * file, instead of the default behavior of logging to stdout. Be advised that
   * only absolute path names appear to be supported by the library at this time.
   */
  rb_define_singleton_method(m_Phidget, "enable_logging!", phidget_enable_logging, -1);

  /*
   * Document-method: log
   * call-seq:
   *   log(log_level, message) -> nil
   *
   * Logs an event of type log_level to the Phidget log, citing the provided message.
   * Supported log_levels are declared in the enable_logging! method.
   */
  rb_define_singleton_method(m_Phidget, "log", phidget_log, 2);

  /*
   * Document-method: disable_logging!
   * call-seq:
   *   disable_logging! -> nil
   *
   * This method will disable logging within the Phidget library, if logging was
   * previously enabled.
   */
  rb_define_singleton_method(m_Phidget, "disable_logging!", phidget_disable_logging, 0);

  /*
   * Document-method: all
   * call-seq:
   *  all -> nil
   *
   * This method will return an array of Phidget objects. These objects all the 
   * represent all the Phidgets which are currently connected to your computer.
   */
  rb_define_singleton_method(m_Phidget, "all", phidget_all, 0);
 
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

  // Phidgets::Device
  VALUE c_Device = rb_define_class_under(m_Phidget,"Device",rb_cObject);
  rb_define_alloc_func(c_Device, phidget_allocate);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
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
  
  // Phidgets::Spatial
  VALUE c_Spatial = rb_define_class_under(m_Phidget,"Spatial",c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
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
  
  // Phidgets::GPS
  VALUE c_Gps = rb_define_class_under(m_Phidget,"GPS",c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_Gps, "initialize", gps_initialize, 1);

  // Phidgets::InterfaceKit
  VALUE c_InterfaceKit = rb_define_class_under(m_Phidget,"InterfaceKit",c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_InterfaceKit, "initialize", interfacekit_initialize, 1);

  // Phidgets::Accelerometer
 	VALUE c_Accelerometer = rb_define_class_under(m_Phidget, "Accelerometer", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_Accelerometer, "initialize", accelerometer_initialize, 1);

  // Phidgets::AdvancedServo
 	VALUE c_AdvancedServo = rb_define_class_under(m_Phidget, "AdvancedServo", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_AdvancedServo, "initialize", advancedservo_initialize, 1);

  // Phidgets::Encoder
 	VALUE c_Encoder = rb_define_class_under(m_Phidget, "Encoder", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_Encoder, "initialize", encoder_initialize, 1);

  // Phidgets::IR
 	VALUE c_IR = rb_define_class_under(m_Phidget, "IR", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_IR, "initialize", ir_initialize, 1);

  // Phidgets::LED
 	VALUE c_LED = rb_define_class_under(m_Phidget, "LED", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_LED, "initialize", led_initialize, 1);

  // Phidgets::MotorControl
 	VALUE c_MotorControl = rb_define_class_under(m_Phidget, "MotorControl", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_MotorControl, "initialize", motorcontrol_initialize, 1);

  // Phidgets::PHSensor
 	VALUE c_PHSensor = rb_define_class_under(m_Phidget, "PHSensor", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_PHSensor, "initialize", phsensor_initialize, 1);

  // Phidgets::RFID
 	VALUE c_RFID = rb_define_class_under(m_Phidget, "RFID", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_RFID, "initialize", rfid_initialize, 1);

  // Phidgets::Servo
 	VALUE c_Servo = rb_define_class_under(m_Phidget, "Servo", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_Servo, "initialize", servo_initialize, 1);

  // Phidgets::Stepper
 	VALUE c_Stepper = rb_define_class_under(m_Phidget, "Stepper", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_Stepper, "initialize", stepper_initialize, 1);

  // Phidgets::TemperatureSensor
 	VALUE c_TemperatureSensor = rb_define_class_under(m_Phidget, "TemperatureSensor", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_TemperatureSensor, "initialize", temperaturesensor_initialize, 1);

  // Phidgets::TextLCD
 	VALUE c_TextLCD = rb_define_class_under(m_Phidget, "TextLCD", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_TextLCD, "initialize", textlcd_initialize, 1);

  // Phidgets::TextLED
 	VALUE c_TextLED = rb_define_class_under(m_Phidget, "TextLED", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_TextLED, "initialize", textled_initialize, 1);

  // Phidgets::WeightSensor
 	VALUE c_WeightSensor = rb_define_class_under(m_Phidget, "WeightSensor", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_WeightSensor, "initialize", weightsensor_initialize, 1);

  // Phidgets::Analog
 	VALUE c_Analog = rb_define_class_under(m_Phidget, "Analog", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_Analog, "initialize", analog_initialize, 1);

  // Phidgets::Bridge
 	VALUE c_Bridge = rb_define_class_under(m_Phidget, "Bridge", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_Bridge, "initialize", bridge_initialize, 1);

  // Phidgets::FrequencyCounter
 	VALUE c_FrequencyCounter = rb_define_class_under(m_Phidget, "FrequencyCounter", c_Device);

  /*
   * Document-method: new
   * call-seq:
   *   new(serial_number)
   *
   * All phidget objects are created from the device serial number. Serial numbers
   * are required to be Fixnums (aka "unsigned integers").
   */
  rb_define_method(c_FrequencyCounter, "initialize", frequencycounter_initialize, 1);
}

VALUE interfacekit_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetInterfaceKitHandle interfacekit = 0;
  ensure(CPhidgetInterfaceKit_create(&interfacekit));
  info->handle = (CPhidgetHandle)interfacekit;
  return rb_call_super(1, &serial);
}

VALUE gps_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetGPSHandle gps = 0;
  ensure(CPhidgetGPS_create(&gps));
  info->handle = (CPhidgetHandle)gps;
  return rb_call_super(1, &serial);
}

VALUE accelerometer_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);

  CPhidgetAccelerometerHandle accelerometer = 0;
  ensure(CPhidgetAccelerometer_create(&accelerometer));

  info->handle = (CPhidgetHandle)accelerometer;
  return rb_call_super(1, &serial);
}

VALUE advancedservo_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetAdvancedServoHandle advancedservo = 0;
  ensure(CPhidgetAdvancedServo_create(&advancedservo));
  info->handle = (CPhidgetHandle)advancedservo;
  return rb_call_super(1, &serial);
}

VALUE encoder_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetEncoderHandle encoder = 0;
  ensure(CPhidgetEncoder_create(&encoder));
  info->handle = (CPhidgetHandle)encoder;
  return rb_call_super(1, &serial);
}

VALUE ir_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetIRHandle ir = 0;
  ensure(CPhidgetIR_create(&ir));
  info->handle = (CPhidgetHandle)ir;
  return rb_call_super(1, &serial);
}

VALUE led_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetLEDHandle led = 0;
  ensure(CPhidgetLED_create(&led));
  info->handle = (CPhidgetHandle)led;
  return rb_call_super(1, &serial);
}

VALUE motorcontrol_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetMotorControlHandle motorcontrol = 0;
  ensure(CPhidgetMotorControl_create(&motorcontrol));
  info->handle = (CPhidgetHandle)motorcontrol;
  return rb_call_super(1, &serial);
}

VALUE phsensor_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetPHSensorHandle phsensor  = 0;
  ensure(CPhidgetPHSensor_create(&phsensor));
  info->handle = (CPhidgetHandle)phsensor ;
  return rb_call_super(1, &serial);
}

VALUE rfid_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetRFIDHandle rfid = 0;
  ensure(CPhidgetRFID_create(&rfid));
  info->handle = (CPhidgetHandle)rfid;
  return rb_call_super(1, &serial);
}

VALUE servo_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetServoHandle servo = 0;
  ensure(CPhidgetServo_create(&servo));
  info->handle = (CPhidgetHandle)servo;
  return rb_call_super(1, &serial);
}

VALUE stepper_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetStepperHandle stepper = 0;
  ensure(CPhidgetStepper_create(&stepper));
  info->handle = (CPhidgetHandle)stepper;
  return rb_call_super(1, &serial);
}

VALUE temperaturesensor_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetTemperatureSensorHandle temperaturesensor = 0;
  ensure(CPhidgetTemperatureSensor_create(&temperaturesensor));
  info->handle = (CPhidgetHandle)temperaturesensor;
  return rb_call_super(1, &serial);
}

VALUE textlcd_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetTextLCDHandle textlcd = 0;
  ensure(CPhidgetTextLCD_create(&textlcd));
  info->handle = (CPhidgetHandle)textlcd;
  return rb_call_super(1, &serial);
}

VALUE textled_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetTextLEDHandle textled = 0;
  ensure(CPhidgetTextLED_create(&textled));
  info->handle = (CPhidgetHandle)textled;
  return rb_call_super(1, &serial);
}

VALUE weightsensor_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetWeightSensorHandle weightsensor = 0;
  ensure(CPhidgetWeightSensor_create(&weightsensor));
  info->handle = (CPhidgetHandle)weightsensor;
  return rb_call_super(1, &serial);
}

VALUE analog_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetAnalogHandle analog = 0;
  ensure(CPhidgetAnalog_create(&analog));
  info->handle = (CPhidgetHandle)analog;
  return rb_call_super(1, &serial);
}

VALUE bridge_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetBridgeHandle bridge = 0;
  ensure(CPhidgetBridge_create(&bridge));
  info->handle = (CPhidgetHandle)bridge;
  return rb_call_super(1, &serial);
}

VALUE frequencycounter_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetFrequencyCounterHandle frequencycounter = 0;
  ensure(CPhidgetFrequencyCounter_create(&frequencycounter));
  info->handle = (CPhidgetHandle)frequencycounter;
  return rb_call_super(1, &serial);
}


