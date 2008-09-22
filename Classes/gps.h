/*
 * gps.h
 *
 *  Created on: 10 août 2008
 *      Author: mathieu
 */

#ifndef GPS_H_
#define GPS_H_

#include <sys/types.h>
#include <sys/time.h>
#include <stdbool.h>
#include <inttypes.h>	/* stdint.h would be smaller but not all have it */
#include <limits.h>
#include <time.h>
#include <signal.h>
#ifndef S_SPLINT_S
#include <pthread.h>	/* pacifies OpenBSD's compiler */
#endif
#include "timebase.h"
#define MAXTAGLEN	8	/* maximum length of sentence tag name */
#define MAXCHANNELS	20	/* maximum GPS channels (*not* satellites!) */
#define SIRF_CHANNELS	12	/* max channels allowed in SiRF format */
#define GPS_PRNMAX	32	/* above this number are SBAS satellites */
#undef PATH_MAX
#define PATH_MAX 255
#define UNUSED
/*
 * The structure describing an uncertainty volume in kinematic space.
 * This is what GPSes are meant to produce; all the other info is
 * technical impedimenta.
 *
 * All double values use NAN to indicate data not available.
 *
 * Usually all the information in this structure was considered valid
 * by the GPS at the time of update.  This will be so if you are using
 * a GPS chipset that speaks SiRF binary, Garmin binary, or Zodiac binary.
 * This covers over 80% of GPS products in early 2005.
 *
 * If you are using a chipset that speaks NMEA, this structure is updated
 * in bits by GPRMC (lat/lon, track, speed), GPGGA (alt, climb), GPGLL
 * (lat/lon), and GPGSA (eph, epv).  Most NMEA GPSes take a single fix
 * at the beginning of a 1-second cycle and report the same timestamp in
 * GPRMC, GPGGA, and GPGLL; for these, all info is guaranteed correctly
 * synced to the time member, but you'll get different stages of the same
 * update depending on where in the cycle you poll.  A very few GPSes,
 * like the Garmin 48, take a new fix before more than one of of
 * GPRMC/GPGGA/GPGLL during a single cycle; thus, they may have different
 * timestamps and some data in this structure can be up to 1 cycle (usually
 * 1 second) older than the fix time.
 *
 * Error estimates are at 95% confidence.
 */
struct gps_fix_t {
	double time; /* Time of update, seconds since Unix epoch */
	int mode; /* Mode of fix */
#define MODE_NOT_SEEN	0	/* mode update not seen yet */
#define MODE_NO_FIX	1	/* none */
#define MODE_2D  	2	/* good for latitude/longitude */
#define MODE_3D  	3	/* good for altitude/climb too */
	double ept; /* Expected time uncertainty */
	double latitude; /* Latitude in degrees (valid if mode >= 2) */
	double longitude; /* Longitude in degrees (valid if mode >= 2) */
	double eph; /* Horizontal position uncertainty, meters */
	double altitude; /* Altitude in meters (valid if mode == 3) */
	double epv; /* Vertical position uncertainty, meters */
	double track; /* Course made good (relative to true north) */
	double epd; /* Track uncertainty, degrees */
	double speed; /* Speed over ground, meters/sec */
	double eps; /* Speed uncertainty, meters/sec */
	double climb; /* Vertical speed, meters/sec */
	double epc; /* Vertical speed uncertainty */
};

typedef /*@unsignedintegraltype@*/unsigned int gps_mask_t;

struct gps_data_t {
	gps_mask_t set; /* has field been set since this was last cleared? */
#define ONLINE_SET	0x00000001u
#define TIME_SET	0x00000002u
#define TIMERR_SET	0x00000004u
#define LATLON_SET	0x00000008u
#define ALTITUDE_SET	0x00000010u
#define SPEED_SET	0x00000020u
#define TRACK_SET	0x00000040u
#define CLIMB_SET	0x00000080u
#define STATUS_SET	0x00000100u
#define MODE_SET	0x00000200u
#define HDOP_SET  	0x00000400u
#define VDOP_SET  	0x00000800u
#define PDOP_SET  	0x00001000u
#define TDOP_SET	0x00002000u
#define GDOP_SET	0x00004000u
#define DOP_SET		(HDOP_SET|VDOP_SET|PDOP_SET|TDOP_SET|GDOP_SET)
#define HERR_SET	0x00008000u
#define VERR_SET	0x00010000u
#define PERR_SET	0x00020000u
#define ERR_SET		(HERR_SET | VERR_SET | PERR_SET)
#define SATELLITE_SET	0x00040000u
#define PSEUDORANGE_SET	0x00080000u
#define USED_SET	0x00100000u
#define SPEEDERR_SET	0x00200000u
#define TRACKERR_SET	0x00400000u
#define CLIMBERR_SET	0x00800000u
#define DEVICE_SET	0x01000000u
#define DEVICELIST_SET	0x02000000u
#define DEVICEID_SET	0x04000000u
#define ERROR_SET	0x08000000u
#define CYCLE_START_SET	0x10000000u
#define RTCM_SET	0x20000000u
#define FIX_SET		(TIME_SET|MODE_SET|TIMERR_SET|LATLON_SET|HERR_SET|ALTITUDE_SET|VERR_SET|TRACK_SET|TRACKERR_SET|SPEED_SET|SPEEDERR_SET|CLIMB_SET|CLIMBERR_SET)
	double online; /* NZ if GPS is on line, 0 if not.
	 *
	 * Note: gpsd clears this flag when sentences
	 * fail to show up within the GPS's normal
	 * send cycle time. If the host-to-GPS
	 * link is lossy enough to drop entire
	 * sentences, this flag will be
	 * prone to false negatives.
	 */

