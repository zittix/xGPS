//
//  MapView.m
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "MainViewController.h"
#import "MapView.h"
#import "xGPSAppDelegate.h"
#undef NAN
#define NAN -10e8
#define DEG_TO_RAD (M_PI/180.0f)
#define DEG2RAD(x) (x*M_PI/180.0f)
/// @brief Earth's quatratic mean radius for WGS-84
#define EARTH_RADIUS_IN_METERS 6372797.560856
@implementation MapView
@synthesize pos;
@synthesize mapRotationEnabled;
@synthesize assocZoomview;
//@synthesize debugRoadStep;
@synthesize pEndForMapSelection;
@synthesize pDepForMapSelection;
-(void)setHasGPSPos:(BOOL)val {
	hasGPSfix=val;
}
-(void)setNextInstruction:(Instruction*)i updatePos:(BOOL)b {
	if(i!=nil) {
		posDrivingInstruction.x=i.pos.x;
		posDrivingInstruction.y=i.pos.y;
		if(b) {
			self.pos.x=posDrivingInstruction.x;
			self.pos.y=posDrivingInstruction.y;	
		}
	} else {
		posDrivingInstruction.x=posDrivingInstruction.y=0;
	}
	[self refreshMap];
}

-(double)distanceBetween:(PositionObj*)p and:(PositionObj*)p2 {
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
		
		double d=[self distanceBetween:p and:lastPos];
		if(d>4) {
			double lat1=lastPos.x*M_PI/180.0;
			double lat2=p.x*M_PI/180.0;
			double lon2=p.y*M_PI/180.0;
			double lon1=lastPos.y*M_PI/180.0;
			double dLon = (lon2-lon1);
			double y = sin(dLon) *cos(lat2);
			double x = cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(dLon);
			double brng = atan2(y, x);
			gpsHeading=(brng);
			//NSLog(@"Heading: %f",brng*180.0/M_PI);
			if(mapRotationEnabled && gpsTracking) {
				float toRotate=fabs((2*M_PI-brng)-mapRotation);
				if(toRotate>0.34f)
				mapRotation=(2*M_PI-brng);
			}
			lastPos.x=p.x;
			lastPos.y=p.y;
		}
		
	}
	
	[self refreshMap];
	//NSLog(@"MapView - updateCurrentPos() - OUT");
}
-(int)zoom {
	return zoom;
}
-(void)setZoom:(int)z {
	zoom=z;
	[assocZoomview setZoomoutState:zoom!=16];
	[assocZoomview setZoominState:zoom!=0];
}

-(id)initWithFrame:(CGRect)f withDB:(TileDB*)_db {
	if((self=[super initWithFrame:f])) {
		//NSLog(@"Loading MapView");
		db=_db;
		hasGPSfix=NO;
		dragging=NO;
		//_orientation=90;
		zoom=0;
		prevDist=NAN;
		posDrivingInstruction=[[PositionObj alloc] init];
		lastDragPoint.x=NAN;
		lastDragPoint.y=NAN;
		tilescache=[[NSMutableDictionary dictionaryWithCapacity:64] retain];
		pos=[[PositionObj alloc] init];
		
		posGPS=[[PositionObj alloc] init];
		drawOrigin.x=drawOrigin.y=0;
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
		//debugRoadStep=-1;
		[self setMultipleTouchEnabled:YES];
		useGPSBall=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsUseGPSBall];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gpsBallChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
		
	}
	return self;
}
-(void)gpsBallChanged:(NSNotification *)notif {
	useGPSBall=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsUseGPSBall];
	mapRotationEnabled=![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapRotation];
	[self refreshMap];
}

-(void)refreshMap {
	[self setNeedsDisplay];
}
- (void)dealloc {
	[tileNoMap release];
	[imgPinRef release];
	[pos release];
	[posSearch release];
	[imgGoogleLogo release];
	[posGPS release];
	[imgPinSearch release];
	[tilescache release];
	[posDrivingInstruction release];
	[super dealloc];
}

