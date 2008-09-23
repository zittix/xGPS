/* $Id: nmea_parse.c 4629 2007-12-26 02:16:05Z ckuethe $ */
#include <sys/types.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <time.h>
#include "gps.h"
#include <time.h>
#include <sys/time.h>
#include <termios.h>
#define MONTHSPERYEAR	12		/* months per calendar year */
//#define DEBUG_PARSE
time_t mkgmtime(register struct tm *t)
/* struct tm to seconds since Unix epoch */
{
	register int year;
	register time_t result;
	static const int cumdays[MONTHSPERYEAR] = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };

	/*@ +matchanyintegral @*/
	year = 1900 + t->tm_year + t->tm_mon / MONTHSPERYEAR;
	result = (year - 1970) * 365 + cumdays[t->tm_mon % MONTHSPERYEAR];
	result += (year - 1968) / 4;
	result -= (year - 1900) / 100;
	result += (year - 1600) / 400;
	if ((year % 4) == 0 && ((year % 100) != 0 || (year % 400) == 0) && (t->tm_mon % MONTHSPERYEAR) < 2) result--;
	result += t->tm_mday - 1;
	result *= 24;
	result += t->tm_hour;
	result *= 60;
	result += t->tm_min;
	result *= 60;
	result += t->tm_sec;
	/*@ -matchanyintegral @*/
	return (result);
}

/**************************************************************************
 *
 * Parser helpers begin here
 *
 **************************************************************************/

static void do_lat_lon(char *field[], struct gps_data_t *out)
/* process a pair of latitude/longitude fields starting at field index BEGIN */
{
	double lat, lon, d, m;
	char str[20], *p;
	int updated = 0;

	if (*(p = field[0]) != '\0') {
		strncpy(str, p, 20);
		(void) sscanf(p, "%lf", &lat);
		m = 100.0 * modf(lat / 100.0, &d);
		lat = d + m / 60.0;
		p = field[1];
		if (*p == 'S') lat = -lat;
		if (out->fix.latitude != lat) out->fix.latitude = lat;
		updated++;
	}
	if (*(p = field[2]) != '\0') {
		strncpy(str, p, 20);
		(void) sscanf(p, "%lf", &lon);
		m = 100.0 * modf(lon / 100.0, &d);
		lon = d + m / 60.0;

		p = field[3];
		if (*p == 'W') lon = -lon;
		if (out->fix.longitude != lon) out->fix.longitude = lon;
		updated++;
	}
}

/**************************************************************************
 *
 * Scary timestamp fudging begins here
 *
 * Four sentences, GGA and GLL and RMC and ZDA, contain timestamps.
 * Timestamps always look like hhmmss.ss, with the trailing .ss part
 * optional.  RMC has a date field, in the format ddmmyy.  ZDA has
 * separate fields for day/month/year, with a 4-digit year.  This
 * means that for RMC we must supply a century and for GGA and GLL we
 * must supply a century, year, and day.  We get the missing data from
 * a previous RMC or ZDA; century in RMC is supplied by a constant if
 * there has been no previous RMC.
 *
 **************************************************************************/

#define DD(s)	((int)((s)[0]-'0')*10+(int)((s)[1]-'0'))

static double bilinear(double x1, double y1, double x2, double y2, double x, double y, double z11, double z12, double z21, double z22) {
	double delta;

	if (y1 == y2 && x1 == x2) return (z11);
	if (y1 == y2 && x1 != x2) return (z22 * (x - x1) + z11 * (x2 - x)) / (x2 - x1);
	if (x1 == x2 && y1 != y2) return (z22 * (y - y1) + z11 * (y2 - y)) / (y2 - y1);

	delta = (y2 - y1) * (x2 - x1);

	return (z22 * (y - y1) * (x - x1) + z12 * (y2 - y) * (x - x1) + z21 * (y - y1) * (x2 - x) + z11 * (y2 - y) * (x2 - x)) / delta;
}

