/*
 * packet_reader.h
 *
 *  Created on: 9 août 2008
 *      Author: mathieu
 */

#ifndef PACKET_READER_H_
#define PACKET_READER_H_
#define RTCM_WORDS_MAX	33
//#define STATE_DEBUG
/*
 * The packet buffers need to be as long than the longest packet we
 * expect to see in any protocol, because we have to be able to hold
 * an entire packet for checksumming...
 * First we thought it had to be big enough for a SiRF Measured Tracker
 * Data packet (188 bytes). Then it had to be big enough for a UBX SVINFO
 * packet (206 bytes). Now it turns out that a couple of ITALK messages are
 * over 512 bytes. I know we like verbose output, but this is ridiculous.
 */
#define MAX_PACKET_LENGTH	516	/* 7 + 506 + 3 */

/*
 * We used to define the input buffer length as MAX_PACKET_LENGTH*2+1.
 * However, as it turns out, this isn't enough.  We've had a report
 * from one user with a GPS that reports at 20Hz that "sometimes a
 * long/slow context switch will cause the next read from the serial
 * device to be very big. I sometimes see a read of 250 characters or
 * more."
 */
#define INPUT_BUFFER_LENGTH	1536
enum {
#include "packet_states.h"
};
#ifndef bool
typedef enum { false, true } bool;
#endif

struct gps_packet_t {
    /* packet-getter internals */
    int	type;
#define BAD_PACKET	-1
#define COMMENT_PACKET	0
#define NMEA_PACKET	1
#define SIRF_PACKET	2
#define ZODIAC_PACKET	3
#define TSIP_PACKET	4
#define EVERMORE_PACKET	5
#define ITALK_PACKET	6
#define RTCM_PACKET	7
#define GARMIN_PACKET	8
#define NAVCOM_PACKET	9
#define UBX_PACKET	10
#define GARMINTXT_PACKET	11
    unsigned int state;
    size_t length;
    unsigned char inbuffer[MAX_PACKET_LENGTH*2+1];
    size_t inbuflen;
    unsigned /*@observer@*/char *inbufptr;
    /* outbuffer needs to be able to hold 4 GPGSV records at once */
    unsigned char outbuffer[MAX_PACKET_LENGTH*2+1];
    size_t outbuflen;
    unsigned long char_counter;		/* count characters processed */
    unsigned long retry_counter;	/* count sniff retries */
    unsigned counter;			/* packets since last driver switch */
};
ssize_t packet_get(int fd, struct gps_packet_t *lexer);
void packet_reset(struct gps_packet_t *lexer);
ssize_t packet_parse(struct gps_packet_t *lexer, size_t fix);

#endif /* PACKET_READER_H_ */