	struct gps_fix_t fix; /* accumulated PVT data */

	double separation; /* Geoidal separation, MSL - WGS84 (Meters) */

	/* GPS status -- always valid */
	int status; /* Do we have a fix? */
#define STATUS_NO_FIX	0	/* no */
#define STATUS_FIX	1	/* yes, without DGPS */
#define STATUS_DGPS_FIX	2	/* yes, with DGPS */

	/* precision of fix -- valid if satellites_used > 0 */
	int satellites_used; /* Number of satellites used in solution */
	int used[MAXCHANNELS]; /* PRNs of satellites used in solution */
	double pdop, hdop, vdop, tdop, gdop; /* Dilution of precision */

	/* redundant with the estimate elments in the fix structure */
	double epe; /* spherical position error, 95% confidence (meters)  */

	/* satellite status -- valid when satellites > 0 */
	int satellites; /* # of satellites in view */
	int PRN[MAXCHANNELS]; /* PRNs of satellite */
	int elevation[MAXCHANNELS]; /* elevation of satellite */
	int azimuth[MAXCHANNELS]; /* azimuth */
	int ss[MAXCHANNELS]; /* signal-to-noise ratio (dB) */

#if 0	/* not yet used or filled in */
	/* measurement data */
	double pseudorange[MAXCHANNELS]; /* meters */
	double deltarange[MAXCHANNELS]; /* meters/sec */
	double doppler[MAXCHANNELS]; /* Hz */
	unsigned satstat[MAXCHANNELS]; /* tracking status */
#define SAT_ACQUIRED	0x01		/* satellite acquired */
#define SAT_CODE_TRACK	0x02		/* code-tracking loop acquired */
#define SAT_CARR_TRACK	0x04		/* carrier-tracking loop acquired */
#define SAT_DATA_SYNC	0x08		/* data-bit synchronization done */
#define SAT_FRAME_SYNC	0x10		/* frame synchronization done */
#define SAT_EPHEMERIS	0x20		/* ephemeris collected */
#define SAT_FIX_USED	0x40		/* used for position fix */
#endif

	/* compass status -- TrueNorth (and any similar) devices only */
	char headingStatus;
	char pitchStatus;
	char rollStatus;
	double horzField; /* Magnitude of horizontal magnetic field */

	/* where and what gpsd thinks the device is */
	char gps_device[PATH_MAX]; /* only valid if non-null. */
	char *gps_id; /* only valid if non-null. */
	unsigned int baudrate, parity, stopbits; /* RS232 link parameters */
	unsigned int driver_mode; /* whether driver is in native mode or not */

	struct {
		int part, await; /* for tracking GSV parts */
		struct tm date;
		double subseconds;
	} nmea;

	/* device list */
	int ndevices; /* count of available devices */
	char **devicelist; /* list of pathnames */

	/* profiling data for last sentence */
	bool profiling; /* profiling enabled? */
	char tag[MAXTAGLEN + 1]; /* tag of last sentence processed */
	size_t sentence_length; /* character count of last sentence */
	double sentence_time; /* sentence timestamp */
	double d_xmit_time; /* beginning of sentence transmission */
	double d_recv_time; /* daemon receipt time (-> E1+T1) */
	double d_decode_time; /* daemon end-of-decode time (-> D1) */
	double poll_time; /* daemon poll time (-> W) */
	double emit_time; /* emission time (-> E2) */
	double c_recv_time; /* client receipt time (-> T2) */
	double c_decode_time; /* client end-of-decode time (-> D2) */
	double cycle, mincycle; /* refresh cycle time in seconds */

	/* these members are private */
	int gps_fd; /* socket or file descriptor to GPS */
	void (*raw_hook)(struct gps_data_t *, char *, size_t len, int level);/* Raw-mode hook for GPS data. */
	void (*thread_hook)(struct gps_data_t *, char *, size_t len, int level);/* Thread-callback hook for GPS data. */

};

/* some multipliers for interpreting GPS output */
#define METERS_TO_FEET	3.2808399	/* Meters to U.S./British feet */
#define METERS_TO_MILES	0.00062137119	/* Meters to miles */
#define KNOTS_TO_MPH	1.1507794	/* Knots to miles per hour */
#define KNOTS_TO_KPH	1.852		/* Knots to kilometers per hour */
#define KNOTS_TO_MPS	0.51444444	/* Knots to meters per second */
#define MPS_TO_KPH	3.6		/* Meters per second to klicks/hr */
#define MPS_TO_MPH	2.2369363	/* Meters/second to miles per hour */
#define MPS_TO_KNOTS	1.9438445	/* Meters per second to knots */
/* miles and knots are both the international standard versions of the units */

/* angle conversion multipliers */
#define PI      	3.1415926535897932384626433832795029
#define RAD_2_DEG	57.2957795130823208767981548141051703
#define DEG_2_RAD	0.0174532925199432957692369076848861271

/* factors for converting among confidence interval units */
#define CEP50_SIGMA	1.18
#define DRMS_SIGMA	1.414
#define CEP95_SIGMA	2.45

/* this is where we choose the confidence level to use in reports */
#define GPSD_CONFIDENCE	CEP95_SIGMA

#define NMEA_MAX	86		/* max length of NMEA sentence */
#define NMEA_BIG_BUF	(2*NMEA_MAX+1)	/* longer than longest NMEA sentence */

gps_mask_t nmea_parse(char *sentence, struct gps_data_t *out);
#endif /* GPS_H_ */
