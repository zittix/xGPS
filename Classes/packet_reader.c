/*
 * packet_reader.c
 *
 *  Created on: 9 août 2008
 *      Author: mathieu
 */

//From the gpsd project
/*
 NAME:
 packet.c -- a packet-sniffing engine for reading from GPS devices

 DESCRIPTION:

 Initial conditions of the problem:

 1. We have a file descriptor open for (possibly non-blocking) read. The device
 on the other end is sending packets at us.

 2. It may require more than one read to gather a packet.  Reads may span packet
 boundaries.

 3. There may be leading garbage before the first packet.  After the first
 start-of-packet, the input should be well-formed.

 The problem: how do we recognize which kind of packet we're getting?

 No need to handle Garmin USB binary, we know that type by the fact we're
 connected to the Garmin kernel driver.  But we need to be able to tell the
 others apart and distinguish them from baud barf.

 ***************************************************************************/
#include <sys/types.h>
#include <ctype.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include "packet_reader.h"

/*
 * The packet-recognition state machine.  It can be fooled by garbage
 * that looks like the head of a binary packet followed by a NMEA
 * packet; in that case it won't reset until it notices that the
 * binary trailer is not where it should be, and the NMEA packet will
 * be lost.  The reverse scenario is not possible because none of the
 * binary leader characters can occur in an NMEA packet.  Caller should
 * consume a packet when it sees one of the *_RECOGNIZED states.
 * It's good practice to follow the _RECOGNIZED transition with one
 * that recognizes a leader of the same packet type rather than
 * dropping back to ground state -- this for example will prevent
 * the state machine from hopping between recognizing TSIP and
 * EverMore packets that both start with a DLE.
 *
 * Error handling is brutally simple; any time we see an unexpected
 * character, go to GROUND_STATE and reset the machine (except that a
 * $ in an NMEA payload only resets back to NMEA_DOLLAR state).  Because
 * another good packet will usually be along in less than a second
 * repeating the same data, Boyer-Moore-like attempts to do parallel
 * recognition beyond the headers would make no sense in this
 * application, they'd just add complexity.
 *
 * This state machine allows the following talker IDs:
 *      GP -- Global Positioning System.
 *      II -- Integrated Instrumentation (Raytheon's SeaTalk system).
 *	IN -- Integrated Navigation (Garmin uses this).
 *
 */




#define DLE	0x10
#define STX	0x02
#define ETX	0x03

static void nextstate(struct gps_packet_t *lexer, unsigned char c);

static void nextstate(struct gps_packet_t *lexer, unsigned char c) {
	switch (lexer->state) {
		case GROUND_STATE:
			if (c == '#') {
				lexer->state = COMMENT_BODY;
				break;
			}
			if (c == '$') {
				lexer->state = NMEA_DOLLAR;
				break;
			}
			if (c == '!') {
				lexer->state = NMEA_BANG;
				break;
			}
			break;
		case COMMENT_BODY:
			if (c == '\n')
				lexer->state = COMMENT_RECOGNIZED;
			else if (!isprint(c)) lexer->state = GROUND_STATE;
			break;
		case NMEA_DOLLAR:
			if (c == 'G')
				lexer->state = NMEA_PUB_LEAD;
			else if (c == 'P') /* vendor sentence */
				lexer->state = NMEA_VENDOR_LEAD;
			else if (c == 'I') /* Seatalk */
				lexer->state = SEATALK_LEAD_1;
			else if (c == 'A') /* SiRF Ack */
				lexer->state = SIRF_ACK_LEAD_1;
			else
				lexer->state = GROUND_STATE;
			break;
		case NMEA_PUB_LEAD:
			if (c == 'P')
				lexer->state = NMEA_LEADER_END;
			else
				lexer->state = GROUND_STATE;
			break;
		case NMEA_VENDOR_LEAD:
			if (isalpha(c))
				lexer->state = NMEA_LEADER_END;
			else
				lexer->state = GROUND_STATE;
			break;
		case NMEA_BANG:
			if (c == 'A')
				lexer->state = AIS_LEAD_1;
			else
				lexer->state = GROUND_STATE;
			break;
		case AIS_LEAD_1:
			if (c == 'I')
				lexer->state = AIS_LEAD_2;
			else
				lexer->state = GROUND_STATE;
			break;
		case AIS_LEAD_2:
			if (isalpha(c))
				lexer->state = NMEA_LEADER_END;
			else
				lexer->state = GROUND_STATE;
			break;
		case NMEA_LEADER_END:
			if (c == '\r')
				lexer->state = NMEA_CR;
			else if (c == '\n')
				/* not strictly correct, but helps for interpreting logfiles */
				lexer->state = NMEA_RECOGNIZED;
			else if (c == '$')
				/* faster recovery from missing sentence trailers */
				lexer->state = NMEA_DOLLAR;
			else if (!isprint(c)) lexer->state = GROUND_STATE;
			break;
		case NMEA_CR:
			if (c == '\n')
				lexer->state = NMEA_RECOGNIZED;
			else
				lexer->state = GROUND_STATE;
			break;
		case NMEA_RECOGNIZED:
			if (c == '$')
				lexer->state = NMEA_DOLLAR;
			else if (c == '!')
				lexer->state = NMEA_BANG;
			else
				lexer->state = GROUND_STATE;
			break;
	}
	/*@ -charint +casebreak @*/
}

//#define STATE_DEBUG

