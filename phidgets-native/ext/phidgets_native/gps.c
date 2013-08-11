#include "phidgets_native.h"

int CCONV gps_on_position_change(CPhidgetGPSHandle gps, void *userptr, double latitude, double longitude, double altitude) {
  PhidgetInfo *info = userptr;
  GpsInfo *gps_info = info->type_info;

  gps_info->latitude = latitude;
  gps_info->longitude = longitude;
  gps_info->altitude = altitude;

  double heading;
  double velocity;

  // TODO: I get the impression that these are only sometimes available, and that
  // this fails. Maybe we want to ensure this? Maybe we want to check the PUNKness:
	if( (CPhidgetGPS_getHeading(gps, &heading) == EPHIDGET_OK) && 
      (CPhidgetGPS_getVelocity(gps, &velocity) == EPHIDGET_OK) ) {
    gps_info->heading = heading;
    gps_info->velocity = velocity;
		printf(" Heading: %3.2lf, Velocity: %4.3lf\n",heading, velocity);
  } else {
    gps_info->heading = 0;
    gps_info->velocity = 0;
  }

  /* TODO
	GPSDate date;
	GPSTime time;

	if(!CPhidgetGPS_getDate(gps, &date) && !CPhidgetGPS_getTime(gps, &time))
		printf(" Date: %02d/%02d/%02d Time %02d:%02d:%02d.%03d\n", date.tm_mday, date.tm_mon, date.tm_year, time.tm_hour, time.tm_min, time.tm_sec, time.tm_ms);
  */

	printf("Position Change event: lat: %3.4lf, long: %4.4lf, alt: %5.4lf\n", latitude, longitude, altitude);

	return 0;
}

int CCONV gps_on_fix_change(CPhidgetGPSHandle gps, void *userptr, int status) {
  /* 
   * TODO, this should be true or false I think:
    gps_info->is_fixed;
   */

	printf("TODO: Fix change event (what does this value mean): %d\n", status);

	return 0;
}

VALUE gps_initialize(VALUE self, VALUE serial) {
  PhidgetInfo *info = device_info(self);
  
  GpsInfo *gps_info = ALLOC(GpsInfo); 
  memset(gps_info, 0, sizeof(GpsInfo));

  CPhidgetGPSHandle gps = 0;

  ensure(CPhidgetGPS_create(&gps));

  ensure(CPhidgetGPS_set_OnPositionChange_Handler( gps, gps_on_position_change, info));
 	ensure(CPhidgetGPS_set_OnPositionFixStatusChange_Handler(gps, gps_on_fix_change, info));

  info->handle = (CPhidgetHandle)gps;
  info->on_type_detach = gps_on_detach;
  info->on_type_free = gps_on_free;
  info->type_info = gps_info;

  return rb_call_super(1, &serial);
}

int CCONV gps_on_detach(CPhidgetHandle phidget, void *userptr) {
  PhidgetInfo *info = userptr;
  GpsInfo *gps_info = info->type_info;

  // Zero out the polled values, which happens to be everything so far:
  memset(gps_info, 0, sizeof(GpsInfo));
  
  return 0;
}

void gps_on_free(void *type_info) {
  GpsInfo *gps_info = type_info;

  xfree(gps_info);
  return;
}

VALUE gps_latitude(VALUE self) {
  GpsInfo *gps_info = device_type_info(self);

  return DBL2NUM(gps_info->latitude);
}

VALUE gps_longitude(VALUE self) {
  GpsInfo *gps_info = device_type_info(self);

  return DBL2NUM(gps_info->longitude);
}

VALUE gps_altitude(VALUE self) {
  GpsInfo *gps_info = device_type_info(self);

  return DBL2NUM(gps_info->altitude);
}

VALUE gps_heading(VALUE self) {
  GpsInfo *gps_info = device_type_info(self);

  return DBL2NUM(gps_info->heading);
}

VALUE gps_velocity(VALUE self) {
  GpsInfo *gps_info = device_type_info(self);

  return DBL2NUM(gps_info->velocity);
}

VALUE gps_is_fixed(VALUE self) {
  GpsInfo *gps_info = device_type_info(self);

  return (gps_info->is_fixed) ? Qtrue : Qfalse;
}

/*
 * TODO:
int 	CPhidgetGPS_getTime (CPhidgetGPSHandle phid, GPSTime *time)
int 	CPhidgetGPS_getDate (CPhidgetGPSHandle phid, GPSDate *date)
*/
