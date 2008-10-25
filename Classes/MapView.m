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
#define DEG_TO_RAD (M_PI/180.0f)
#define DEG2RAD(x) (x*M_PI/180.0f)
/// @brief Earth's quatratic mean radius for WGS-84
#define EARTH_RADIUS_IN_METERS 6372797.560856
@implementation MapView
@synthesize pos;
@synthesize mapRotationEnabled;
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

-(float)distanceBetween:(PositionObj*)p and:(PositionObj*)p2 {
	double latitudeArc  = (p.x - p2.x) * DEG_TO_RAD;
	double longitudeArc = (p.y - p2.y) * DEG_TO_RAD;
    double latitudeH = sin(latitudeArc * 0.5);
    latitudeH *= latitudeH;
    double lontitudeH = sin(longitudeArc * 0.5);
    lontitudeH *= lontitudeH;
    double tmp = cos(p.x*DEG_TO_RAD) * cos(p2.x*DEG_TO_RAD);
    return EARTH_RADIUS_IN_METERS * 2.0 * asin(sqrt(latitudeH + tmp*lontitudeH));	
}
- (void)updateCurrentPos:(PositionObj*) p {
	//NSLog(@"MapView - updateCurrentPos() - IN");
	//NSLog(@"MapView - updateCurrentPos() - IN with %f %f",[p x],[p y]);
	posGPS.x=[p x];
	posGPS.y=[p y];
	if(!dragging && gpsTracking) {
		pos.x=posGPS.x;
		pos.y=posGPS.y;
	}
	
	
	
	if(lastPos.x==0.0 && lastPos.y==0.0) {
		lastPos.x=p.x;
		lastPos.y=p.y;
	} else {
		
		float d=[self distanceBetween:p and:lastPos];
		if(d>4) {
			//	float header=fmod(atan2(sin(DEG2RAD(p.y-lastPos.y))*cos(DEG2RAD(p.x)),cos(DEG2RAD(lastPos.x))*sin(DEG2RAD(p.x))-sin(DEG2RAD(lastPos.x))*cos(DEG2RAD(p.x))*cos(DEG2RAD(p.y-lastPos.y))),2*M_PI);
			float lat1=lastPos.x*M_PI/180.0;
			float lat2=p.x*M_PI/180.0;
			float lon2=p.y*M_PI/180.0;
			float lon1=lastPos.y*M_PI/180.0;
			//float dLat = (lat2-lat1);
			float dLon = (lon2-lon1);
			float y = sin(dLon) * cos(lat2);
			float x = cos(lat1)*sin(lat2) -
			sin(lat1)*cos(lat2)*cos(dLon);
			float brng = atan2(y, x);
			gpsHeading=(brng);
			//NSLog(@"Heading: %f",brng*180.0/M_PI);
			if(mapRotationEnabled && gpsTracking) {
				mapRotation=(2*M_PI-brng);
			}
			lastPos.x=p.x;
			lastPos.y=p.y;
		}
		
	}
	
	[self refreshMap];
	//NSLog(@"MapView - updateCurrentPos() - OUT");
}

-(void)setZoom:(int)z {
	zoom=z;
}
-(void)fakeGPS {
	pos.x+=0.0001;
	pos.y+=0.0001;
	[self refreshMap];
}
-(id)initWithFrame:(CGRect)f withDB:(TileDB*)_db {
	if((self=[super initWithFrame:f])) {
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
		
		imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"gps_ball.png"];
		NSData *data = [NSData dataWithContentsOfFile:imageFileName];
		
		imgPinRef=[[MapTile alloc] initWithData: data];
		imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"GoogleBadge.png"];
		data = [NSData dataWithContentsOfFile:imageFileName];
		
		imgGoogleLogo=[[MapTile alloc] initWithData: data];
		mapRotationEnabled=NO;
		imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pin_pos.png"];
		data = [NSData dataWithContentsOfFile:imageFileName];
		
		imgPinSearch=[[MapTile alloc] initWithData: data];
		posSearch=[[PositionObj alloc] init];
		lastPos=[[PositionObj alloc] init];
		mapRotation=0;
		
		[self setMultipleTouchEnabled:YES];
		//	[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(updateAngle) userInfo:nil repeats:YES];
		//	self.backgroundColor=[UIColor redColor];
	}
	return self;
}
-(void)updateAngle {
	mapRotation+=M_PI/32.0;
	mapRotation=fmod(mapRotation,2*M_PI);
	[self setNeedsDisplay];
}
- (void)layoutSubviews {
	//tiledLayer.frame=self.frame;
	
}
-(void)refreshMap {
	[self setNeedsDisplay];
}
- (void)dealloc {
	[lines release];
	[tileNoMap release];
	[imgPinRef release];
	[pos release];
	[posSearch release];
	[imgGoogleLogo release];
	[posGPS release];
	[imgPinSearch release];
	[tilescache release];
	[super dealloc];
}

