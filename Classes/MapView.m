//
//  MapView.m
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "MainViewController.h"
#import "MapView.h"
#undef NAN
#define NAN -10e8
extern float UIDistanceBetweenPoints(CGPoint a, CGPoint b);
@implementation MapView
-(void)setHasGPSPos:(BOOL)val {
	hasGPSfix=val;
}
-(void)setNextDirection:(PositionObj*)p {
	if(p!=nil) {
		nextDirection=[p retain];
	} else {
		if(nextDirection)
		[nextDirection release];

		nextDirection=nil;
	}

}
- (double)viewDoubleTapDelay:(UIView *)view {
	return 0.7;
}
- (void)updateCurrentPos:(PositionObj*) p {
	//NSLog(@"MapView - updateCurrentPos() - IN");
	//NSLog(@"MapView - updateCurrentPos() - IN with %f %f",[p x],[p y]);
	posGPS.x=[p x];
	posGPS.y=[p y];
	if(!dragging) {
		pos.x=posGPS.x;
		pos.y=posGPS.y;
	}
	[self setNeedsDisplay];
	//NSLog(@"MapView - updateCurrentPos() - OUT");
}
-(void)setOrientation:(int)orientation {
	_orientation=orientation;
	[self setNeedsDisplay];
}

-(void)setZoom:(int)z {
	zoom=z;
}
-(void)fakeGPS {
		pos.x+=0.0001;
		pos.y+=0.0001;
	[self setNeedsDisplay];
}
-(id)initWithFrame:(CGRect)f withDB:(TileDB*)_db {
	self=[super initWithFrame:f];
	NSLog(@"Loading MapView");
	db=_db;
	hasGPSfix=NO;
	dragging=NO;
	//_orientation=90;
	zoom=0;
	direction=0;
	passDoubleFingersEvent=NO;
	prevDist=NAN;
	dynTileSize=TILE_SIZE;
	lastDragPoint.x=NAN;
	lastDragPoint.y=NAN;
	tilescache=[[NSMutableDictionary dictionaryWithCapacity:64] retain];
	pos=[[PositionObj alloc] init];
	
	posGPS=[[PositionObj alloc] init];
	drawOrigin.x=drawOrigin.y=0;
	lines=[[NSMutableArray arrayWithCapacity:10] retain];
	//No map texture
	NSString* imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"notile.png"];
	NSData *noTileImg = [NSData dataWithContentsOfFile:imageFileName];
	tileNoMap=[[MapTile alloc] initWithData: noTileImg];
	
	imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pin_pos.png"];
	NSData *data = [NSData dataWithContentsOfFile:imageFileName];
	
	imgPinRef=[[MapTile alloc] initWithData: data];
	imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"GoogleBadge.png"];
	data = [NSData dataWithContentsOfFile:imageFileName];
	
	imgGoogleLogo=[[MapTile alloc] initWithData: data];
	
	
	pos.x=46.5833333;
	pos.y=6.55;
	posGPS.x=pos.x;
	posGPS.y=pos.y;
	[self setMultipleTouchEnabled:YES];
	//fakeGPS=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fakeGPS) userInfo:nil repeats:YES];

	return self;
}
-(void)setDirection:(int)dir {
	direction=dir;
	[self setNeedsDisplay];
}
/*
-(void)view:(UIView *)view handleTapWithCount:(int)count event: (GSEvent *)event fingerCount:(int)fcount {
	if(count==2) {
		//TODO: center on tap

		if(fcount==1) {
			[self zoomin];
		} else if(fcount==2) {
			[self zoomout];
		}
	}
	//NSLog(@"%d taps with %d fingers zoom: %d",count,fcount,zoom);
}
*/



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches	withEvent:event];
	dragging=NO;

	//Update the lat / lon with the org offset

	int x,y,xoff,yoff;
	//NSLog(@"Draw org: %f %f",drawOrigin.x,drawOrigin.y);
	//NSLog(@"Current pos: %f %f",pos.x,pos.y);
	[MapView getXYfrom:pos.x andLon:pos.y toPositionX:&x andY:&y withZoom:zoom];
	[self getXYOffsetfrom:pos.x andLon:pos.y toPositionX:&xoff andY:&yoff withZoom:zoom];

	int topleftx=floor((-drawOrigin.x+xoff)/TILE_SIZE);
	int toplefty=floor((-drawOrigin.y+yoff)/TILE_SIZE);

	int offx_after=-drawOrigin.x+xoff-topleftx*TILE_SIZE;
	int offy_after=-drawOrigin.y+yoff-toplefty*TILE_SIZE;
		//NSLog(@"Before (x,y): %d %d with offset %d %d",x,y,xoff,yoff);
	x+=topleftx;
	y+=toplefty;
	
	
		//NSLog(@"After (x,y): %d %d with offset %d %d",x,y,offx_after,offy_after);
	float lat,lon;

	[MapView getLatLonfromXY:x andY:y withXOffset:offx_after andYOffset:offy_after toLat:&lat andLon:&lon withZoom:zoom];
	//	NSLog(@"Dyn tile size: %f",dynTileSize/TILE_SIZE);
	if(dynTileSize/TILE_SIZE>=1.4 && zoom < 17) {
		dynTileSize=TILE_SIZE;
		zoom++;
	} else if(dynTileSize/TILE_SIZE<=0.6 && zoom>0) {
		dynTileSize=TILE_SIZE;
		zoom--;
	}
	//NSLog(@"Before: %f %f, after: %f %f",pos.x,pos.y,lat,lon);
	pos.x=lat;
	pos.y=lon;
	drawOrigin.x=0;
	drawOrigin.y=0;
	lastDragPoint.x=NAN;
	lastDragPoint.y=NAN;
	prevDist=NAN;
	[self setNeedsDisplay];[self setNeedsDisplay];[self setNeedsDisplay];

}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	
	NSSet *events=[event allTouches];
	NSEnumerator *enumerator = [events objectEnumerator];
	UITouch* value;
	//NSLog(@"Nb finger mapview: %d",[events count]);
	if([events count]>1)
		return;
	while ((value = [enumerator nextObject])) {
		CGPoint c = [value locationInView:self];

		dragging=YES;

		if(lastDragPoint.x==NAN || lastDragPoint.y==NAN) {
			lastDragPoint.x=c.x;
			lastDragPoint.y=c.y;
			return;
		}

		float diffx=c.x-lastDragPoint.x;
		float diffy=c.y-lastDragPoint.y;
		lastDragPoint.x=c.x;
		lastDragPoint.y=c.y;

		if(_orientation==0) {
			drawOrigin.x+=diffx;
			drawOrigin.y+=diffy;
		} else if(_orientation==90) {
			drawOrigin.x+=diffy;
			drawOrigin.y-=diffx;
		} else if(_orientation==-90) {
			drawOrigin.x-=diffy;
			drawOrigin.y+=diffx;
		} else { //180
			drawOrigin.x-=diffx;
			drawOrigin.y-=diffy;
		}
		[self setNeedsDisplay];
	}

}

