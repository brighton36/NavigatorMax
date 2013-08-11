#include "phidgets_native.h"

VALUE gps_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = device_info(self);
  CPhidgetGPSHandle gps = 0;
  ensure(CPhidgetGPS_create(&gps));
  info->handle = (CPhidgetHandle)gps;
  return rb_call_super(1, &serial);
}