-(void)setDirection:(int)dir {
	direction=dir;
	[self refreshMap];
}
-(void)tileDownloaded {
	[self refreshMap];
}
-(void)setPosSearch:(PositionObj*)p {
	posSearch.x=p.x;
	posSearch.y=p.y;
	[self refreshMap];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	lastInitMove=NO;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches	withEvent:event];
	dragging=NO;
	NSSet *events=[event allTouches];
	if([events count]!=1)  return;
	//Update the lat / lon with the org offset
	
	int x,y,xoff,yoff;
	//NSLog(@"Draw org: %f %f",drawOrigin.x,drawOrigin.y);
	//NSLog(@"Current pos: %f %f",pos.x,pos.y);
	[self getXYfrom:pos.x andLon:pos.y toPositionX:&x andY:&y withZoom:zoom];
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
	
	[self getLatLonfromXY:x andY:y withXOffset:offx_after andYOffset:offy_after toLat:&lat andLon:&lon withZoom:zoom];
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
	[self refreshMap];
	
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	static CGPoint lastT1, lastT2;
	
	[super touchesMoved:touches withEvent:event];
	
	NSSet *events=[event allTouches];
	NSEnumerator *enumerator = [events objectEnumerator];
	UITouch* value;
	//NSLog(@"Nb finger mapview: %d",[events count]);
	if([events count]>2)
		return;
	if([events count]==1) {
		while ((value = [enumerator nextObject])) {
			/*if(lastTouch!=nil){
			 CGPoint c = [value locationInView:self];
			 CGPoint c2 = [lastTouch locationInView:self];
			 NSLog(@"Delta T: %f",lastTouch.timestamp-value.timestamp);
			 NSLog(@"Delta D: %f",sqrt((c.x-c2.x)*(c.x-c2.x)+(c.y-c2.y)*(c.y-c2.y)));
			 }*/
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
			
			drawOrigin.x+=diffy*sin(mapRotation)+diffx*cos(mapRotation);
			drawOrigin.y+=diffy*cos(mapRotation)-diffx*sin(mapRotation);
			
			/*if(lastTouch!=nil) [lastTouch release];
			 lastTouch=[value retain];*/
			[self refreshMap];
			//tiledLayer.position=CGPointMake(tiledLayer.position.x+diffx,tiledLayer.position.y+diffy);
			
			break;
		}
	} else if([events count]==2 && mapRotationEnabled) {
		UITouch* t1=[enumerator nextObject];
		UITouch* t2=[enumerator nextObject];
		CGPoint c1 = [t1 locationInView:self];
		CGPoint c2 = [t2 locationInView:self];
		if(lastInitMove==NO) {
			lastInitMove=YES;	
			lastT1.x=c1.x;
			lastT1.y=c1.y;
			lastT2.x=c2.x;
			lastT2.y=c2.y;
			return;
		}
		
		
		//Angle between the two vectors
		CGPoint v1=CGPointMake(c1.x-c2.x,c1.y-c2.y);
		CGPoint v2=CGPointMake(lastT1.x-lastT2.x,lastT1.y-lastT2.y);
		float cos_a=(v1.x*v2.x+v1.y*v2.y)/(sqrt(v1.x*v1.x+v1.y*v1.y)*sqrt(v2.x*v2.x+v2.y*v2.y));
		float a=acos(cos_a);
		
		//Check the rotation "sense"
		//Vectorial product
		float vectProd=v1.x*v2.y-v2.x*v1.y;
		if(vectProd>=0)
			a*=-1;
		//NSLog(@"Alpha=%f",a);
		mapRotation+=a;
		mapRotation=fmod(mapRotation,2*M_PI);
		lastT1.x=c1.x;
		lastT1.y=c1.y;
		lastT2.x=c2.x;
		lastT2.y=c2.y;
		[self refreshMap];
		
	}
}