/* return geoid separtion (MSL - WGS84) in meters, given a lat/lot in degrees */
/*@ +charint @*/
double wgs84_separation(double lat, double lon) {
#define GEOID_ROW	19
#define GEOID_COL	37
	const char geoid_delta[GEOID_COL * GEOID_ROW] = {
	/* 90S */-30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30, -30,
			-30, -30, -30, -30, -30, -30, -30, -30, -30, -30,
			/* 80S */-53, -54, -55, -52, -48, -42, -38, -38, -29, -26, -26, -24, -23, -21, -19, -16, -12, -8, -4, -1, 1, 4, 4, 6, 5, 4, 2, -6, -15,
			-24, -33, -40, -48, -50, -53, -52, -53,
			/* 70S */-61, -60, -61, -55, -49, -44, -38, -31, -25, -16, -6, 1, 4, 5, 4, 2, 6, 12, 16, 16, 17, 21, 20, 26, 26, 22, 16, 10, -1, -16,
			-29, -36, -46, -55, -54, -59, -61,
			/* 60S */-45, -43, -37, -32, -30, -26, -23, -22, -16, -10, -2, 10, 20, 20, 21, 24, 22, 17, 16, 19, 25, 30, 35, 35, 33, 30, 27, 10, -2,
			-14, -23, -30, -33, -29, -35, -43, -45,
			/* 50S */-15, -18, -18, -16, -17, -15, -10, -10, -8, -2, 6, 14, 13, 3, 3, 10, 20, 27, 25, 26, 34, 39, 45, 45, 38, 39, 28, 13, -1, -15,
			-22, -22, -18, -15, -14, -10, -15,
			/* 40S */21, 6, 1, -7, -12, -12, -12, -10, -7, -1, 8, 23, 15, -2, -6, 6, 21, 24, 18, 26, 31, 33, 39, 41, 30, 24, 13, -2, -20, -32, -33,
			-27, -14, -2, 5, 20, 21,
			/* 30S */46, 22, 5, -2, -8, -13, -10, -7, -4, 1, 9, 32, 16, 4, -8, 4, 12, 15, 22, 27, 34, 29, 14, 15, 15, 7, -9, -25, -37, -39, -23, -14,
			15, 33, 34, 45, 46,
			/* 20S */51, 27, 10, 0, -9, -11, -5, -2, -3, -1, 9, 35, 20, -5, -6, -5, 0, 13, 17, 23, 21, 8, -9, -10, -11, -20, -40, -47, -45, -25, 5,
			23, 45, 58, 57, 63, 51,
			/* 10S */36, 22, 11, 6, -1, -8, -10, -8, -11, -9, 1, 32, 4, -18, -13, -9, 4, 14, 12, 13, -2, -14, -25, -32, -38, -60, -75, -63, -26, 0,
			35, 52, 68, 76, 64, 52, 36,
			/* 00N */22, 16, 17, 13, 1, -12, -23, -20, -14, -3, 14, 10, -15, -27, -18, 3, 12, 20, 18, 12, -13, -9, -28, -49, -62, -89, -102, -63, -9,
			33, 58, 73, 74, 63, 50, 32, 22,
			/* 10N */13, 12, 11, 2, -11, -28, -38, -29, -10, 3, 1, -11, -41, -42, -16, 3, 17, 33, 22, 23, 2, -3, -7, -36, -59, -90, -95, -63, -24,
			12, 53, 60, 58, 46, 36, 26, 13,
			/* 20N */5, 10, 7, -7, -23, -39, -47, -34, -9, -10, -20, -45, -48, -32, -9, 17, 25, 31, 31, 26, 15, 6, 1, -29, -44, -61, -67, -59, -36,
			-11, 21, 39, 49, 39, 22, 10, 5,
			/* 30N */-7, -5, -8, -15, -28, -40, -42, -29, -22, -26, -32, -51, -40, -17, 17, 31, 34, 44, 36, 28, 29, 17, 12, -20, -15, -40, -33, -34,
			-34, -28, 7, 29, 43, 20, 4, -6, -7,
			/* 40N */-12, -10, -13, -20, -31, -34, -21, -16, -26, -34, -33, -35, -26, 2, 33, 59, 52, 51, 52, 48, 35, 40, 33, -9, -28, -39, -48, -59,
			-50, -28, 3, 23, 37, 18, -1, -11, -12,
			/* 50N */-8, 8, 8, 1, -11, -19, -16, -18, -22, -35, -40, -26, -12, 24, 45, 63, 62, 59, 47, 48, 42, 28, 12, -10, -19, -33, -43, -42, -43,
			-29, -2, 17, 23, 22, 6, 2, -8,
			/* 60N */2, 9, 17, 10, 13, 1, -14, -30, -39, -46, -42, -21, 6, 29, 49, 65, 60, 57, 47, 41, 21, 18, 14, 7, -3, -22, -29, -32, -32, -26,
			-15, -2, 13, 17, 19, 6, 2,
			/* 70N */2, 2, 1, -1, -3, -7, -14, -24, -27, -25, -19, 3, 24, 37, 47, 60, 61, 58, 51, 43, 29, 20, 12, 5, -2, -10, -14, -12, -10, -14,
			-12, -6, -2, 3, 6, 4, 2,
			/* 80N */3, 1, -2, -3, -3, -3, -1, 3, 1, 5, 9, 11, 19, 27, 31, 34, 33, 34, 33, 34, 28, 23, 17, 13, 9, 4, 4, 1, -2, -2, 0, 2, 3, 2, 1, 1,
			3,
			/* 90N */13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
			13, 13, 13, 13, 13 };
	/*@ -charint @*/
	int ilat, ilon;
	int ilat1, ilat2, ilon1, ilon2;

	ilat = (int) floor((90. + lat) / 10);
	ilon = (int) floor((180. + lon) / 10);

	/* sanity checks to prevent segfault on bad data */
	if ((ilat > 90) || (ilat < -90)) {
		return 0.0;
	}
	if ((ilon > 180) || (ilon < -180)) {
		return 0.0;
	}

	ilat1 = ilat;
	ilon1 = ilon;
	ilat2 = (ilat < GEOID_ROW - 1) ? ilat + 1 : ilat;
	ilon2 = (ilon < GEOID_COL - 1) ? ilon + 1 : ilon;

	return bilinear(ilon1 * 10. - 180., ilat1 * 10. - 90., ilon2 * 10. - 180., ilat2 * 10. - 90., lon, lat, (double) geoid_delta[ilon1 + ilat1
			* GEOID_COL], (double) geoid_delta[ilon2 + ilat1 * GEOID_COL], (double) geoid_delta[ilon1 + ilat2 * GEOID_COL],
			(double) geoid_delta[ilon2 + ilat2 * GEOID_COL]);
}

