CC=arm-apple-darwin9-gcc
CFLAGS=-Os -Wall -I/iphone/sys/usr/include -std=c99
LDFLAGS=-L"/iphone/sys/usr/lib" -F"/iphone/sys/System/Library/Frameworks" -F"/iphone/sys/System/Library/PrivateFrameworks" -bind_at_load -lobjc -lm -lsqlite3 -framework CoreFoundation -framework Foundation \
        -framework UIKit -framework CoreGraphics \
        -framework GraphicsServices -framework MultitouchSupport -framework CoreSurface -framework CoreLocation -framework AddressBook -framework AddressBookUI

SRC_C= $(wildcard Classes/*.c)
SRC_M= $(wildcard Classes/*.m) main.m
CLASSES= $(SRC_M:.m=.o)
C_FILE+= $(SRC_C:.c=.o)


all:	xGPS

xGPS: 	$(CLASSES) $(C_FILE)
	$(CC) $(LDFLAGS) -o xGPS $^
	#ldid -S xGPS

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

clean:	
	rm -fr *.o xGPS Classes/*.o
	rm -f *~