- (PositionObj*)getPositionFromPixel:(float)x andY:(float)y {
	PositionObj *ret=[[[PositionObj alloc] init ] autorelease];
	int tx,ty,xoff,yoff;

	[MapView getXYfrom:pos.x andLon:pos.y toPositionX:&tx andY:&ty withZoom:zoom];
	[self getXYOffsetfrom:pos.x andLon:pos.y toPositionX:&xoff andY:&yoff withZoom:zoom];
	NSLog(@"x y %d %d",tx,ty);
	//Calculate the x and y offset of the first tile corresponding to the correct lat/lon
	//The pos.x and pos.y will be the center of the screen
	CGRect rect=[self frame];
	float centerTilePosY=rect.size.height/2.0-(yoff/TILE_SIZE)*dynTileSize;
	float centerTilePosX=rect.size.width/2.0-(xoff/TILE_SIZE)*dynTileSize;

	float diffx=(x-centerTilePosX);
	float diffy=(y-centerTilePosY);
	NSLog(@"diffx diffy %f %f",diffx,diffy);
	int nbplusX=diffx/dynTileSize;
	int nbplusY=diffy/dynTileSize;
	tx+=nbplusX;
	ty+=nbplusY;
	diffx-=nbplusX*dynTileSize;
	diffy-=nbplusY*dynTileSize;

	if(diffx<0) {
		tx--;
		diffx=dynTileSize+diffx;
	}
	if(diffy<0) {
		ty--;
		diffy=dynTileSize+diffy;
	}
	NSLog(@"x y diffx diffy: %d %d %f %f",tx,ty,diffx,diffy);
	xoff=diffx;
	yoff=diffy;
	float lat,lon;
	[MapView getLatLonfromXY:tx andY:ty withXOffset:xoff andYOffset:yoff toLat:&lat andLon:&lon withZoom:zoom];
	//	NSLog(@"Dyn tile size: %f",dynTileSize/TILE_SIZE);

	//NSLog(@"Before: %f %f, after: %f %f",pos.x,pos.y,lat,lon);
	ret.x=lat;
	ret.y=lon;

	return ret;
}
-(void)setPassDoubleFingersEvent:(BOOL)val {
	passDoubleFingersEvent=val;
}