-(void)tileDownloaded {
	[self refreshMap];
}
-(void)setPosSearch:(PositionObj*)p {
	if(p!=nil) {
		posSearch.x=p.x;
		posSearch.y=p.y;
	} else {
		posSearch.x=posSearch.y=0;
	}
	[self refreshMap];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	lastInitMove=NO;
	NSSet *events=[event allTouches];
	if([events count]>0) {
		NSEnumerator *enumerator = [events objectEnumerator];
		UITouch *value = [enumerator nextObject];
		
		
		if(value.tapCount==2 && [events count]==1) {
			if(zoom>0) {
				zoom--;
				[assocZoomview setZoomoutState:zoom!=16];
				[assocZoomview setZoominState:zoom!=0];
				[self computeCachedRoad];
				[self refreshMap];
			}
		}
		if([events count]==2) {
			UITouch *value2 = [enumerator nextObject];
			if(zoom<16 && (value2.tapCount==2 || value.tapCount==2)) {
				zoom++;
				[assocZoomview setZoomoutState:zoom!=16];
				[assocZoomview setZoominState:zoom!=0];
				[self computeCachedRoad];
				[self refreshMap];
			}
		}
	}
	
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
	double lat,lon;
	
	[self getLatLonfromXY:x andY:y withXOffset:offx_after andYOffset:offy_after toLat:&lat andLon:&lon withZoom:zoom];
	//	NSLog(@"Dyn tile size: %f",dynTileSize/TILE_SIZE);
	
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
		double cosr=cos(mapRotation);
		double sinr=sin(mapRotation);
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
			
			double diffx=c.x-lastDragPoint.x;
			double diffy=c.y-lastDragPoint.y;
			lastDragPoint.x=c.x;
			lastDragPoint.y=c.y;
			
			drawOrigin.x+=diffy*sinr+diffx*cosr;
			drawOrigin.y+=diffy*cosr-diffx*sinr;
			
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
		double cos_a=(v1.x*v2.x+v1.y*v2.y)/(sqrt(v1.x*v1.x+v1.y*v1.y)*sqrt(v2.x*v2.x+v2.y*v2.y));
		double a=acos(cos_a);
		
		//Check the rotation "sense"
		//Vectorial product
		double vectProd=v1.x*v2.y-v2.x*v1.y;
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

- (PositionObj*)getPositionFromPixel:(double)x andY:(double)y {
	PositionObj *ret=[[[PositionObj alloc] init ] autorelease];
	int tx,ty,xoff,yoff;
	
	[self getXYfrom:pos.x andLon:pos.y toPositionX:&tx andY:&ty withZoom:zoom];
	[self getXYOffsetfrom:pos.x andLon:pos.y toPositionX:&xoff andY:&yoff withZoom:zoom];
	//NSLog(@"x y %d %d",tx,ty);
	//Calculate the x and y offset of the first tile corresponding to the correct lat/lon
	//The pos.x and pos.y will be the center of the screen
	CGRect rect=[self frame];
	double centerTilePosY=rect.size.height/2.0-(yoff);
	double centerTilePosX=rect.size.width/2.0-(xoff);
	
	double diffx=(x-centerTilePosX);
	double diffy=(y-centerTilePosY);
	//NSLog(@"diffx diffy %f %f",diffx,diffy);
	int nbplusX=diffx/TILE_SIZE;
	int nbplusY=diffy/TILE_SIZE;
	tx+=nbplusX;
	ty+=nbplusY;
	diffx-=nbplusX*TILE_SIZE;
	diffy-=nbplusY*TILE_SIZE;
	
	while(diffx<0) {
		tx--;
		diffx=TILE_SIZE+diffx;
	}
	while(diffy<0) {
		ty--;
		diffy=TILE_SIZE+diffy;
	}
	//NSLog(@"x y diffx diffy: %d %d %f %f",tx,ty,diffx,diffy);
	xoff=diffx;
	yoff=diffy;
	double lat,lon;
	[self getLatLonfromXY:tx andY:ty withXOffset:xoff andYOffset:yoff toLat:&lat andLon:&lon withZoom:zoom];
	//	NSLog(@"Dyn tile size: %f",dynTileSize/TILE_SIZE);
	
	//NSLog(@"Before: %f %f, after: %f %f",pos.x,pos.y,lat,lon);
	ret.x=lat;
	ret.y=lon;
	
	return ret;
}

+(double)getMetersPerPixel:(double)latitude zoom:(int)zoom {
	double radius=6378200; //m, at equator
	double real_radius=radius*cos(latitude*(M_PI/180.0));
	double circ=2*M_PI*real_radius; //Circumference
	double res = circ / (TILE_SIZE * pow(2,17-zoom));
	return res;
}
-(double)getMetersPerPixel:(double)latitude {
	double radius=6378200; //m, at equator
	double real_radius=radius*cos(latitude*(M_PI/180.0));
	double circ=2*M_PI*real_radius; //Circumference
	double res = circ / (TILE_SIZE * pow(2,17-zoom));
	return res;
}
-(PositionObj*)getCurrentPos {
	return pos;
}
-(void)setGPSTracking:(BOOL)val {
	gpsTracking=val;
}
- (void)getLatLonfromXY:(int)x andY:(int)y withXOffset:(int)xoff andYOffset:(int)yoff toLat:(double*)lat andLon:(double*)lon withZoom:(int)zoom2 {
	[MapView getLatLonfromXY:x andY:y withXOffset:xoff andYOffset:yoff toLat:lat andLon:lon withZoom:zoom2];
}
+ (void)getLatLonfromXY:(int)x andY:(int)y withXOffset:(int)xoff andYOffset:(int)yoff toLat:(double*)lat andLon:(double*)lon withZoom:(int)zoom2 {
	int zl = 17 - zoom2;
	double DegreePerPixel = 360.0 / (1 << (zl + 8));
	
	double tmp = xoff * DegreePerPixel+((x<<zoom2)*360.0)/131072.0 - 180.0; //131072.0=2^17
	*lon = tmp;
	
	double iY = y;
	iY = iY + yoff / 256.0;
	iY = iY / (1 << zl);
	iY = iY * (2 * M_PI);
	iY = M_PI - iY;
	double LatRad = 2 *atan(exp(iY));
	*lat = LatRad * (180 / M_PI) - 90;
}
- (void)getXYfrom:(double)lat andLon:(double)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2 {
	[MapView getXYfrom:lat andLon:lon toPositionX:x andY:y withZoom:zoom2];
}
+ (void)getXYfrom:(double)lat andLon:(double)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2 {
	double ty;
	
	while (lon> 180) lon -= 360;
	while (lon<-180) lon += 360;
	
	int tmpx = (int)((lon+180.0) * 364.088888888); //131072.0=2^17 / 360 =  * 364.088888888f
	*x = (tmpx >> zoom2);
	
	if (lat> 90) lat = lat - 180;
	if (lat < -90) lat = lat + 180;
	
	lat = lat / 180.0 * M_PI;
	ty=sin(lat);
	ty=(1.0 + ty) / (1.0 - ty);
	errno=0;
	double ty2=logf(ty);
	
	ty2 = 0.5 * ty2;
	ty2=M_PI-ty2;
	int tmpy = (int)((ty2 / 2.0 / M_PI) * 131072.0);
	tmpy=tmpy >> zoom2;
	
	*y=tmpy;
}
- (void)getXYOffsetfrom:(double)lat andLon:(double)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2 {
	[MapView getXYOffsetfrom:lat andLon:lon toPositionX:x andY:y withZoom:zoom2];
}
+ (void)getXYOffsetfrom:(double)lat andLon:(double)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2 {
	double ty;
	double latici=lat;
	double pow2zoom=pow(2,zoom2);
	//double lonici=lon;
	double tmpx = (((lon+180.0) * 364.088888888f)*(TILE_SIZE))/pow2zoom;
	//NSLog(@"Offset x: tmpx=%f",tmpx);
	*x=(int)fmod(tmpx,TILE_SIZE);
	//NSLog(@"Lat 1=%f",lat);
	latici = (lat / 180.0) * M_PI;
	//NSLog(@"Lat 2=%f",lat);
	ty=sin(latici);
	ty=(1.0 + ty) / (1.0 - ty);
	ty=-0.5*logf(ty);
	ty+=M_PI;
	double tmpy = (((ty / 2.0 / M_PI) * 131072.0)*(TILE_SIZE))/pow2zoom;
	//NSLog(@"1-sin=%f",1.0 - sin(lat));
	//NSLog(@"Offset y: tmpy=%f, ty=%f = %f",tmpy,ty,(1.0 + sin(lat)) / (1.0 - sin(lat)));
	
	*y=(int)fmod(tmpy,TILE_SIZE);
}
-(void)computeCachedRoad {
	
	for(PositionObj * p in APPDELEGATE.directions.roadPoints) {
		int xstart,ystart,xoffstart,yoffstart;
		
		[self getXYfrom:p.x andLon:p.y toPositionX:&xstart andY:&ystart withZoom:zoom];
		[self getXYOffsetfrom:p.x andLon:p.y toPositionX:&xoffstart andY:&yoffstart withZoom:zoom];	
		p.tileX=xstart;
		p.tileY=ystart;
		p.xoff=xoffstart;
		p.yoff=yoffstart;
		//NSLog(@"Point: %f %f is %d %d %d %d",p.x,p.y,p.tileX,p.tileY,p.xoff,p.yoff);
	}
	[self refreshMap];
}
#if 1
- (void)drawRect:(CGRect)rect{
	//NSLog(@"Drawing at %f°",mapRotation/M_PI*180.0);
	//TODO: we currently assume that rect if the full screen !
	int winWidth=rect.size.width;
	int winHeight=rect.size.height;

	if(!mapRotationEnabled)
		mapRotation=0;
	
	float cosr=cos(mapRotation);
	float sinr=sin(mapRotation);
	
	// Drawing code
	//NSLog(@"Drawing Map with rect size: %f %f and pos %f %f",rect.size.width,rect.size.height,rect.origin.x,rect.origin.y);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
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
	//double centerTilePosY=winHeight/2.0-(yoff/TILE_SIZE)*dynTileSize;
	//double centerTilePosX=winWidth/2.0-(xoff/TILE_SIZE)*dynTileSize;
	float centerTilePosX=drawOrigin.x-(xoff);
	float centerTilePosY=drawOrigin.y-(yoff);
	
	//double centerTilePosX2=centerTilePosY*sinr+centerTilePosX*cosr;
	//double centerTilePosY2=centerTilePosY*cosr-centerTilePosX*sinr;
	//centerTilePosX=centerTilePosX2;
	//centerTilePosY=centerTilePosY2;
	//Try to search the tile x,y which will be put in the top left corner and where exactly.
	//int nbTileInX=ceil((double)centerTilePosX/dynTileSize);
	//int nbTileInY=ceil((double)centerTilePosY/dynTileSize);
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
	
	int nbTileInX=ceil((float)widthDraw2/TILE_SIZE);
	int nbTileInY=ceil((float)heightDraw2/TILE_SIZE);
	x=x-nbTileInX;
	y=y-nbTileInY;
	org.x=centerTilePosX-nbTileInX*TILE_SIZE;
	org.y=centerTilePosY-nbTileInY*TILE_SIZE;
	
	//double heightDraw=sqrt(winWidth*winWidth+winHeight*winHeight)/2;
	
	//double orgAngleY=cos(M_PI/2-mapRotation)*rect.size.width;
	//double orgAngleX=cos(M_PI/2-mapRotation)*rect.size.height;
	//double orgAngleX=
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
					[t drawInRect: CGRectMake(org.x+marginx,org.y+marginy + TILE_SIZE,TILE_SIZE,TILE_SIZE) withContext:context];
				}
				marginx-=0.5;
				
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
				org.x+=TILE_SIZE;
				x++;
			}
		}
		org.x=orgx;
		marginy-=0.5;
		org.y+=TILE_SIZE;
		x=orgxTile;
		y++;
		
	}
	
	//Flush memory cache if too big
	if([tilescache count]>64) {
		[tilescache removeAllObjects];
	}
	
	//NSLog(@"Cache size: %d",[tilescache count]);
	
	//Draw gps pos
	
	if(posSearch.x!=0.0f && posSearch.y!=0.0f) {
		int xoff2,yoff2;
		[self getXYfrom:posSearch.x andLon:posSearch.y toPositionX:&x andY:&y withZoom:zoom];
		[self getXYOffsetfrom:posSearch.x andLon:posSearch.y toPositionX:&xoff2 andY:&yoff2 withZoom:zoom];
		
		
		float posXPin=drawOrigin.x+(x-centerTileX)*TILE_SIZE-xoff+(xoff2);
		float posYPin=drawOrigin.y+(y-centerTileY)*TILE_SIZE-(yoff)+(yoff2);
		float posXPin2=cosr*posXPin - posYPin*sinr;
		float posYPin2=sinr*posXPin + posYPin*cosr;
		
		
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
	
	
	/*CGContextBeginPath(context);
	 CGContextAddArc(context,rect.size.width/2,rect.size.height/2,4,0,2*M_PI,0);
	 CGContextClosePath(context);
	 CGContextSetRGBFillColor(context, 1, 0, 0, 1);
	 CGContextDrawPath(context,kCGPathFill);
	 */
	
	//Draw lines
	
	if([APPDELEGATE.directions.roadPoints count]>1) {
		//NSLog(@"Drawing %d points",[APPDELEGATE.directions.roadPoints count]);
		int i;
		CGContextSetRGBStrokeColor(context,0.662,0.184,1,0.64);
		CGContextSetLineWidth(context,6.0);
		CGContextSetLineJoin(context,kCGLineJoinRound);
		CGPoint points[[APPDELEGATE.directions.roadPoints count]];
		//CGPoint points2[[APPDELEGATE.directions.roadPoints count]];
		int j=0;
		//BOOL goodFound=NO;
		//BOOL badFound=NO;
		//double prevx=0,prevy=0;
		//BOOL addedPrev=YES;
		//int nb=debugRoadStep>0 ? debugRoadStep : [APPDELEGATE.directions.roadPoints count];
		for(i=0;i<[APPDELEGATE.directions.roadPoints count];i++) {
			int xoffstart,yoffstart,xstart,ystart;
			PositionObj *l=[APPDELEGATE.directions.roadPoints objectAtIndex:i];
			//NSLog(@"Drawing line %f %f",l.x,l.y);
			//[self getXYfrom:l.x andLon:l.y toPositionX:&xstart andY:&ystart withZoom:zoom];
			//[self getXYOffsetfrom:l.x andLon:l.y toPositionX:&xoffstart andY:&yoffstart withZoom:zoom];
			xoffstart=l.xoff;
			yoffstart=l.yoff;
			xstart=l.tileX;
			ystart=l.tileY;
			float posXPin=drawOrigin.x+(xstart-centerTileX)*TILE_SIZE-(xoff)+(xoffstart);
			float posYPin=drawOrigin.y+(ystart-centerTileY)*TILE_SIZE-(yoff)+(yoffstart);
			
			//	double posXPin2=cosr*posXPin - posYPin*sinr;
			//	double posYPin2=sinr*posXPin + posYPin*cosr;
			
			//NSLog(@"Test point %f %f",posXPin2,posYPin2);
			/*
			 if(posXPin2<-winWidth/2.0 || posXPin2>=winWidth/2 || posYPin2<-winHeight/2 || posYPin2>=winHeight/2) {	
			 prevx=posXPin;
			 prevy=posYPin;
			 if(goodFound) {
			 if(badFound)
			 break;
			 else {
			 badFound=YES;
			 }
			 } else {
			 continue;
			 }
			 
			 } else {
			 goodFound=YES;
			 }*/
			
			//NSLog(@"Drawing point %f %f",posXPin,posYPin);
			//	if(alwaysIN || (posXStart>=-dynTileSize && posXStart<rect.size.width+dynTileSize && posYStart>=-dynTileSize && posYStart<rect.size.height+dynTileSize)) {
			//Draw the line
			
			/*if(!addedPrev) {
			 if(i>0) {
			 points[j]=CGPointMake(prevx,prevy);
			 j++;
			 }
			 addedPrev=YES;
			 }*/
			
			points[j]=CGPointMake(posXPin,posYPin);
			j++;
			//	alwaysIN=YES;
			//} else {
			//	alwaysIN=NO;
			//}
		}
		if(j>1) {
			//	NSLog(@"Nb points to draw %d",j);
			//CGContextRotateCTM(context, -mapRotation);
			
			CGContextBeginPath(context);
			CGContextAddLines(context,points,j);
			//CGContextClosePath(context);
			CGContextDrawPath(context,kCGPathStroke);
			
			//CGContextRotateCTM(context, mapRotation);
			
			
		}
	}
	
	
	
	if(posDrivingInstruction.x!=0 && posDrivingInstruction.y!=0) {
		int xoff2,yoff2;
		[self getXYfrom:posDrivingInstruction.x andLon:posDrivingInstruction.y toPositionX:&x andY:&y withZoom:zoom];
		[self getXYOffsetfrom:posDrivingInstruction.x andLon:posDrivingInstruction.y toPositionX:&xoff2 andY:&yoff2 withZoom:zoom];
		
		
		float posXPin=drawOrigin.x+(x-centerTileX)*TILE_SIZE-xoff+(xoff2);
		float posYPin=drawOrigin.y+(y-centerTileY)*TILE_SIZE-(yoff)+(yoff2);		
		//Draw a circle
		
		CGContextSetLineWidth(context,3.0);
		CGContextSetRGBFillColor(context,0.662,0.184,1,0.4);
		CGContextSetRGBStrokeColor(context,0.662,0.184,1,0.8);
		CGContextBeginPath(context);
		CGContextAddArc(context,posXPin,posYPin,35,0,2*M_PI,0);
		CGContextStrokePath(context);
		CGContextBeginPath(context);
		CGContextAddArc(context,posXPin,posYPin,35,0,2*M_PI,0);
		CGContextFillPath(context);
	}	
	
	//CGContextScaleCTM(context, 1, -1);
	

	//rot=CGAffineTransformMakeRotation(mapRotation);
	//CGAffineTransform trans=CGAffineTransformMakeTranslation(-rect.size.width/2.0,-rect.size.height/2.0);
	//CGContextConcatCTM(context, rot);
	
	if(hasGPSfix) {
		int xoff2,yoff2;
		[self getXYfrom:posGPS.x andLon:posGPS.y toPositionX:&x andY:&y withZoom:zoom];
		[self getXYOffsetfrom:posGPS.x andLon:posGPS.y toPositionX:&xoff2 andY:&yoff2 withZoom:zoom];
		
		double posXPin=drawOrigin.x+(x-centerTileX)*TILE_SIZE-(xoff)+(xoff2);
		double posYPin=drawOrigin.y+(y-centerTileY)*TILE_SIZE-(yoff)+(yoff2);
		
		if(useGPSBall) {
			CGContextRotateCTM(context, -mapRotation);
			CGContextScaleCTM(context, 1, -1);
			[imgPinRef drawAtPoint: CGPointMake(posXPin-10, posYPin+10) withContext:context];
			CGContextScaleCTM(context, 1, -1);
			CGContextRotateCTM(context, mapRotation);
		} else{		
			float posXPin2=cosr*posXPin - posYPin*sinr;
			float posYPin2=sinr*posXPin + posYPin*cosr;
			if(posXPin2>=-winWidth/2.0 && posXPin2<winWidth/2 && posYPin2>=-winHeight/2 && posYPin2<winHeight/2) {
				
				CGPoint ind[4];
				ind[0].x=0;
				ind[0].y=5;
				ind[1].x=-15;
				ind[1].y=15*0.666+10;
				ind[2].x=0;
				ind[2].y=-35+10;
				ind[3].x=15;
				ind[3].y=15*0.666+10;
				float alpha=gpsHeading+mapRotation;
				float cosa=cos(alpha);
				float sina=sin(alpha);
				for(int i=0;i<4;i++) {
					float posx=ind[i].x;
					float posy=ind[i].y;
					
					ind[i].x=-cosa*posx -posy*sina;
					ind[i].y=+sina*posx - posy*cosa;
					
					//Translate to correct plage
					ind[i].x+=posXPin2;
					ind[i].y-=posYPin2;
				}
				

				CGContextRotateCTM(context, -mapRotation);
	
				CGContextScaleCTM(context, 1, -1);
				CGContextBeginPath(context);
				CGContextAddLines(context,ind,4);
				CGContextClosePath(context);
				CGContextSetRGBFillColor(context,0,0,1,0.6);
				CGContextFillPath(context);
				CGContextBeginPath(context);
				CGContextAddArc(context,posXPin2,-posYPin2,6,0,2*M_PI,0);
				CGContextClosePath(context);
				CGContextSetRGBFillColor(context,0,0,1,1);
				CGContextFillPath(context);
				CGContextScaleCTM(context, 1, -1);
		
				CGContextRotateCTM(context, mapRotation);

				
				//NSLog(@"Pos: %f %f",posXPin,posYPin);
			}
		}
	}	
	
	
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
	//CGContextScaleCTM(context, 1, -1);
	//CGAffineTransform trans=CGAffineTransformMakeTranslation(-rect.size.width/2.0,-rect.size.height/2.0);
	////CGContextConcatCTM(context, rot);
	//CGContextConcatCTM(context, trans);
	
	CGContextRestoreGState(context);
	
	
	/*CGContextBeginPath(context);
	 CGContextAddArc(context,rect.size.width-72,rect.size.height-52,4,0,2*M_PI,0);
	 CGContextClosePath(context);
	 CGContextSetRGBFillColor(context, 0, 1, 0, 1);
	 CGContextDrawPath(context,kCGPathFill);*/
	CGContextScaleCTM(context, 1, -1);
	[imgGoogleLogo drawAtPoint:CGPointMake(rect.size.width-72,rect.size.height-2) withContext:context];
	//CGContextScaleCTM(context, 1, -1);
	
	
	
	//CGContextSetRGBFillColor(context, 1, 0, 0, 1);
	//CGContextFillRect(context,CGRectMake(-30,30,10,10));
	
	//NSLog(@"Scale: %f m / pixel",[self getMetersPerPixel: pos.x]);
	//if(!dragging)
	//[dirC getNextDirection:pos];
	CGContextScaleCTM(context, 1, -1);
	if(pDepForMapSelection.x==0.0f && pDepForMapSelection.y==0.0f && pEndForMapSelection.x==0.0f && pEndForMapSelection.y==0.0f)
		return;
	CGContextSetRGBFillColor(context,1,0,0,0.4);
	CGContextSetRGBStrokeColor(context,1,0,0,0.8);
	
	CGSize size;
	
	//if(orientation==0 || orientation==180) {
	org=CGPointMake(pDepForMapSelection.x >= 0 ? pDepForMapSelection.x : 0,pDepForMapSelection.y-48.0f >= 0 ? pDepForMapSelection.y-48.0f : 0);
	size=CGSizeMake(pEndForMapSelection.x-pDepForMapSelection.x,pEndForMapSelection.y-pDepForMapSelection.y);
	/*} else if(orientation==90) {
	 org=CGPointMake(pDep.y >= 0 ? pDep.y : 0,pDep.x-48.0f >= 0 ? rect.size.height-pDep.x : 0);
	 size=CGSizeMake(pEnd.y-pDep.y,pEnd.x-pDep.x);
	 } else {
	 org=CGPointMake(pDep.y >= 0 ? pDep.y : 0,pDep.x-48.0f >= 0 ? rect.size.height-pDep.x : 0);
	 size=CGSizeMake(pEnd.y-pDep.y,pEnd.x-pDep.x);
	 }*/
	
	//NSLog(@"Origin: %f %f",org.x,org.y);
	//NSLog(@"Size: %f %f",size.width,size.height);
	CGContextFillRect(context,CGRectMake(org.x,org.y,size.width,size.height));
	CGContextStrokeRectWithWidth(context,CGRectMake(org.x,org.y,size.width,size.height),4);
	
	
	
	//if(passDoubleFingersEvent)
	//	[[self superview] drawRect:rect];
	
}
#endif
-(BOOL)hasGPSTracking {
	return gpsTracking;
}
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
	[sender setZoomoutState:zoom!=16];
	[self computeCachedRoad];
}
-(void)zoomout:(id)sender {
	if(zoom<16) zoom++;
	[self refreshMap];
	
	[sender setZoomoutState:zoom!=16];
	[sender setZoominState:zoom!=0];
	[self computeCachedRoad];
}
-(void)addDrawPoint:(PositionObj*)p {
	
	[self refreshMap];
}

-(void)allTileDownloaded {
	
}
@end
