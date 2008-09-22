/* $Id: packet_states.h 4644 2007-12-28 03:13:44Z esr $ */
   GROUND_STATE,	/* we don't know what packet type to expect */

   COMMENT_BODY,	/* pound comment for a test load */
   COMMENT_RECOGNIZED,	/* comment recognized */

   NMEA_DOLLAR,		/* we've seen first character of NMEA leader */
   NMEA_BANG,		/* we've seen first character of an AIS message '!' */
   NMEA_PUB_LEAD,	/* seen second character of NMEA G leader */
   NMEA_VENDOR_LEAD,	/* seen second character of NMEA P leader */
   NMEA_LEADER_END,	/* seen end char of NMEA leader, in body */
   NMEA_CR,	   	/* seen terminating \r of NMEA packet */
   NMEA_RECOGNIZED,	/* saw trailing \n of NMEA packet */

   SIRF_ACK_LEAD_1,	/* seen A of possible SiRF Ack */
   SIRF_ACK_LEAD_2,	/* seen c of possible SiRF Ack */
   AIS_LEAD_1,		/* seen A of possible marine AIS message */
   AIS_LEAD_2,		/* seen I of possible marine AIS message */

   SEATALK_LEAD_1,	/* SeaTalk/Garmin packet leader 'I' */

   DLE_LEADER		/* we've seen the TSIP/EverMore leader (DLE) */

/* end of packet_states.h */