+(float)getMetersPerPixel:(float)latitude zoom:(int)zoom {
	float radius=6378200; //m, at equator
	float real_radius=radius*cos(latitude*(M_PI/180.0));
	float circ=2*M_PI*real_radius; //Circumference
	float res = circ / (TILE_SIZE * pow(2,17-zoom));
	return res;
}
-(float)getMetersPerPixel:(float)latitude {
	float radius=6378200; //m, at equator
	float real_radius=radius*cos(latitude*(M_PI/180.0));
	float circ=2*M_PI*real_radius; //Circumference
	float res = circ / (TILE_SIZE * pow(2,17-zoom));
	return res;
}
-(PositionObj*)getCurrentPos {
	return pos;
}
+ (void)getLatLonfromXY:(int)x andY:(int)y withXOffset:(int)xoff andYOffset:(int)yoff toLat:(float*)lat andLon:(float*)lon withZoom:(int)zoom {
	int zl = 17 - zoom;
	float DegreePerPixel = 360.0 / (1 << (zl + 8));

	float tmp = xoff * DegreePerPixel+((x<<zoom)*360.0)/131072.0 - 180.0; //131072.0=2^17
	*lon = tmp;

	float iY = y;
	iY = iY + yoff / 256.0;
	iY = iY / (1 << zl);
	iY = iY * (2 * M_PI);
	iY = M_PI - iY;
	float LatRad = 2 *atan(exp(iY));
	*lat = LatRad * (180 / M_PI) - 90;
}
+ (void)getXYfrom:(float)lat andLon:(float)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom {
	float ty;

	while (lon> 180) lon -= 360;
	while (lon<-180) lon += 360;

	int tmpx = (int)(((lon+180.0) / 360.0) * 131072.0); //131072.0=2^17
	*x = (tmpx >> zoom);

	if (lat> 90) lat = lat - 180;
	if (lat < -90) lat = lat + 180;

	lat = lat / 180.0 * M_PI;
	ty = M_PI - 0.5 * log((1.0 + sin(lat)) / (1.0 - sin(lat)));
	int tmpy = (int)((ty / 2.0 / M_PI) * 131072.0);
	tmpy=tmpy >> zoom;

	*y=tmpy;
}
- (void)getXYOffsetfrom:(float)lat andLon:(float)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2 {
	float ty;
	float latici=lat;
	//float lonici=lon;
	float tmpx = ((((lon+180.0) / 360.0) * 131072.0)*(TILE_SIZE))/pow(2,zoom2);
	//NSLog(@"Offset x: tmpx=%f",tmpx);
	*x=(int)fmod(tmpx,TILE_SIZE);
	//NSLog(@"Lat 1=%f",lat);
	latici = (lat / 180.0) * M_PI;
	//NSLog(@"Lat 2=%f",lat);
	ty=sin(latici);
	ty=(1.0 + ty) / (1.0 - ty);
	ty=-0.5*log(ty);
	ty+=M_PI;
	float tmpy = (((ty / 2.0 / M_PI) * 131072.0)*(TILE_SIZE))/pow(2,zoom2);
	//NSLog(@"1-sin=%f",1.0 - sin(lat));
	//NSLog(@"Offset y: tmpy=%f, ty=%f = %f",tmpy,ty,(1.0 + sin(lat)) / (1.0 - sin(lat)));
	
	*y=(int)fmod(tmpy,TILE_SIZE);
}
- (void)drawRect:(CGRect)rect {
	
	//TODO: we currently assume that rect if the full screen !
	int winWidth=rect.size.width;
	int winHeight=rect.size.height;

	// Drawing code
	//NSLog(@"Drawing Map with rect size: %f %f and pos %f %f",rect.size.width,rect.size.height,rect.origin.x,rect.origin.y);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint org;
	int x,y;
	int xoff,yoff;

	CGContextSetRGBFillColor(context, 0.53, 0.53, 0.53, 1);
	CGContextFillRect(context,rect);

	[MapView getXYfrom:pos.x andLon:pos.y toPositionX:&x andY:&y withZoom:zoom];
	[self getXYOffsetfrom:pos.x andLon:pos.y toPositionX:&xoff andY:&yoff withZoom:zoom];
	
	int centerTileX=x;
	int centerTileY=y;

	//Calculate the x and y offset of the first tile corresponding to the correct lat/lon
	//The pos.x and pos.y will be the center of the screen
	float centerTilePosY=winHeight/2.0-(yoff/TILE_SIZE)*dynTileSize;
	float centerTilePosX=winWidth/2.0-(xoff/TILE_SIZE)*dynTileSize;

	//Try to search the tile x,y which will be put in the top left corner and where exactly.
	int nbTileInX=ceil((float)centerTilePosX/dynTileSize);
	int nbTileInY=ceil((float)centerTilePosY/dynTileSize);
	//NSLog(@"nb x y: %d;%d",nbTileInX,nbTileInY);
	x=x-nbTileInX;
	y=y-nbTileInY;

	//Try to search the pos of the left top tile
	org.x=centerTilePosX-nbTileInX*dynTileSize;
	org.y=centerTilePosY-nbTileInY*dynTileSize;

	//Move the origin
	org.x+=drawOrigin.x;
	org.y+=drawOrigin.y;
	//	NSLog(@"lat lon: %g;%g and x y: %ld;%ld",pos.x,pos.y,x,y);
	//CGContextRotateCTM(context,_orientation*M_PI/180.0);

	float widthDraw=rect.size.width;
	float heightDraw=rect.size.height;
	CGContextScaleCTM(context, 1, -1);
		
	//NSLog(@"Before x y: %d;%d %f %f Offset: %d %d, zoom=%d",x,y,pos.x,pos.y,xoff,yoff,zoom);
	int nbTiles=pow(2,17-zoom);
	//NSLog(@"x y: %d;%d %f %f Offset: %d %d, zoom=%d",x,y,pos.x,pos.y,xoff,yoff,zoom);
	//CGContextRotateCTM(context,M_PI/2.0);
	while(org.x<widthDraw) {
		int orgyTile=y;
		int orgy=org.y;
		while(org.y<heightDraw) {
			if(x<0) {
				x=nbTiles+x;
				
			}
			x = fmod(x,nbTiles);
			//y= fmod(y,nbTiles);
			
			if(y<nbTiles && y>=0) {
				
				
			
			//Try to load the tile from cache
			NSString *key=[NSString stringWithFormat:@"%d:%d",x,y];

			MapTile* t=[tilescache valueForKey:key];
			//NSLog(@"Getting x y: %d;%d",x,y);
			if(t==nil && dragging==NO) {
				t=[db getTile:x atY:y withZoom:zoom];
				
				if(t!=nil) {
					//Add to the cache
					[tilescache setValue:t forKey:key];
					[t release];
				} else {
					NSLog(@"Error getting tile from TileDB engine %@",db);
					t=tileNoMap;
				}
			}
				
			
			
			if(t!=nil) {
				//[t drawAtPoint: CGPointMake(org.x,org.y + dynTileSize) withContext:context];

				[t drawInRect: CGRectMake(org.x,org.y + dynTileSize,dynTileSize,dynTileSize) withContext:context];
				//[t drawInRect: CGRectMake(-org.y - dynTileSize,org.x,dynTileSize,dynTileSize) withContext:context];
			} else {
				//NSLog(@"No map");
				//[tileNoMap drawAtPoint: CGPointMake(org.x,org.y + TILE_SIZE) withContext:context];
			}
				}
			y++;
			/*CGContextScaleCTM(context, 1, -1);
			 CGContextBeginPath(context);
			 CGPoint points[5];
			 points[0]=org;
			 points[1].x=org.x;
			 points[1].y=org.y+TILE_SIZE;
			 points[2].x=org.x+TILE_SIZE;
			 points[2].y=org.y+TILE_SIZE;
			 points[3].x=org.x+TILE_SIZE;
			 points[3].y=org.y;
			 points[4].x=org.x;
			 points[4].y=org.y;
			 CGContextAddLines(context,points,5);
			 CGContextClosePath(context);
			 CGContextDrawPath(context,kCGPathStroke);
			 CGContextScaleCTM(context, 1, -1);*/
			org.y+=dynTileSize;
		}
		x++;
		y=orgyTile;
		org.y=orgy;
		org.x+=dynTileSize;

	}

	//Flush memory cache if too big
	if([tilescache count]>64) {
		[tilescache removeAllObjects];
	}

	//NSLog(@"Cache size: %d",[tilescache count]);

	//Draw gps pos
	if(hasGPSfix) {
	int xoff2,yoff2;
	[MapView getXYfrom:posGPS.x andLon:posGPS.y toPositionX:&x andY:&y withZoom:zoom];
	[self getXYOffsetfrom:posGPS.x andLon:posGPS.y toPositionX:&xoff2 andY:&yoff2 withZoom:zoom];

	float posXPin=rect.size.width/2+(x-centerTileX)*dynTileSize-(xoff/TILE_SIZE)*dynTileSize+(xoff2/TILE_SIZE)*dynTileSize;
	float posYPin=(rect.size.height/2+(y-centerTileY)*dynTileSize-(yoff/TILE_SIZE)*dynTileSize+(yoff2/TILE_SIZE)*dynTileSize);

	posXPin+=drawOrigin.x;
	posYPin+=drawOrigin.y;
	//NSLog(@"Pos: %f %f",posXPin,posYPin);
	if(posXPin>=0 && posXPin<rect.size.width && posYPin>=0 && posYPin<rect.size.height) {

		[imgPinRef drawAtPoint: CGPointMake(posXPin-7, posYPin+4) withContext:context];

		//NSLog(@"Pos: %f %f",posXPin,posYPin);
	}
	}
	CGContextScaleCTM(context, 1, -1);
	/*CGContextBeginPath(context);
	CGContextAddArc(context,rect.size.width/2,rect.size.height/2,4,0,2*M_PI,0);
	CGContextClosePath(context);
	CGContextSetRGBFillColor(context, 1, 0, 0, 1);
	CGContextDrawPath(context,kCGPathFill);

	*/

	//Draw lines

	if([lines count]>1) {
		//NSLog(@"Drawing %d points",[lines count]);
		int i;
		CGContextSetRGBStrokeColor(context,0.662,0.184,1,0.64);
		CGContextSetLineWidth(context,8.0);
		CGContextSetLineJoin(context,kCGLineJoinRound);
		CGPoint points[[lines count]];
		int j=0;
		//BOOL alwaysIN=NO;
		for(i=0;i<[lines count];i++) {
			int xoffstart,yoffstart,xstart,ystart;
			PositionObj *l=[lines objectAtIndex:i];
			//NSLog(@"Drawing line %f %f - %f %f",l.start.x,l.start.y,l.end.x,l.end.y);
			[MapView getXYfrom:l.x andLon:l.y toPositionX:&xstart andY:&ystart withZoom:zoom];
			[self getXYOffsetfrom:l.x andLon:l.y toPositionX:&xoffstart andY:&yoffstart withZoom:zoom];

			float posXStart=rect.size.width/2+(xstart-centerTileX)*dynTileSize-(xoff/TILE_SIZE)*dynTileSize+(xoffstart/TILE_SIZE)*dynTileSize;
			float posYStart=(rect.size.height/2+(ystart-centerTileY)*dynTileSize-(yoff/TILE_SIZE)*dynTileSize+(yoffstart/TILE_SIZE)*dynTileSize);

			posXStart+=drawOrigin.x;
			posYStart+=drawOrigin.y;
			//	if(alwaysIN || (posXStart>=-dynTileSize && posXStart<rect.size.width+dynTileSize && posYStart>=-dynTileSize && posYStart<rect.size.height+dynTileSize)) {
			//Draw the line
			points[j]=CGPointMake(posXStart,posYStart);
			j++;
			//	alwaysIN=YES;
			//} else {
			//	alwaysIN=NO;
			//}
		}
		if(j>1) {
			CGContextBeginPath(context);
			CGContextAddLines(context,points,j);
			//CGContextClosePath(context);
			CGContextDrawPath(context,kCGPathStroke);
		}
	}

	if(nextDirection!=nil) {
		int xstart,ystart,xoffstart,yoffstart;
		[MapView getXYfrom:nextDirection.x andLon:nextDirection.y toPositionX:&xstart andY:&ystart withZoom:zoom];
		[self getXYOffsetfrom:nextDirection.x andLon:nextDirection.y toPositionX:&xoffstart andY:&yoffstart withZoom:zoom];

		float posXStart=rect.size.width/2+(xstart-centerTileX)*dynTileSize-(xoff/TILE_SIZE)*dynTileSize+(xoffstart/TILE_SIZE)*dynTileSize;
		float posYStart=(rect.size.height/2+(ystart-centerTileY)*dynTileSize-(yoff/TILE_SIZE)*dynTileSize+(yoffstart/TILE_SIZE)*dynTileSize);

		posXStart+=drawOrigin.x;
		posYStart+=drawOrigin.y;

		//Draw a circle

		CGContextSetLineWidth(context,3.0);
		CGContextSetRGBFillColor(context,0.662,0.184,1,0.4);
		CGContextSetRGBStrokeColor(context,0.662,0.184,1,0.8);
		CGContextBeginPath(context);
		CGContextAddArc(context,posXStart,posYStart,35,0,2*M_PI,0);
		CGContextStrokePath(context);
		CGContextBeginPath(context);
		CGContextAddArc(context,posXStart,posYStart,35,0,2*M_PI,0);
		CGContextFillPath(context);
	}
	CGContextScaleCTM(context, 1, -1);

	
	/*CGContextSetShouldAntialias(context,YES);
	CGContextSelectFont(context, "Helvetica",10, kCGEncodingMacRoman);

		CGContextSetTextPosition(
								 context, 80,-rect.size.height+6);
	NSString *txt=@"(C) 2008 Google, Map Data (C) TeleAtlas";
	CGContextShowText(context,[txt UTF8String],[txt length]);*/
	[imgGoogleLogo drawAtPoint:CGPointMake(rect.size.width-72,rect.size.height-2) withContext:context];
	CGContextScaleCTM(context, 1, -1);

	
	
	//CGContextSetRGBFillColor(context, 1, 0, 0, 1);
	//CGContextFillRect(context,CGRectMake(-30,30,10,10));

	//NSLog(@"Scale: %f m / pixel",[self getMetersPerPixel: pos.x]);
	//if(!dragging)
	//[dirC getNextDirection:pos];
	if(passDoubleFingersEvent)
	[[self superview] drawRect:rect];

}
-(void)setDir:(id)d {
	//dirC=d;
}
-(void)zoomin:(id)sender {
	if(zoom>0) zoom--;
	[self setNeedsDisplay];
	[sender setZoominState:zoom!=0];
	[sender setZoomoutState:zoom!=17];
}
-(void)zoomout:(id)sender {
	if(zoom<17) zoom++;
	[self setNeedsDisplay];
	[sender setZoomoutState:zoom!=17];
	[sender setZoominState:zoom!=0];
}
-(void)addDrawPoint:(PositionObj*)p {
	[lines addObject:p];
	[self setNeedsDisplay];
}
-(void)clearPoints {
	nextDirection=nil;
	
	[lines removeAllObjects];
}
- (void)dealloc {
	[lines release];
	[tileNoMap release];
	[imgPinRef release];
	[pos release];
	[posGPS release];
	[tilescache release];
	[super dealloc];
}

@end
