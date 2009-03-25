CC=arm-apple-darwin9-gcc
CFLAGS=-DTARGET_OS_IPHONE -Os -I/iphone/sys/usr/include -std=c99 -IClasses/include -IClasses/lang/cmu_us_kal16 -IClasses/lang/cmulex -IClasses/lang/usenglish -IClasses/src/audio
LDFLAGS=-bind_at_load -framework AudioToolbox -framework CoreAudio -framework CoreFoundation -lz -L"/iphone/sys/usr/lib" -F"/iphone/sys/System/Library/Frameworks" -F"/iphone/sys/System/Library/PrivateFrameworks" -lobjc -lm -lsqlite3 -framework Foundation -framework UIKit -framework CoreGraphics -framework CFNetwork -framework CoreLocation -framework AddressBook -framework AddressBookUI -framework MediaPlayer

SRC_C= $(wildcard Classes/*.c) $(wildcard Classes/lang/cmu_us_kal16/*.c) Classes/lang/cmulex/cmu_lex.c Classes/lang/cmulex/cmu_lex_data.c Classes/lang/cmulex/cmu_lex_entries.c Classes/lang/cmulex/cmu_lts_model.c Classes/lang/cmulex/cmu_lts_rules.c $(wildcard Classes/lang/usenglish/*.c) $(wildcard Classes/src/audio/*.c) $(wildcard Classes/src/hrg/*.c) $(wildcard Classes/src/lexicon/*.c) $(wildcard Classes/src/regex/*.c) $(wildcard Classes/src/speech/*.c) $(wildcard Classes/src/stats/*.c) $(wildcard Classes/src/synth/*.c) $(wildcard Classes/src/utils/*.c) $(wildcard Classes/src/wavesynth/*.c)
SRC_M= $(wildcard Classes/*.m) main.m
CLASSES= $(SRC_M:.m=.o)
C_FILE+= $(SRC_C:.c=.o)


all:	xGPS
xGPS: 	$(CLASSES) $(C_FILE)
	$(CC) $(LDFLAGS) -o xGPS $^
	ldid -S xGPS

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
	
package:
	rm -fr debian/Applications
	mkdir -p debian/Applications/xGPSBeta.app/sounds
	mkdir -p debian/System/Library/CoreServices/SpringBoard.app
	cp xGPS debian/Applications/xGPSBeta.app/
	cp sounds/* debian/Applications/xGPSBeta.app/sounds
	cp Info_beta.plist debian/Applications/xGPSBeta.app/Info.plist
	cp *.png debian/Applications/xGPSBeta.app
	cp icon_satbar_red.png debian/System/Library/CoreServices/SpringBoard.app/Default_xGPS_sat_0.png
	cp icon_satbar_red.png debian/System/Library/CoreServices/SpringBoard.app/FSO_xGPS_sat_0.png
	cp icon_satbar_yellow.png debian/System/Library/CoreServices/SpringBoard.app/Default_xGPS_sat_1.png
	cp icon_satbar_yellow.png debian/System/Library/CoreServices/SpringBoard.app/FSO_xGPS_sat_1.png
	cp icon_satbar_green.png debian/System/Library/CoreServices/SpringBoard.app/Default_xGPS_sat_2.png
	cp icon_satbar_green.png debian/System/Library/CoreServices/SpringBoard.app/FSO_xGPS_sat_2.png
	cp -r *.lproj debian/Applications/xGPSBeta.app/
	chmod a+r debian/Applications/xGPSBeta.app/*
	chmod a+x debian/Applications/xGPSBeta.app/xGPS
	#Remove .svn folder
	find ./debian -name ".svn" | xargs rm -Rf
dist: package deb
	cd debian/Applications && zip -r xGPSBeta.zip xGPSBeta.app/ && mv xGPSBeta.zip ../../
deb: package
	dpkg-deb -b debian
	mv debian.deb xGPSBeta.deb

clean:	
	rm -fr *.o xGPS Classes/*.o
	rm -fr debian/Applications
	rm -f xGPSBeta.zip xGPSBeta.deb
	rm -fr debian/
	rm -f *~