static void merge_ddmmyy(char *ddmmyy, struct gps_data_t *out)
/* sentence supplied ddmmyy, but no century part */
{
	if (out->nmea.date.tm_year == 0) out->nmea.date.tm_year = (CENTURY_BASE + DD(ddmmyy+4)) - 1900;
	out->nmea.date.tm_mon = DD(ddmmyy+2) - 1;
	out->nmea.date.tm_mday = DD(ddmmyy);
}

static void merge_hhmmss(char *hhmmss, struct gps_data_t *out)
/* update from a UTC time */
{
	int old_hour = out->nmea.date.tm_hour;

	out->nmea.date.tm_hour = DD(hhmmss);
	if (out->nmea.date.tm_hour < old_hour) /* midnight wrap */
	out->nmea.date.tm_mday++;
	out->nmea.date.tm_min = DD(hhmmss+2);
	out->nmea.date.tm_sec = DD(hhmmss+4);
	out->nmea.subseconds = atof(hhmmss + 4) - out->nmea.date.tm_sec;
}

#undef DD

/**************************************************************************
 *
 * Compare GPS timestamps for equality.  Depends on the fact that the
 * timestamp granularity of GPS is 1/100th of a second.  Use this to avoid
 * naive float comparisons.
 *
 **************************************************************************/

#define GPS_TIME_EQUAL(a, b) (fabs((a) - (b)) < 0.01)

/**************************************************************************
 *
 * NMEA sentence handling begins here
 *
 **************************************************************************/

static gps_mask_t processGPRMC(int count, char *field[], struct gps_data_t *out)
/* Recommend Minimum Course Specific GPS/TRANSIT Data */
{
	/*
	 RMC,225446.33,A,4916.45,N,12311.12,W,000.5,054.7,191194,020.3,E,A*68
	 1     225446.33    Time of fix 22:54:46 UTC
	 2     A	    Status of Fix A = Autonomous, valid; D = Differential, valid; V = invalid
	 3,4   4916.45,N    Latitude 49 deg. 16.45 min North
	 5,6   12311.12,W   Longitude 123 deg. 11.12 min West
	 7     000.5	Speed over ground, Knots
	 8     054.7	Course Made Good, True north
	 9     191194       Date of fix  19 November 1994
	 10,11 020.3,E      Magnetic variation 20.3 deg East
	 12    A	    FAA mode indicator (NMEA 2.3 and later)
	 A=autonomous, D=differential, E=Estimated,
	 N=not valid, S=Simulator, M=Manual input mode
	 *68	  mandatory nmea_checksum

	 * SiRF chipsets don't return either Mode Indicator or magnetic variation.
	 */
	gps_mask_t mask = 0;

	if (strcmp(field[2], "V") == 0) {
		/* copes with Magellan EC-10X, see below */
		if (out->status != STATUS_NO_FIX) {
			out->status = STATUS_NO_FIX;
			mask |= STATUS_SET;
		}
		if (out->fix.mode >= MODE_2D) {
			out->fix.mode = MODE_NO_FIX;
			mask |= MODE_SET;
		}
		/* set something nz, so it won't look like an unknown sentence */
		mask |= ONLINE_SET;
	} else if (strcmp(field[2], "A") == 0) {
		if (count > 9) {
			merge_ddmmyy(field[9], out);
			merge_hhmmss(field[1], out);
			mask |= TIME_SET;
			out->fix.time = (double) mkgmtime(&out->nmea.date) + out->nmea.subseconds;
			if (!GPS_TIME_EQUAL(out->sentence_time, out->fix.time)) {
				mask |= CYCLE_START_SET;
				//gpsd_report(LOG_PROG, "GPRMC starts a reporting cycle.\n");
			}
			out->sentence_time = out->fix.time;
		}
		do_lat_lon(&field[3], out);
		mask |= LATLON_SET;
		out->fix.speed = atof(field[7]) * KNOTS_TO_MPS;
		out->fix.track = atof(field[8]);
		mask |= (TRACK_SET | SPEED_SET);
		/*
		 * This copes with GPSes like the Magellan EC-10X that *only* emit
		 * GPRMC. In this case we set mode and status here so the client
		 * code that relies on them won't mistakenly believe it has never
		 * received a fix.
		 */
		if (out->status == STATUS_NO_FIX) {
			out->status = STATUS_FIX; /* could be DGPS_FIX, we can't tell */
			mask |= STATUS_SET;
		}
		if (out->fix.mode < MODE_2D) {
			out->fix.mode = MODE_2D;
			mask |= MODE_SET;
		}
	}
#ifdef DEBUG_PARSE
	printf("GPRMC parsed\n");
#endif
	//gpsd_report(LOG_PROG, "GPRMC sets mode %d\n", out->fix.mode);
	return mask;
}

