//
//  SoundController.m
//  xGPS
//
//  Created by Mathieu on 28.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SoundController.h"

#include <AudioToolbox/AudioToolbox.h>
#include <AudioToolbox/AudioQueue.h>
#include <CoreAudio/CoreAudioTypes.h>
#include "cst_wave.h"
#include "flite.h"
#include "flite_version.h"
#include "voxdefs.h"

static const int kNumberBuffers = 3;                              // 1
typedef struct AQPlayerState {
    AudioStreamBasicDescription   mDataFormat;                    // 2
    AudioQueueRef                 mQueue;                         // 3
    AudioQueueBufferRef           mBuffers[3];					// 4
    AudioFileID                   mAudioFile;                     // 5
    UInt32                        bufferByteSize;                 // 6
    UInt64                        mCurrentPacket;                 // 7
    UInt32                        mNumPacketsToRead;              // 8
    AudioStreamPacketDescription  *mPacketDescs;                  // 9
    bool                          mIsRunning;                     // 10
	cst_wave *w;
} AQPlayerState;

static AQPlayerState aqData;

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
	
	if(pAqData->w!=NULL) {
		
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
	} else {
		//AudioFile
		UInt32 numBytesReadFromFile;                              // 3
		UInt32 numPackets = pAqData->mNumPacketsToRead;           // 4
		AudioFileReadPackets (
							  pAqData->mAudioFile,
							  false,
							  &numBytesReadFromFile,
							  pAqData->mPacketDescs, 
							  pAqData->mCurrentPacket,
							  &numPackets,
							  inBuffer->mAudioData 
							  );
		if (numPackets > 0) {                                     // 5
			inBuffer->mAudioDataByteSize = numBytesReadFromFile;  // 6
			AudioQueueEnqueueBuffer ( 
									 pAqData->mQueue,
									 inBuffer,
									 (pAqData->mPacketDescs ? numPackets : 0),
									 pAqData->mPacketDescs
									 );
			pAqData->mCurrentPacket += numPackets;                // 7 
		} else {
			AudioQueueStop (
							pAqData->mQueue,
							false
							);
			pAqData->mIsRunning = false; 
		}
	}
	//printf("HandleOutputBuffer - OUT\n");
	
}

@implementation SoundController

