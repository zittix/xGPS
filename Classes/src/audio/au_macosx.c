/*************************************************************************/
/*                                                                       */
/*                  Language Technologies Institute                      */
/*                     Carnegie Mellon University                        */
/*                        Copyright (c) 2001                             */
/*                        All Rights Reserved.                           */
/*                                                                       */
/*  Permission is hereby granted, free of charge, to use and distribute  */
/*  this software and its documentation without restriction, including   */
/*  without limitation the rights to use, copy, modify, merge, publish,  */
/*  distribute, sublicense, and/or sell copies of this work, and to      */
/*  permit persons to whom this work is furnished to do so, subject to   */
/*  the following conditions:                                            */
/*   1. The code must retain the above copyright notice, this list of    */
/*      conditions and the following disclaimer.                         */
/*   2. Any modifications must be clearly marked as such.                */
/*   3. Original authors' names are not deleted.                         */
/*   4. The authors' names are not used to endorse or promote products   */
/*      derived from this software without specific prior written        */
/*      permission.                                                      */
/*                                                                       */
/*  CARNEGIE MELLON UNIVERSITY AND THE CONTRIBUTORS TO THIS WORK         */
/*  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      */
/*  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   */
/*  SHALL CARNEGIE MELLON UNIVERSITY NOR THE CONTRIBUTORS BE LIABLE      */
/*  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    */
/*  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   */
/*  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          */
/*  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       */
/*  THIS SOFTWARE.                                                       */
/*                                                                       */
/*************************************************************************/
/*             Author:  Alan W Black (awb@cs.cmu.edu)                    */
/*               Date:  January 2001                                     */
/*************************************************************************/
/*                                                                       */
/*  Ain't got no direct audio                                            */
/*                                                                       */
/*************************************************************************/

#include "cst_string.h"
#include "cst_wave.h"
#include "cst_audio.h"
#include <AudioToolbox/AudioToolbox.h>
#include <AudioToolbox/AudioQueue.h>
#include <CoreAudio/CoreAudioTypes.h>

static const int kNumberBuffers = 2;                              // 1
typedef struct AQPlayerState {
    AudioStreamBasicDescription   mDataFormat;                    // 2
    AudioQueueRef                 mQueue;                         // 3
    AudioQueueBufferRef           mBuffers[2];       // 4
    //AudioFileID                   mAudioFile;                     // 5
    UInt32                        bufferByteSize;                 // 6
    UInt64                        mCurrentPacket;                 // 7
    UInt32                        mNumPacketsToRead;              // 8
    AudioStreamPacketDescription  *mPacketDescs;                  // 9
    bool                          mIsRunning;                     // 10
	cst_wave *w;
} AQPlayerState;
static AQPlayerState aqData;
/*
 1 Sets the number of audio queue buffers to use. Three is typically a good number, as described in “Audio Queue Buffers.”
 2 An AudioStreamBasicDescription structure (from CoreAudioTypes.h) representing the audio data format of the file being played. This format gets used by the audio queue specified in the mQueue field.
 The mDataFormat field gets filled by querying an audio file's kAudioFilePropertyDataFormat property, as described in “Obtaining a File’s Audio Data Format.”
 
 For details on the AudioStreamBasicDescription structure, see Core Audio Data Types Reference.
 
 3 The playback audio queue created by your application.
 4 An array holding pointers to the audio queue buffers managed by the audio queue.
 5 An audio file object that represents the audio file your program plays.
 6 The size, in bytes, for each audio queue buffer. This value is calculated in these examples in the DeriveBufferSize function, after the audio queue is created and before it is started. See “Write a Function to Derive Playback Audio Queue Buffer Size.”
 7 The packet index for the next packet to play from the audio file.
 8 The number of packets to read on each invocation of the audio queue’s playback callback. Like the bufferByteSize field, this value is calculated in these examples in the DeriveBufferSize function, after the audio queue is created and before it is started.
 9 For VBR audio data, the array of packet descriptions for the file being played. For CBR data, the value of this field is NULL.
 10  A Boolean value indicating whether or not the audio queue is running.
 
 */