static gps_mask_t processGPGLL(int count, char *field[], struct gps_data_t *out)
/* Geographic position - Latitude, Longitude */
{
	/* Introduced in NMEA 3.0.  Here are the fields:
	 *
	 * 1,2 Latitude, N (North) or S (South)
	 * 3,4 Longitude, E (East) or W (West)
	 * 5 UTC of position
	 * 6 A=Active, V=Void
	 * 7 Mode Indicator
	 *   A = Autonomous mode
	 *   D = Differential Mode
	 *   E = Estimated (dead-reckoning) mode
	 *   M = Manual Input Mode
	 *   S = Simulated Mode
	 *   N = Data Not Valid
	 *
	 * I found a note at <http://www.secoh.ru/windows/gps/nmfqexep.txt>
	 * indicating that the Garmin 65 does not return time and status.
	 * SiRF chipsets don't return the Mode Indicator.
	 * This code copes gracefully with both quirks.
	 *
	 * Unless you care about the FAA indicator, this sentence supplies nothing
	 * that GPRMC doesn't already.  But at least one Garmin GPS -- the 48
	 * actually ships updates in GPLL that aren't redundant.
	 */
	char *status = field[7];
	gps_mask_t mask = ERROR_SET;

	if (strcmp(field[6], "A") == 0 && (count < 8 || *status != 'N')) {
		int newstatus = out->status;

		mask = 0;
		merge_hhmmss(field[5], out);
		if (out->nmea.date.tm_year == 0) {
			//gpsd_report(LOG_WARN, "can't use GGL time until after ZDA or RMC has supplied a year.\n");
		} else {
			mask = TIME_SET;
			out->fix.time = (double) mkgmtime(&out->nmea.date) + out->nmea.subseconds;
			if (!GPS_TIME_EQUAL(out->sentence_time, out->fix.time)) {
				mask |= CYCLE_START_SET;
				//gpsd_report(LOG_PROG, "GPGLL starts a reporting cycle.\n");
			}
			out->sentence_time = out->fix.time;
		}
		do_lat_lon(&field[1], out);
		mask |= LATLON_SET;
		if (count >= 8 && *status == 'D')
			newstatus = STATUS_DGPS_FIX; /* differential */
		else
			newstatus = STATUS_FIX;
		/*
		 * This is a bit dodgy.  Technically we shouldn't set the mode
		 * bit until we see GSA.  But it may be later in the cycle,
		 * some devices like the FV-18 don't send it by default, and
		 * elsewhere in the code we want to be able to test for the
		 * presence of a valid fix with mode > MODE_NO_FIX.
		 */
		if (out->fix.mode < MODE_2D) {
			out->fix.mode = MODE_2D;
			mask |= MODE_SET;
		}
		out->status = newstatus;
		mask |= STATUS_SET;
		//gpsd_report(LOG_PROG, "GPGLL sets status %d\n", out->status);
	}

	return mask;
}