-(void)dealloc {
	[super dealloc];
	[tmrSoundCheck release];
	[chain dealloc];
}
-(id)init {
	if((self=[super init])) {
	flite_init();	
	}
	return self;
}
-(void)playFile:(NSString*)f {
	CFURLRef audioFileURL =
    CFURLCreateFromFileSystemRepresentation (           // 1
											 NULL,                                           // 2
											(const UInt8 *) f.UTF8String,                       // 3
											 f.length ,                              // 4
											 false                                           // 5
											 );
	
    AudioFileOpenURL (                                  // 2
					  audioFileURL,                                   // 3
					  fsRdPerm,                                       // 4
					  0,                                              // 5
					  &aqData.mAudioFile                              // 6
					  );
	
	CFRelease (audioFileURL);                               // 7
	UInt32 dataFormatSize = sizeof (aqData.mDataFormat);    // 1
	
	AudioFileGetProperty (                                  // 2
						  aqData.mAudioFile,                                  // 3
						  kAudioFilePropertyDataFormat,                       // 4
						  &dataFormatSize,                                    // 5
						  &aqData.mDataFormat                                 // 6
	);
	AudioQueueNewOutput (                                // 1
						 &aqData.mDataFormat,                             // 2
						 HandleOutputBuffer,                              // 3
						 &aqData,                                         // 4
						 CFRunLoopGetCurrent (),                          // 5
						 kCFRunLoopCommonModes,                           // 6
						 0,                                               // 7
						 &aqData.mQueue                                   // 8
	);
	UInt32 maxPacketSize;
	UInt32 propertySize = sizeof (maxPacketSize);
	AudioFileGetProperty (                               // 1
						  aqData.mAudioFile,                               // 2
						  kAudioFilePropertyPacketSizeUpperBound,          // 3
						  &propertySize,                                   // 4
						  &maxPacketSize                                   // 5
	);
	
	DeriveBufferSize (                                   // 6
					  &aqData.mDataFormat,                              // 7
					  maxPacketSize,                                   // 8
					  0.5,                                             // 9
					  &aqData.bufferByteSize,                          // 10
					  &aqData.mNumPacketsToRead                        // 11
	);
	aqData.mCurrentPacket = 0;                                // 1
	aqData.mIsRunning = true;                          // 1
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
	aqData.mIsRunning = true;                          // 1
	checkSoundCounter=0;
	tmrSoundCheck=[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(checkSound) userInfo:nil repeats:YES];
	[tmrSoundCheck retain];
	AudioQueueStart (                                  // 2
					 aqData.mQueue,                                 // 3
					 NULL                                           // 4
	);
}
-(void)checkSound {
	if(aqData.mIsRunning == false) {
		if(checkSoundCounter==3) {
		//Done, continue to process the queue
		
		//Remove toPlay
		SoundEvent *next=chain.next;
		[next retain];
		[chain release];
		chain=next;
		[tmrSoundCheck invalidate];
		[tmrSoundCheck release];
		tmrSoundCheck=nil;
			
		AudioQueueDispose(aqData.mQueue,false);
		if(aqData.w!=NULL) {
			delete_wave(aqData.w);
			aqData.w=NULL;
			
		} else if(aqData.mAudioFile!=NULL) {
			AudioFileClose(aqData.mAudioFile);
		}
		running=NO;
		checkSoundCounter=0;
		[self treatQueue];
		} else {
			checkSoundCounter++;
		}
	}
}
-(void)playText:(NSString*)text {
	cst_voice *v;
	
    cst_features *extra_feats;
	
    
    extra_feats = new_features();
	
    
	
    v = REGISTER_VOX(NULL);
    feat_copy_into(extra_feats,v->features);

	cst_wave *w=flite_text_to_wave(text.UTF8String,v);
	
    delete_features(extra_feats);
	
    UNREGISTER_VOX(v);
	
	aqData.mDataFormat.mSampleRate=w->sample_rate;
	
	
	aqData.mDataFormat.mFramesPerPacket = 1;
	
	aqData.mDataFormat.mChannelsPerFrame = w->num_channels;
	aqData.mDataFormat.mFormatFlags=kLinearPCMFormatFlagIsSignedInteger ;
	aqData.mDataFormat.mFormatID=kAudioFormatLinearPCM;

	aqData.mDataFormat.mBitsPerChannel = 16;
		
	aqData.w=w;
	aqData.mDataFormat.mBytesPerPacket = w->num_channels*(aqData.mDataFormat.mBitsPerChannel/8);
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
					  0.5,                                             // 9
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
	aqData.mIsRunning = true;                          // 1
	checkSoundCounter=0;
	tmrSoundCheck=[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(checkSound) userInfo:nil repeats:YES];
	[tmrSoundCheck retain];
	AudioQueueStart (                                  // 2
					 aqData.mQueue,                                 // 3
					 NULL                                           // 4
					 );
}
-(void)treatQueue {
	if(running) return;
	
	//Play the queue
	running=YES;
	
	SoundEvent *toPlay=chain;
	if(toPlay==nil) {
		running=NO;
		NSLog(@"SoundController: No more sound to play. Exiting");
		return;
	}
	
	if(toPlay.text!=nil) {
		[self playText:toPlay.text];
		
	} else if(toPlay.snd>=0) {
		//Play a system sound
		NSString *songToPlay=nil;
		switch(toPlay.snd) {
			case Sound_Announce:
				songToPlay=@"announce_direction";
				break;
			case Sound_Radar:
				songToPlay=@"radar_alert";
				break;
			default:
				NSLog(@"Internal consistency error: Wrong sound ID");
				running=NO;
				return;
				break;
		}
		//Get the bundle path
		NSString* fileToPlay=[[NSBundle mainBundle] pathForResource:songToPlay ofType:@"wav" inDirectory:@"sounds"];
		
		//Sound file not found
		if(fileToPlay==nil) {
			NSLog(@"Sound file not found: %@.wav",songToPlay);
			
			//Remove toPlay
			SoundEvent *next=chain.next;
			[next retain];
			[chain release];
			chain=next;
			
			running=NO;
			[self treatQueue];
			return;
		} else {
			//Play the file
			[self playFile:fileToPlay];
		}
	} else {
		NSLog(@"Invalid sound event");
		//Remove toPlay
		SoundEvent *next=chain.next;
		[next retain];
		[chain release];
		chain=next;
		
		running=NO;
		[self treatQueue];
		return;
		
	}
}
-(void)addSound:(SoundEvent*)s {
	[self addSound:s after:nil];
}
-(void)addSound:(SoundEvent*)s after:(SoundEvent*)ePrev {
	
	if(chain==nil) {
		//No sound in queue
		if(ePrev!=nil) {
			NSLog(@"Consistency error: Cannot add a song after another one: Queue empty");
		}
		chain=[s retain];
	} else {
		//sounds in queue
		SoundEvent *prev=[chain getLast];
		if(ePrev!=nil) {
			//Find the previous one
			SoundEvent *f=chain;
			while(f.next!=nil) {
				if(f==ePrev) {
					prev=f;
					break;
				}
				f=f.next;
			}
		}
		
		//Add the sound to the queue
		
		//Save the next before
		SoundEvent *prevNext=prev.next;
		
		prev.next=[s retain];
		
		[prev.next getLast].next=prevNext;
	}
	[self treatQueue];
}

@end
