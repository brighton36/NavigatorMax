#include "phidgets_native.h"

const char MSG_INVALID_LOG_LEVEL[] = "unrecognized log_level, must be one of :critical, :error, :warning, :debug, :info, or :verbose";
const char MSG_FILE_PATH_MUST_BE_STRING[] = "file_path must be string, or nil";
const char MSG_INVALID_MESSAGE_STRING[] = "message must be a string";

CPhidgetLog_level sym_to_log_level(VALUE log_sym) {
  const char *log_level_str;

  if (TYPE(log_sym) != T_SYMBOL)
    rb_raise(rb_eTypeError, MSG_INVALID_LOG_LEVEL);

  log_level_str = rb_id2name(SYM2ID(log_sym));

  if (strcmp("critical", log_level_str) == 0)
    return PHIDGET_LOG_CRITICAL;
  else if (strcmp("error", log_level_str) == 0)
    return PHIDGET_LOG_ERROR;
  else if (strcmp("warning", log_level_str) == 0)
    return PHIDGET_LOG_WARNING;
  else if (strcmp("debug", log_level_str) == 0)
    return PHIDGET_LOG_DEBUG;
  else if (strcmp("info", log_level_str) == 0)
    return PHIDGET_LOG_INFO;
  else if (strcmp("verbose", log_level_str) == 0)
    return PHIDGET_LOG_VERBOSE;
  
  rb_raise(rb_eTypeError, MSG_INVALID_LOG_LEVEL);

  return 0;
}

VALUE phidget_enable_logging(int argc, VALUE *argv, VALUE class) {
  VALUE log_level;
  VALUE file_path;

  CPhidgetLog_level phidget_log_level; 
  const char *file_path_str;

  rb_scan_args(argc, argv, "11", &log_level, &file_path);

  phidget_log_level = sym_to_log_level(log_level);

  if (TYPE(file_path) == T_STRING)
    file_path_str = StringValueCStr(file_path);
  else if( TYPE(file_path) == T_NIL)
    file_path_str = NULL;
  else
    rb_raise(rb_eTypeError, MSG_FILE_PATH_MUST_BE_STRING);

  ensure(CPhidget_enableLogging(phidget_log_level,file_path_str));

  return Qnil;
}

VALUE phidget_disable_logging(VALUE class) {
  ensure(CPhidget_disableLogging());

  return Qnil;
}

VALUE phidget_log(VALUE class, VALUE log_level, VALUE message) {
  CPhidgetLog_level phidget_log_level; 

  if (TYPE(message) != T_STRING) rb_raise(rb_eTypeError, MSG_INVALID_MESSAGE_STRING);

  phidget_log_level = sym_to_log_level(log_level);

  // I really don't know what that second parameter does. It doesn't seem too useful.
  ensure(CPhidget_log(phidget_log_level, "N/A", "%s", StringValueCStr(message)));

  return Qnil;
}