static gps_mask_t processGPGGA(int c UNUSED, char *field[], struct gps_data_t *out)
/* Global Positioning System Fix Data */
{
	/*
	 GGA,123519,4807.038,N,01131.324,E,1,08,0.9,545.4,M,46.9,M, , *42
	 123519       Fix taken at 12:35:19 UTC
	 4807.038,N   Latitude 48 deg 07.038' N
	 01131.324,E  Longitude 11 deg 31.324' E
	 1	    Fix quality: 0 = invalid, 1 = GPS fix, 2 = DGPS fix,
	 3=PPS (Precise Position Service),
	 4=RTK (Real Time Kinematic) with fixed integers,
	 5=Float RTK, 6=Estimated, 7=Manual, 8=Simulator
	 08	   Number of satellites being tracked
	 0.9	  Horizontal dilution of position
	 545.4,M      Altitude, Metres above mean sea level
	 46.9,M       Height of geoid (mean sea level) above WGS84
	 ellipsoid, in Meters
	 (empty field) time in seconds since last DGPS update
	 (empty field) DGPS station ID number (0000-1023)
	 */
	gps_mask_t mask;

	out->status = atoi(field[6]);
	mask = STATUS_SET;
	if (out->status > STATUS_NO_FIX) {
		char *altitude;
		double oldfixtime = out->fix.time;

		merge_hhmmss(field[1], out);
		if (out->nmea.date.tm_year == 0) {
			//gpsd_report(LOG_WARN, "can't use GGA time until after ZDA or RMC has supplied a year.\n");
		} else {
			mask |= TIME_SET;
			out->fix.time = (double) mkgmtime(&out->nmea.date) + out->nmea.subseconds;
			if (!GPS_TIME_EQUAL(out->sentence_time, out->fix.time)) {
				mask |= CYCLE_START_SET;
				//gpsd_report(LOG_PROG, "GPGGA starts a reporting cycle.\n");
			}
			out->sentence_time = out->fix.time;
		}
		do_lat_lon(&field[2], out);
		mask |= LATLON_SET;
		out->satellites_used = atoi(field[7]);
		altitude = field[9];
		/*
		 * SiRF chipsets up to version 2.2 report a null altitude field.
		 * See <http://www.sirf.com/Downloads/Technical/apnt0033.pdf>.
		 * If we see this, force mode to 2D at most.
		 */
		if (altitude[0] == '\0') {
			if (out->fix.mode == MODE_3D) {
				out->fix.mode = out->status ? MODE_2D : MODE_NO_FIX;
				mask |= MODE_SET;
			}
		} else {
			double oldaltitude = out->fix.altitude;

			out->fix.altitude = atof(altitude);
			mask |= ALTITUDE_SET;
			/*
			 * This is a bit dodgy.  Technically we shouldn't set the mode
			 * bit until we see GSA.  But it may be later in the cycle,
			 * some devices like the FV-18 don't send it by default, and
			 * elsewhere in the code we want to be able to test for the
			 * presence of a valid fix with mode > MODE_NO_FIX.
			 */
			if (out->fix.mode < MODE_3D) {
				out->fix.mode = MODE_3D;
				mask |= MODE_SET;
			}

			/*
			 * Compute climb/sink in the simplest possible way.
			 * This substitutes for the climb report provided by
			 * SiRF and Garmin chips, which might have some smoothing
			 * going on.
			 */
			if (isnan(oldaltitude) != 0 || out->fix.time == oldfixtime)
				out->fix.climb = 0;
			else {
				out->fix.climb = (out->fix.altitude - oldaltitude) / (out->fix.time - oldfixtime);
			}
			mask |= CLIMB_SET;
		}
		if (strlen(field[11]) > 0) {
			out->separation = atof(field[11]);
		} else {
			out->separation = wgs84_separation(out->fix.latitude, out->fix.longitude);
		}
	}
#ifdef DEBUG_PARSE
	printf("GPGGA parsed\n");
#endif
	//gpsd_report(LOG_PROG, "GPGGA sets status %d and mode %d (%s)\n", out->status, out->fix.mode, ((mask&MODE_SET)!=0) ? "changed" : "unchanged");
	return mask;
}

