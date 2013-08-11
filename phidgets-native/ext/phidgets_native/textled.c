#include "phidgets_native.h"

VALUE textled_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = get_info(self);
  CPhidgetTextLEDHandle textled = 0;
  ensure(CPhidgetTextLED_create(&textled));
  info->handle = (CPhidgetHandle)textled;
  return rb_call_super(1, &serial);
}
