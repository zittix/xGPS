CC=/iphone/pre/bin/arm-apple-darwin9-gcc
CFLAGS=-Wall -Os -Wall -I/iphone/sys/usr/include
LDFLAGS=-L"/iphone/sys/usr/lib" -F"/iphone/sys/System/Library/Frameworks" -F"/iphone/sys/System/Library/PrivateFrameworks" -bind_at_load -lobjc -lm -lsqlite3 -framework CoreFoundation -framework Foundation \
        -framework UIKit -framework CoreGraphics \
        -framework GraphicsServices -framework MultitouchSupport -framework CoreSurface

CLASSES=Classes/DirectionsViewController.o \
Classes/MainViewController.o \
Classes/MapsManagerView.o \
Classes/MapTile.o \
Classes/MapView.o \
Classes/Position.o \
Classes/ProgressView.o \
Classes/SettingsViewController.o \
Classes/SpeedView.o \
Classes/TileDB.o \
Classes/xGPSAppDelegate.o \
Classes/xGPSController.o \
Classes/ZoomView.o \
main.o

C_FILE=Classes/nmea_parse.o \
Classes/packet_reader.o \

all:	xGPS

xGPS: 	$(C_FILE) $(CLASSES)
	echo $(CLASSES)
	$(CC) $(LDFLAGS) -o xGPS $^
	#/usr/bin/ldid -S xGPS

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

package:
	rm -fr xGPSUtil/Applications
	mkdir -p xGPSUtil/Applications/xGPSUtil.app
	cp xgpsutil xGPSUtil/Applications/xGPSUtil.app/
	cp Resources/Info.plist xGPSUtil/Applications/xGPSUtil.app/Info.plist
	cp Resources/icon.png xGPSUtil/Applications/xGPSUtil.app/icon.png
	cp Resources/Default.png xGPSUtil/Applications/xGPSUtil.app/Default.png
	chmod +r xGPSUtil/Applications/xGPSUtil.app/*
	chmod +x xGPSUtil/Applications/xGPSUtil.app/xgpsutil

dist: package
	cd xGPSUtil && zip -r xGPS.zip xGPSUtil.app/ && mv xGPSUtil.zip ../
deb:
	dpkg-deb -b xGPS
deploy: package
#	ssh root@xtouch "rm -f -R /Applications/xGPS.app"
	scp -r xGPSUtil/xGPSUtil.app root@xtouch:/Applications/
#	ssh root@xtouch "chmod +x /Applications/xGPS.app/xGPS"

xGPSUtilrestart: package spring

clean:	
	rm -fr *.o xGPS Classes/*.o
	rm -f *~
	
spring:
	ssh root@xtouch 'killall SpringBoard'