static gps_mask_t processGPGSA(int count, char *field[], struct gps_data_t *out)
/* GPS DOP and Active Satellites */
{
	/*
	 eg1. $GPGSA,A,3,,,,,,16,18,,22,24,,,3.6,2.1,2.2*3C
	 eg2. $GPGSA,A,3,19,28,14,18,27,22,31,39,,,,,1.7,1.0,1.3*35
	 1    = Mode:
	 M=Manual, forced to operate in 2D or 3D
	 A=Automatic, 3D/2D
	 2    = Mode: 1=Fix not available, 2=2D, 3=3D
	 3-14 = PRNs of satellites used in position fix (null for unused fields)
	 15   = PDOP
	 16   = HDOP
	 17   = VDOP
	 */
	gps_mask_t mask;
	int i;

	/*
	 * One chipset called the i.Trek M3 issues GPGSA lines that look like
	 * this: "$GPGSA,A,1,,,,*32" when it has no fix.  This is broken
	 * in at least two ways: it's got the wrong number of fields, and
	 * it claims to be a valid sentence (A flag) when it isn't.
	 * Alarmingly, it's possible this error may be generic to SiRFstarIII.
	 */
	if (count < 17) return ONLINE_SET;

	out->fix.mode = atoi(field[2]);
	/*
	 * The first arm of this conditional ignores dead-reckoning
	 * fixes from an Antaris chipset. which returns E in field 2
	 * for a dead-reckoning estimate.  Fix by Andreas Stricker.
	 */
	if (out->fix.mode == 0 && field[2][0] == 'E')
		mask = 0;
	else
		mask = MODE_SET;
	//gpsd_report(LOG_PROG, "GPGSA sets mode %d\n", out->fix.mode);
	out->pdop = atof(field[count - 3]);
	out->hdop = atof(field[count - 2]);
	out->vdop = atof(field[count - 1]);
	out->satellites_used = 0;
	memset(out->used, 0, sizeof(out->used));
	/* the magic 6 here counts the tag, two mode fields, and the DOP fields */
	for (i = 0; i < count - 6; i++) {
		int prn = atoi(field[i + 3]);
		if (prn > 0) out->used[out->satellites_used++] = prn;
	}
	mask |= HDOP_SET | VDOP_SET | PDOP_SET | USED_SET;

	return mask;
}
static void gpsd_zero_satellites(/*@out@*/struct gps_data_t *out) {
	(void) memset(out->PRN, 0, sizeof(out->PRN));
	(void) memset(out->elevation, 0, sizeof(out->elevation));
	(void) memset(out->azimuth, 0, sizeof(out->azimuth));
	(void) memset(out->ss, 0, sizeof(out->ss));
	out->satellites = 0;
}
static gps_mask_t processGPGSV(int count, char *field[], struct gps_data_t *out)
/* GPS Satellites in View */
{
	/*
	 GSV,2,1,08,01,40,083,46,02,17,308,41,12,07,344,39,14,22,228,45*75
	 2	    Number of sentences for full data
	 1	    sentence 1 of 2
	 08	   Total number of satellites in view
	 01	   Satellite PRN number
	 40	   Elevation, degrees
	 083	  Azimuth, degrees
	 46	   Signal-to-noise ratio in decibels
	 <repeat for up to 4 satellites per sentence>
	 There my be up to three GSV sentences in a data packet
	 */
	int n, fldnum;
	if (count <= 3) {
		gpsd_zero_satellites(out);
		out->satellites = 0;
		return ERROR_SET;
	}
	if (count % 4 != 3) {
		//gpsd_report(LOG_WARN, "malformed GPGSV - fieldcount %d %% 4 != 3\n", count);
		gpsd_zero_satellites(out);
		out->satellites = 0;
		return ERROR_SET;
	}

	out->nmea.await = atoi(field[1]);
	if (sscanf(field[2], "%d", &out->nmea.part) < 1) {
		gpsd_zero_satellites(out);
		return ERROR_SET;
	} else if (out->nmea.part == 1) gpsd_zero_satellites(out);

	for (fldnum = 4; fldnum < count;) {
		if (out->satellites >= MAXCHANNELS) {
			//gpsd_report(LOG_ERROR, "internal error - too many satellites!\n");
			gpsd_zero_satellites(out);
			break;
		}
		out->PRN[out->satellites] = atoi(field[fldnum++]);
		out->elevation[out->satellites] = atoi(field[fldnum++]);
		out->azimuth[out->satellites] = atoi(field[fldnum++]);
		out->ss[out->satellites] = atoi(field[fldnum++]);
		/*
		 * Incrementing this unconditionally falls afoul of chipsets like
		 * the Motorola Oncore GT+ that emit empty fields at the end of the
		 * last sentence in a GPGSV set if the number of satellites is not
		 * a multiple of 4.
		 */
		if (out->PRN[out->satellites] != 0) out->satellites++;
	}
	if (out->nmea.part == out->nmea.await && atoi(field[3]) != out->satellites) {
		//	gpsd_report(LOG_WARN,
		//	"GPGSV field 3 value of %d != actual count %d\n", atoi(field[3]), out->satellites);
	}
	/* not valid data until we've seen a complete set of parts */
	if (out->nmea.part < out->nmea.await) {
		//gpsd_report(LOG_PROG, "Partial satellite data (%d of %d).\n", out->nmea.part, out->nmea.await);
		return ERROR_SET;
	}
	/*
	 * This sanity check catches an odd behavior of SiRFstarII receivers.
	 * When they can't see any satellites at all (like, inside a
	 * building) they sometimes cough up a hairball in the form of a
	 * GSV packet with all the azimuth entries 0 (but nonzero
	 * elevations).  This behavior was observed under SiRF firmware
	 * revision 231.000.000_A2.
	 */
	for (n = 0; n < out->satellites; n++)
		if (out->azimuth[n] != 0) goto sane;
	//gpsd_report(LOG_WARN, "Satellite data no good (%d of %d).\n", out->nmea.part, out->nmea.await);
	gpsd_zero_satellites(out);
	return ERROR_SET;
	sane: //gpsd_report(LOG_PROG, "Satellite data OK (%d of %d).\n", out->nmea.part, out->nmea.await);
	return SATELLITE_SET;
}