static void packet_accept(struct gps_packet_t *lexer, int packet_type)
/* packet grab succeeded, move to output buffer */
{
	size_t packetlen = lexer->inbufptr - lexer->inbuffer;
	if (packetlen < sizeof(lexer->outbuffer)) {
		memcpy(lexer->outbuffer, lexer->inbuffer, packetlen);
		lexer->outbuflen = packetlen;
		lexer->outbuffer[packetlen] = '\0';
		lexer->type = packet_type;
#ifdef STATE_DEBUG
		printf("Packet type %d accepted %d = %s\n", packet_type, (int) packetlen, lexer->outbuffer);
#endif /* STATE_DEBUG */
	} else {
		printf("Rejected too long packet type %d len %d\n", packet_type, (int) packetlen);
	}
}

static void packet_discard(struct gps_packet_t *lexer)
/* shift the input buffer to discard all data up to current input pointer */
{
	//printf("BEFORE: '%s'\n",lexer->inbuffer);
	size_t discard = lexer->inbufptr - lexer->inbuffer;
	size_t remaining = lexer->inbuflen - discard;
	lexer->inbufptr = memmove(lexer->inbuffer, lexer->inbufptr, remaining);
	lexer->inbuflen = remaining;
#ifdef STATE_DEBUG
	//printf("AFTER: '%s'\n",lexer->inbuffer);
	printf("Packet discard of %d, chars remaining is %d, free= %d\n", (int) discard, (int) remaining, sizeof(lexer->inbuffer)-remaining);
#endif /* STATE_DEBUG */
}

static void character_discard(struct gps_packet_t *lexer)
/* shift the input buffer to discard one character and reread data */
{
	memmove(lexer->inbuffer, lexer->inbuffer + 1, (size_t) --lexer->inbuflen);
	lexer->inbufptr = lexer->inbuffer;
#ifdef STATE_DEBUG
	printf("Character discarded, buffer %d chars = %s\n", (int) lexer->inbuflen, lexer->inbuffer);
#endif /* STATE_DEBUG */
}

/* get 0-origin big-endian words relative to start of packet buffer */
#define getword(i) (short)(lexer->inbuffer[2*(i)] | (lexer->inbuffer[2*(i)+1] << 8))

/* entry points begin here */
extern void writeDebugMessage(const char*msg);
ssize_t packet_parse(struct gps_packet_t *lexer, size_t fix)
/* grab a packet; returns either BAD_PACKET or the length */
{
#ifdef STATE_DEBUG
	printf("Read %d chars to buffer offset %d (total %d): %s\n", (int) fix, (int) lexer->inbuflen, (int) (lexer->inbuflen + fix), lexer->inbufptr);
#endif /* STATE_DEBUG */

	lexer->outbuflen = 0;
	lexer->inbuflen += fix;
	while (lexer->inbufptr < lexer->inbuffer + lexer->inbuflen) {
		/*@ -modobserver @*/
		unsigned char c = *lexer->inbufptr++;
		/*@ +modobserver @*/

		nextstate(lexer, c);
		//printf("%08ld: character '%c' [%02x], new state: %s\n", lexer->char_counter, (isprint(c) ? c : '.'), c, state_table[lexer->state]);
		lexer->char_counter++;

		if (lexer->state == GROUND_STATE) {
			character_discard(lexer);
		} else if (lexer->state == COMMENT_RECOGNIZED) {
			packet_accept(lexer, COMMENT_PACKET);
			packet_discard(lexer);
			lexer->state = GROUND_STATE;
			break;
		} else if (lexer->state == NMEA_RECOGNIZED) {
			bool checksum_ok = true;
			char csum[3];
			char *trailer = (char *) lexer->inbufptr - 5;
			if (*trailer == '*') {
				unsigned int n, crc = 0;
				for (n = 1; (char *) lexer->inbuffer + n < trailer; n++)
					crc ^= lexer->inbuffer[n];
				(void) snprintf(csum, sizeof(csum), "%02X", crc);
				checksum_ok = (csum[0] == toupper(trailer[1]) && csum[1] == toupper(trailer[2]));
			}
			if (checksum_ok)
				packet_accept(lexer, NMEA_PACKET);
			else {
				lexer->state = GROUND_STATE;
				writeDebugMessage("Checksum error");
			}
			packet_discard(lexer);
			lexer->state = GROUND_STATE;
			break;
		}
	} /* while */

	return (ssize_t) fix;
}
#undef getword


ssize_t packet_get(int fd, struct gps_packet_t *lexer)
/* grab a packet; returns either BAD_PACKET or the length */
{
	ssize_t recvd;

	/*@ -modobserver @*/
	recvd = read(fd, lexer->inbuffer + lexer->inbuflen, sizeof(lexer->inbuffer) - (lexer->inbuflen));

	//printf("%d raw bytes read: %s\n",
	//	(int)recvd,lexer->inbuffer+lexer->inbuflen);
	//if(recvd<0)
	//	printf("Receive error: %s\n", strerror(errno));
	/*@ +modobserver @*/
	if (recvd == -1) {
		if ((errno == EAGAIN) || (errno == EINTR)) {
			return 0;
		} else {
			return BAD_PACKET;
		}
	}

	if (recvd == 0) return 0;
	return packet_parse(lexer, (size_t) recvd);
}

void packet_reset(struct gps_packet_t *lexer)
/* return the packet machine to the ground state */
{
	lexer->type = BAD_PACKET;
	lexer->state = GROUND_STATE;
	lexer->inbuflen = 0;
	lexer->inbufptr = lexer->inbuffer;
}