/*
 typedef enum {
 CST_AUDIO_LINEAR16 = 0,
 CST_AUDIO_LINEAR8,
 CST_AUDIO_MULAW
 } cst_audiofmt;
 */

static void DeriveBufferSize (
							  AudioStreamBasicDescription *ASBDesc,                            // 1
							  UInt32                      maxPacketSize,                       // 2
							  Float64                     seconds,                             // 3
							  UInt32                      *outBufferSize,                      // 4
							  UInt32                      *outNumPacketsToRead                 // 5
) {
    static const int maxBufferSize = 0x50000;                        // 6
    static const int minBufferSize = 0x1000;                         // 7
	
    if ((*ASBDesc).mFramesPerPacket != 0) {                             // 8
        Float64 numPacketsForTime =
		(*ASBDesc).mSampleRate / (*ASBDesc).mFramesPerPacket * seconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    } else {                                                         // 9
        *outBufferSize =
		maxBufferSize > maxPacketSize ?
		maxBufferSize : maxPacketSize;
    }
	
    if (                                                             // 10
        *outBufferSize > maxBufferSize &&
        *outBufferSize > maxPacketSize
		)
        *outBufferSize = maxBufferSize;
    else {                                                           // 11
        if (*outBufferSize < minBufferSize)
            *outBufferSize = minBufferSize;
    }
	
    *outNumPacketsToRead = *outBufferSize / maxPacketSize;           // 12
}

static void HandleOutputBuffer (
								void                 *aqData,                 // 1
								AudioQueueRef        inAQ,                    // 2
								AudioQueueBufferRef  inBuffer                 // 3
) {
	//We fill inBuffer
	//inBuffer->mAudioData
	AQPlayerState *pAqData=(AQPlayerState*)aqData;
	//printf("HandleOutputBuffer - IN with buffer of %d bytes\n",inBuffer->mAudioDataBytesCapacity);
	if (pAqData->mIsRunning == 0) return;
	
	
	UInt64 start=pAqData->mCurrentPacket;
	UInt64 stop;
	if((inBuffer->mAudioDataBytesCapacity/pAqData->mDataFormat.mBytesPerPacket)+start>=pAqData->w->num_samples)
		stop=pAqData->w->num_samples-1;
	else
		stop=start+(inBuffer->mAudioDataBytesCapacity/pAqData->mDataFormat.mBytesPerPacket)-1;
	
	
	inBuffer->mAudioDataByteSize = (stop-start)*pAqData->mDataFormat.mBytesPerPacket;
	if(inBuffer->mAudioDataByteSize>0) {
		//printf("Start: %d, Len:%d Total: %d\n",start,stop-start,pAqData->w->num_samples);
		
		memcpy(inBuffer->mAudioData, pAqData->w->samples+start, inBuffer->mAudioDataByteSize);
		
		//nb bytes read
		
		
		//printf("HandleOutputBuffer - Enqueue\n");
		
		//Set the audio ready to be played
		AudioQueueEnqueueBuffer (                      // 1
								 pAqData->mQueue,                           // 2
								 inBuffer,                                  // 3
								 0,  // 4
								 NULL                     // 5
								 );
		
		pAqData->mCurrentPacket+=(stop-start);
	} else {
		//printf("Nore more packet!!!\n");
		pAqData->mIsRunning=0;
	}
	//Checking which buffer we are using
	//for(int i=0;i<kNumberBuffers;i++) {
	//	if(pAqData->mBuffers[i]==inBuffer) {
	//		printf("Using buffer %d\n",i);
	//		break;
	//	}
	//}
	
	//printf("HandleOutputBuffer - OUT\n");
	
}