static gps_mask_t processPGRME(int c UNUSED, char *field[], struct gps_data_t *out)
/* Garmin Estimated Position Error */
{
	/*
	 $PGRME,15.0,M,45.0,M,25.0,M*22
	 1    = horizontal error estimate
	 2    = units
	 3    = vertical error estimate
	 4    = units
	 5    = spherical error estimate
	 6    = units
	 *
	 * Garmin won't say, but the general belief is that these are 50% CEP.
	 * We follow the advice at <http://gpsinformation.net/main/errors.htm>.
	 * If this assumption changes here, it should also change in garmin.c
	 * where we scale error estimates from Garmin binary packets.
	 */
	if ((strcmp(field[2], "M") != 0) || (strcmp(field[4], "M") != 0) || (strcmp(field[6], "M") != 0)) {
		out->fix.eph = out->fix.epv = out->epe = 100;
		return ERROR_SET;
	}

	out->fix.eph = atof(field[1]) * (GPSD_CONFIDENCE / CEP50_SIGMA);
	out->fix.epv = atof(field[3]) * (GPSD_CONFIDENCE / CEP50_SIGMA);
	out->epe = atof(field[5]) * (GPSD_CONFIDENCE / CEP50_SIGMA);

	return HERR_SET | VERR_SET | PERR_SET;
}

static gps_mask_t processGPZDA(int c UNUSED, char *field[], struct gps_data_t *out)
/* Time & Date */
{
	gps_mask_t mask = TIME_SET;
	/*
	 $GPZDA,160012.71,11,03,2004,-1,00*7D
	 1) UTC time (hours, minutes, seconds, may have fractional subsecond)
	 2) Day, 01 to 31
	 3) Month, 01 to 12
	 4) Year (4 digits)
	 5) Local zone description, 00 to +- 13 hours
	 6) Local zone minutes description, apply same sign as local hours
	 7) Checksum
	 */
	merge_hhmmss(field[1], out);
	out->nmea.date.tm_year = atoi(field[4]) - 1900;
	out->nmea.date.tm_mon = atoi(field[3]) - 1;
	out->nmea.date.tm_mday = atoi(field[2]);
	out->fix.time = (double) mkgmtime(&out->nmea.date) + out->nmea.subseconds;
	if (!GPS_TIME_EQUAL(out->sentence_time, out->fix.time)) {
		mask |= CYCLE_START_SET;
		//gpsd_report(LOG_PROG, "GPZDA starts a reporting cycle.\n");
	}
	out->sentence_time = out-> fix.time;
	return mask;
}

#ifdef __UNUSED__
static short nmea_checksum(char *sentence, unsigned char *correct_sum)
/* is the checksum on the specified sentence good? */
{
	unsigned char sum = '\0';
	char c, *p = sentence, csum[3];

	while ((c = *p++) != '*' && c != '\0')
	sum ^= c;
	if (correct_sum)
	*correct_sum = sum;
	(void)snprintf(csum, sizeof(csum), "%02X", sum);
	return(csum[0]==toupper(p[0])) && (csum[1]==toupper(p[1]));
}
#endif /* __ UNUSED__ */

/**************************************************************************
 *
 * Entry points begin here
 *
 **************************************************************************/