- (PositionObj*)getPositionFromPixel:(float)x andY:(float)y {
	PositionObj *ret=[[[PositionObj alloc] init ] autorelease];
	int tx,ty,xoff,yoff;
	
	[self getXYfrom:pos.x andLon:pos.y toPositionX:&tx andY:&ty withZoom:zoom];
	[self getXYOffsetfrom:pos.x andLon:pos.y toPositionX:&xoff andY:&yoff withZoom:zoom];
	//NSLog(@"x y %d %d",tx,ty);
	//Calculate the x and y offset of the first tile corresponding to the correct lat/lon
	//The pos.x and pos.y will be the center of the screen
	CGRect rect=[self frame];
	float centerTilePosY=rect.size.height/2.0-(yoff/TILE_SIZE)*dynTileSize;
	float centerTilePosX=rect.size.width/2.0-(xoff/TILE_SIZE)*dynTileSize;
	
	float diffx=(x-centerTilePosX);
	float diffy=(y-centerTilePosY);
	//NSLog(@"diffx diffy %f %f",diffx,diffy);
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
	//NSLog(@"x y diffx diffy: %d %d %f %f",tx,ty,diffx,diffy);
	xoff=diffx;
	yoff=diffy;
	float lat,lon;
	[self getLatLonfromXY:tx andY:ty withXOffset:xoff andYOffset:yoff toLat:&lat andLon:&lon withZoom:zoom];
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
-(void)setGPSTracking:(BOOL)val {
	gpsTracking=val;
}
- (void)getLatLonfromXY:(int)x andY:(int)y withXOffset:(int)xoff andYOffset:(int)yoff toLat:(float*)lat andLon:(float*)lon withZoom:(int)zoom2 {
	int zl = 17 - zoom2;
	float DegreePerPixel = 360.0 / (1 << (zl + 8));
	
	float tmp = xoff * DegreePerPixel+((x<<zoom2)*360.0)/131072.0 - 180.0; //131072.0=2^17
	*lon = tmp;
	
	float iY = y;
	iY = iY + yoff / 256.0;
	iY = iY / (1 << zl);
	iY = iY * (2 * M_PI);
	iY = M_PI - iY;
	float LatRad = 2 *atan(exp(iY));
	*lat = LatRad * (180 / M_PI) - 90;
}
- (void)getXYfrom:(float)lat andLon:(float)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2 {
	float ty;
	
	while (lon> 180) lon -= 360;
	while (lon<-180) lon += 360;
	
	int tmpx = (int)(((lon+180.0) / 360.0) * 131072.0); //131072.0=2^17
	*x = (tmpx >> zoom2);
	
	if (lat> 90) lat = lat - 180;
	if (lat < -90) lat = lat + 180;
	
	lat = lat / 180.0 * M_PI;
	ty=(1.0 + sin(lat)) / (1.0 - sin(lat));
	ty=log(ty);
	ty = 0.5 * ty;
	ty=M_PI-ty;
	int tmpy = (int)((ty / 2.0 / M_PI) * 131072.0);
	tmpy=tmpy >> zoom2;
	
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
#if 1
- (void)drawRect:(CGRect)rect{
	//NSLog(@"Drawing at %f°",mapRotation/M_PI*180.0);
	//TODO: we currently assume that rect if the full screen !
	int winWidth=rect.size.width;
	int winHeight=rect.size.height;
	
	if(!mapRotationEnabled)
		mapRotation=0;
	
	// Drawing code
	//NSLog(@"Drawing Map with rect size: %f %f and pos %f %f",rect.size.width,rect.size.height,rect.origin.x,rect.origin.y);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	
	CGContextSetRGBFillColor(context, 0.53, 0.53, 0.53, 1);
	CGContextFillRect(context,rect);
	
	
	CGContextTranslateCTM(context,rect.size.width/2.0,rect.size.height/2.0);
	CGAffineTransform rot=CGAffineTransformMakeRotation(mapRotation);
	//CGAffineTransform trans=CGAffineTransformMakeTranslation(-rect.size.width/2.0,-rect.size.height/2.0);
	CGContextConcatCTM(context, rot);
	//CGContextConcatCTM(context, trans);
	//NSLog(@"CTM Done");
	
	CGPoint org;
	int x,y;
	int xoff,yoff;
	
	[self getXYfrom:pos.x andLon:pos.y toPositionX:&x andY:&y withZoom:zoom];
	[self getXYOffsetfrom:pos.x andLon:pos.y toPositionX:&xoff andY:&yoff withZoom:zoom];
	
	int centerTileX=x;
	int centerTileY=y;
	
	//The pos.x and pos.y will be the center of the screen
	//The center tile position will then be at the following position:s
	//float centerTilePosY=winHeight/2.0-(yoff/TILE_SIZE)*dynTileSize;
	//float centerTilePosX=winWidth/2.0-(xoff/TILE_SIZE)*dynTileSize;
	float centerTilePosX=drawOrigin.x-(xoff/TILE_SIZE)*dynTileSize;
	float centerTilePosY=drawOrigin.y-(yoff/TILE_SIZE)*dynTileSize;
	
	//float centerTilePosX2=centerTilePosY*sin(mapRotation)+centerTilePosX*cos(mapRotation);
	//float centerTilePosY2=centerTilePosY*cos(mapRotation)-centerTilePosX*sin(mapRotation);
	//centerTilePosX=centerTilePosX2;
	//centerTilePosY=centerTilePosY2;
	//Try to search the tile x,y which will be put in the top left corner and where exactly.
	//int nbTileInX=ceil((float)centerTilePosX/dynTileSize);
	//int nbTileInY=ceil((float)centerTilePosY/dynTileSize);
	//NSLog(@"nb x y: %d;%d",nbTileInX,nbTileInY);
	//x=x-nbTileInX;
	//y=y-nbTileInY;
	
	//Try to search the pos of the left top tile
	//org.x=centerTilePosX-nbTileInX*dynTileSize;
	//org.y=centerTilePosY-nbTileInY*dynTileSize;
	
	//Move the origin
	org.x=centerTilePosX;
	org.y=centerTilePosY;
	//	NSLog(@"lat lon: %g;%g and x y: %ld;%ld",pos.x,pos.y,x,y);
	//CGContextRotateCTM(context,_orientation*M_PI/180.0);
	
	float widthDraw=0;
	float heightDraw=0;
	
	
	float widthDraw2=0;
	float heightDraw2=0;
	
	widthDraw2=widthDraw=heightDraw=heightDraw2=sqrt(winWidth*winWidth/4+winHeight*winHeight/4);
	
	int nbTileInX=ceil((float)widthDraw2/dynTileSize);
	int nbTileInY=ceil((float)heightDraw2/dynTileSize);
	x=x-nbTileInX;
	y=y-nbTileInY;
	org.x=centerTilePosX-nbTileInX*dynTileSize;
	org.y=centerTilePosY-nbTileInY*dynTileSize;
	
	//float heightDraw=sqrt(winWidth*winWidth+winHeight*winHeight)/2;
	
	//float orgAngleY=cos(M_PI/2-mapRotation)*rect.size.width;
	//float orgAngleX=cos(M_PI/2-mapRotation)*rect.size.height;
	//float orgAngleX=
	//org.y-=orgAngleY;
	//org.x-=orgAngleX;
	CGContextScaleCTM(context, 1, -1);
	
	//NSLog(@"Before x y: %d;%d %f %f Offset: %d %d, zoom=%d",x,y,pos.x,pos.y,xoff,yoff,zoom);
	int nbTiles=pow(2,17-zoom);
	//NSLog(@"x y: %d;%d %f %f Offset: %d %d, zoom=%d",x,y,pos.x,pos.y,xoff,yoff,zoom);
	//CGContextRotateCTM(context,M_PI/2.0);
	float marginy=0;
	
	while(org.y<heightDraw) {
		int orgxTile=x;
		float orgx=org.x;
		float marginx=0;
		if(y<nbTiles && y>=0) {
			while(org.x<widthDraw) {
				if(x<0) {
					x=nbTiles+x;
				}
				x = fmod(x,nbTiles);
				NSString *key=[NSString stringWithFormat:@"%d:%d:%d",x,y,zoom];
				
				MapTile* t=[tilescache objectForKey:key];
				//NSLog(@"Getting x y: %d;%d",x,y);
				if(t==nil && dragging==NO) {
					t=[db getTile:x atY:y withZoom:zoom withDelegate:self];
					
					if(t!=nil) {
						//Add to the cache
						[tilescache setObject:t forKey:key];
						[t release];
					} else {
						//NSLog(@"Error getting tile from TileDB engine %@",db);
						t=tileNoMap;
					}
				}
				
				
				if(t!=nil) {
					[t drawInRect: CGRectMake(org.x+marginx,org.y+marginy + dynTileSize,dynTileSize,dynTileSize) withContext:context];
				}
				marginx-=1;
				
				/* CGContextScaleCTM(context, 1, -1);
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
				org.x+=dynTileSize;
				x++;
			}
		}
		org.x=orgx;
		marginy-=1;
		org.y+=dynTileSize;
		x=orgxTile;
		y++;
		
	}
	
	//Flush memory cache if too big
	if([tilescache count]>128) {
		[tilescache removeAllObjects];
	}
	
	//NSLog(@"Cache size: %d",[tilescache count]);
	
	//Draw gps pos
	if(hasGPSfix) {
		int xoff2,yoff2;
		[self getXYfrom:posGPS.x andLon:posGPS.y toPositionX:&x andY:&y withZoom:zoom];
		[self getXYOffsetfrom:posGPS.x andLon:posGPS.y toPositionX:&xoff2 andY:&yoff2 withZoom:zoom];
		
		float posXPin=drawOrigin.x+(x-centerTileX)*dynTileSize-(xoff/TILE_SIZE)*dynTileSize+(xoff2/TILE_SIZE)*dynTileSize;
		float posYPin=drawOrigin.y+(y-centerTileY)*dynTileSize-(yoff/TILE_SIZE)*dynTileSize+(yoff2/TILE_SIZE)*dynTileSize;
		//NSLog(@"Pos: %f %f",posXPin,posYPin);
		float posXPin2=cos(mapRotation)*posXPin - posYPin*sin(mapRotation);
		float posYPin2=sin(mapRotation)*posXPin + posYPin*cos(mapRotation);
		if(posXPin2>=-winWidth/2.0 && posXPin2<winWidth/2 && posYPin2>=-winHeight/2 && posYPin2<winHeight/2) {
			
			//Project
			//CGContextTranslateCTM(context,rect.size.width/2.0,rect.size.height/2.0);
			
			
			
			CGContextScaleCTM(context, 1, -1);
			//CGContextRotateCTM(context, -mapRotation);
			// CGContextScaleCTM(context, 1, -1);
			// [imgPinRef drawAtPoint: CGPointMake(posXPin2-7.5, posYPin2+7.5) withContext:context];
			// CGContextScaleCTM(context, 1, -1);
			CGContextRotateCTM(context, gpsHeading);
			
			CGPoint ind[4];
			ind[0].x=posXPin;
			ind[0].y=posYPin+10;
			ind[1].x=posXPin-20;
			ind[1].y=posYPin+20*0.666+10;
			ind[2].x=posXPin;
			ind[2].y=posYPin-40+10;
			ind[3].x=posXPin+20;
			ind[3].y=posYPin+20*0.666+10;
			CGContextBeginPath(context);
			CGContextAddLines(context,ind,4);
			CGContextClosePath(context);
			CGContextSetRGBFillColor(context,0,1,0,0.6);
			CGContextFillPath(context);
			CGContextBeginPath(context);
			CGContextAddArc(context,posXPin,posYPin,6,0,2*M_PI,0);
			CGContextClosePath(context);
			CGContextSetRGBFillColor(context,0,1,0,1);
			CGContextFillPath(context);
			CGContextRotateCTM(context, -gpsHeading);
			// CGContextRotateCTM(context, mapRotation);
			CGContextScaleCTM(context, 1, -1);
			
			//NSLog(@"Pos: %f %f",posXPin,posYPin);
		}
	}
	if(posSearch.x!=0.0f && posSearch.y!=0.0f) {
		int xoff2,yoff2;
		[self getXYfrom:posSearch.x andLon:posSearch.y toPositionX:&x andY:&y withZoom:zoom];
		[self getXYOffsetfrom:posSearch.x andLon:posSearch.y toPositionX:&xoff2 andY:&yoff2 withZoom:zoom];
		
		
		float posXPin=drawOrigin.x+(x-centerTileX)*dynTileSize-(xoff/TILE_SIZE)*dynTileSize+(xoff2/TILE_SIZE)*dynTileSize;
		float posYPin=drawOrigin.y+(y-centerTileY)*dynTileSize-(yoff/TILE_SIZE)*dynTileSize+(yoff2/TILE_SIZE)*dynTileSize;
		float posXPin2=cos(mapRotation)*posXPin - posYPin*sin(mapRotation);
		float posYPin2=sin(mapRotation)*posXPin + posYPin*cos(mapRotation);
		
		
		//NSLog(@"Pos: %f %f",posXPin,posYPin);
		if(posXPin2>=-winWidth/2.0 && posXPin2<winWidth/2 && posYPin2>=-winHeight/2 && posYPin2<winHeight/2) {		
			CGContextScaleCTM(context, 1, -1);
			CGContextRotateCTM(context, -mapRotation);
			CGContextScaleCTM(context, 1, -1);
			[imgPinSearch drawAtPoint: CGPointMake(posXPin2-7.5, posYPin2+5) withContext:context];
			CGContextScaleCTM(context, 1, -1);
			CGContextRotateCTM(context, mapRotation);
			CGContextScaleCTM(context, 1, -1);
			
		}
	}
	
	CGContextScaleCTM(context, 1, -1);
	CGContextRotateCTM(context, -mapRotation);
	
	
	
	/*CGContextBeginPath(context);
	 CGContextAddArc(context,rect.size.width/2,rect.size.height/2,4,0,2*M_PI,0);
	 CGContextClosePath(context);
	 CGContextSetRGBFillColor(context, 1, 0, 0, 1);
	 CGContextDrawPath(context,kCGPathFill);
	 
	 
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
	 }	*/
	/*
	 CGContextBeginPath(context);
	 CGContextAddArc(context,0,0,4,0,2*M_PI,0);
	 CGContextClosePath(context);
	 CGContextSetRGBFillColor(context, 1, 0, 0, 1);
	 CGContextDrawPath(context,kCGPathFill);
	 CGContextBeginPath(context);
	 CGContextAddArc(context,20,0,4,0,2*M_PI,0);
	 CGContextClosePath(context);
	 CGContextSetRGBFillColor(context, 0, 1, 0, 1);
	 CGContextDrawPath(context,kCGPathFill);
	 
	 CGContextBeginPath(context);
	 CGContextAddArc(context,0,20,4,0,2*M_PI,0);
	 CGContextClosePath(context);
	 CGContextSetRGBFillColor(context, 0, 0, 1, 1);
	 CGContextDrawPath(context,kCGPathFill);
	 */
	
	//CGContextTranslateCTM(context,rect.size.width/2.0,rect.size.height/2.0);
	//rot=CGAffineTransformMakeRotation(-mapRotation);
	CGAffineTransform trans=CGAffineTransformMakeTranslation(-rect.size.width/2.0,-rect.size.height/2.0);
	//CGContextConcatCTM(context, rot);
	CGContextConcatCTM(context, trans);
	CGContextScaleCTM(context, 1, -1);
	
	
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
#endif

-(void)setDir:(id)d {
	//dirC=d;
}
-(void)zoomin:(id)sender {
	if(zoom>0) zoom--;
	
	//[UIView beginAnimations:nil context:nil];
	//self.transform=CGAffineTransformMakeScale(0.5,0.5);
	//[UIView commitAnimations];
	
	[self refreshMap];
	
	[sender setZoominState:zoom!=0];
	[sender setZoomoutState:zoom!=17];
}
-(void)zoomout:(id)sender {
	if(zoom<17) zoom++;
	[self refreshMap];
	
	[sender setZoomoutState:zoom!=17];
	[sender setZoominState:zoom!=0];
}
-(void)addDrawPoint:(PositionObj*)p {
	[lines addObject:p];
	[self refreshMap];
}
-(void)clearPoints {
	nextDirection=nil;
	
	[lines removeAllObjects];
}
-(void)allTileDownloaded {
	
}
@end