void audio_play_osx(int sps, int channels, cst_audiofmt fmt,cst_wave *w)
{
   	aqData.mDataFormat.mSampleRate=sps;
	
	
	aqData.mDataFormat.mFramesPerPacket = 1;
	
	aqData.mDataFormat.mChannelsPerFrame = channels;
	aqData.mDataFormat.mFormatFlags=kLinearPCMFormatFlagIsSignedInteger ;
	aqData.mDataFormat.mFormatID=kAudioFormatLinearPCM;
	switch (fmt)
    {
		case CST_AUDIO_LINEAR16:
			//wfx.wFormatTag = WAVE_FORMAT_PCM;
			//wfx.wBitsPerSample = 16;
			aqData.mDataFormat.mBitsPerChannel = 16;
			break;
		case CST_AUDIO_LINEAR8:
			//wfx.wFormatTag = WAVE_FORMAT_PCM;
			//wfx.wBitsPerSample = 8;
			aqData.mDataFormat.mBitsPerChannel =8;
			break;
		default:
			cst_errmsg("audio_open_none: unsupported format %d\n", fmt);
			cst_error();
			return;
    }
	aqData.w=w;
	aqData.mDataFormat.mBytesPerPacket = channels*(aqData.mDataFormat.mBitsPerChannel/8);
	aqData.mDataFormat.mBytesPerFrame = aqData.mDataFormat.mBytesPerPacket;
	//printf("Audio format: %u bits per channel, %u channels, %u bytes per frame\n",aqData.mDataFormat.mBitsPerChannel,aqData.mDataFormat.mBytesPerFrame);
	//printf("We play %d samples\n",w->num_samples);
	AudioQueueNewOutput (                                // 1
						 &aqData.mDataFormat,                             // 2
						 HandleOutputBuffer,                              // 3
						 &aqData,                                         // 4
						 CFRunLoopGetCurrent(),                          // 5
						 kCFRunLoopCommonModes,                           // 6
						 0,                                               // 7
						 &aqData.mQueue                                   // 8
						 );
	
	DeriveBufferSize (                                   // 6
					  & aqData.mDataFormat,                              // 7
					  aqData.mDataFormat.mBytesPerPacket,                                   // 8 max packet size
					  w->num_samples/(double)sps,                                             // 9
					  &aqData.bufferByteSize,                          // 10
					  &aqData.mNumPacketsToRead                        // 11
					  );
	aqData.mPacketDescs = NULL;
	//printf("Buffer stat: %d buffer size, %d packet to read\n",aqData.bufferByteSize, aqData.mNumPacketsToRead);
	aqData.mCurrentPacket = 0;       
	aqData.mIsRunning = 1;     // 1
	//printf("Allocating buffers.\n");
	for (int i = 0; i < kNumberBuffers; ++i) {                // 2
		AudioQueueAllocateBuffer (                            // 3
								  aqData.mQueue,                                    // 4
								  aqData.bufferByteSize,                            // 5
								  &aqData.mBuffers[i]                               // 6
								  );
		
		HandleOutputBuffer (                                  // 7
							&aqData,                                          // 8
							aqData.mQueue,                                    // 9
							aqData.mBuffers[i]                                // 10
							);
	}
	Float32 gain = 1.0;                                       // 1
    // Optionally, allow user to override gain setting here
	AudioQueueSetParameter (                                  // 2
							aqData.mQueue,                                        // 3
							kAudioQueueParam_Volume,                              // 4
							gain                                                  // 5
							);
	//printf("Playing.\n");
	// 1
	
	AudioQueueStart (                                  // 2
					 aqData.mQueue,                                 // 3
					 NULL                                           // 4
					 );
	do {                                               // 5
		CFRunLoopRunInMode (                           // 6
							kCFRunLoopDefaultMode,                     // 7
							0.25,                                      // 8
							false                                      // 9
							);
	} while (aqData.mIsRunning);
	
	CFRunLoopRunInMode (                               // 10
						kCFRunLoopDefaultMode,
						1,
						false
						);
	//printf("Stop open\n");
	AudioQueueDispose(aqData.mQueue,false);
    return;
}