gps_mask_t nmea_parse(char *sentence, struct gps_data_t *out)
/* parse an NMEA sentence, unpack it into a session structure */
{
	typedef gps_mask_t (*nmea_decoder)(int count, char *f[], struct gps_data_t *out);
	static struct {
		char *name;
		int nf; /* minimum number of fields required to parse */
		nmea_decoder decoder;
	} nmea_phrase[] = { { "RMC", 8, processGPRMC }, { "GGA", 13, processGPGGA }, { "GLL", 7, processGPGLL }, { "GSA", 17, processGPGSA }, { "GSV", 0,
			processGPGSV }, { "VTG", 0, NULL }, /* ignore Velocity Track made Good */
	{ "ZDA", 7, processGPZDA }, { "PGRMC", 0, NULL }, /* ignore Garmin Sensor Config */
	{ "PGRME", 7, processPGRME }, { "PGRMI", 0, NULL }, /* ignore Garmin Sensor Init */
	{ "PGRMO", 0, NULL }, /* ignore Garmin Sentence Enable */
	};
	volatile unsigned char buf[NMEA_MAX + 1];

	int count;
	gps_mask_t retval = 0;
	unsigned int i;
	char *p, *field[NMEA_MAX], *s;
#ifndef USE_OLD_SPLIT
	volatile char *t;
#endif
#ifdef __UNUSED__
	unsigned char sum;

	if (!nmea_checksum(sentence+1, &sum)) {
		gpsd_report(LOG_ERROR, "Bad NMEA checksum: '%s' should be %02X\n",
				sentence, sum);
		return 0;
	}
#endif /* __ UNUSED__ */

	/*
	 * We've had reports that on the Garmin GPS-10 the device sometimes
	 * (1:1000 or so) sends garbage packets that have a valid checksum
	 * but are like 2 successive NMEA packets merged together in one
	 * with some fields lost.  Usually these are much longer than the
	 * legal limit for NMEA, so we can cope by just tossing out overlong
	 * packets.  This may be a generic bug of all Garmin chipsets.
	 */
	if (strlen(sentence) > NMEA_MAX) {
		//gpsd_report(LOG_WARN, "Overlong packet rejected.\n");
		return ONLINE_SET;
	}

#ifdef BREAK_REGRESSIONS
	/* trim trailing CR/LF */
	for (i = 0; i < strlen(sentence); i++)
	if ((sentence[i] == '\r') || (sentence[i] == '\n')) {
		sentence[i] = '\0';
		break;
	}
#endif
	/*@ -usedef @*//* splint 3.1.1 seems to have a bug here */
	/* make an editable copy of the sentence */
	strncpy((char *) buf, sentence, NMEA_MAX);
	/* discard the checksum part */
	for (p = (char *) buf; (*p != '*') && (*p >= ' ');)
		++p;
	*p = '\0';
	/* split sentence copy on commas, filling the field array */
#ifdef USE_OLD_SPLIT
	for (count = 0, p = (char *)buf; p != NULL && *p != '\0'; ++count, p = strchr(p, ',')) {
		*p = '\0';
		field[count] = ++p;
	}
#else
	count = 0;
	t = p; /* end of sentence */
	p = (char *) buf + 1; /* beginning of tag, 'G' not '$' */
	/* while there is a search string and we haven't run off the buffer... */
	while ((p != NULL) && (p <= t)) {
		field[count] = p; /* we have a field. record it */
		/*@ -compdef @*/
		if ((p = strchr(p, ',')) != NULL) { /* search for the next delimiter */
			*p = '\0'; /* replace it with a NUL */
			count++; /* bump the counters and continue */
			p++;
		}
		/*@ +compdef @*/
	}
#endif
	/* dispatch on field zero, the sentence tag */
	for (i = 0; i < (unsigned) (sizeof(nmea_phrase) / sizeof(nmea_phrase[0])); ++i) {
		s = field[0];
		if (strlen(nmea_phrase[i].name) == 3) s += 2; /* skip talker ID */
		if (strcmp(nmea_phrase[i].name, s) == 0) {
			if (nmea_phrase[i].decoder != NULL && (count >= nmea_phrase[i].nf)) {
				retval = (nmea_phrase[i].decoder)(count, field, out);
				strncpy(out->tag, nmea_phrase[i].name, MAXTAGLEN);
				out->sentence_length = strlen(sentence);
			} else
				retval = ONLINE_SET; /* unknown sentence */
			break;
		}
	}
	/*@ +usedef @*/
	return retval;
}

void nmea_add_checksum(char *sentence)
/* add NMEA checksum to a possibly  *-terminated sentence */
{
	unsigned char sum = '\0';
	char c, *p = sentence;

	if (*p == '$') {
		p++;
	} else {
		//gpsd_report(LOG_ERROR, "Bad NMEA sentence: '%s'\n", sentence);
	}
	while (((c = *p) != '*') && (c != '\0')) {
		sum ^= c;
		p++;
	}
	*p++ = '*';
	(void) snprintf(p, 5, "%02X\r\n", (unsigned) sum);
}

int nmea_send(int fd, const char *fmt, ...)
/* ship a command to the GPS, adding * and correct checksum */
{
	int status;
	char buf[BUFSIZ];
	va_list ap;

	va_start(ap, fmt);
	(void) vsnprintf(buf, sizeof(buf) - 5, fmt, ap);
	va_end(ap);
	if (fmt[0] == '$') {
		(void) strlcat(buf, "*", BUFSIZ);
		nmea_add_checksum(buf);
	} else
		(void) strlcat(buf, "\r\n", BUFSIZ);
	status = (int) write(fd, buf, strlen(buf));
	(void) tcdrain(fd);
	if (status == (int) strlen(buf)) {
		//gpsd_report(LOG_IO, "=> GPS: %s\n", buf);
		return status;
	} else {
		//gpsd_report(LOG_WARN, "=> GPS: %s FAILED\n", buf);
		return -1;
	}
}