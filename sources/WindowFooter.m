//
//  WindowFooter.m
//  ircat
//
//  Created by Atsushi on 2012/09/09.
//
//

#import "WindowFooter.h"

@implementation WindowFooter

//-- initWithFrame
//
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }    
    return self;
}


//-- drawRect
// draw rect
-(void) drawRect:(NSRect)dirtyRect
{
    //BOOL highlighted = [[self window] isMainWindow] && [[NSApplication sharedApplication] isActive];
	[NSGraphicsContext saveGraphicsState];
	
	NSRect bounds = [self bounds];
    
	NSColor* startColor = [NSColor colorWithDeviceWhite:.90 alpha:1.0];
	NSColor* endColor = [NSColor colorWithDeviceWhite:.75 alpha:1.0];
	NSGradient *backgroundGradient = [[[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor] autorelease];
	[backgroundGradient drawInRect:bounds angle:270];
    
	[[NSColor colorWithDeviceWhite:.40 alpha:1.0] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))
							  toPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
	//[[NSColor colorWithDeviceWhite:1.0 alpha:1.0] set];
	//[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds) - 1)
	//						  toPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds) - 1)];
	[NSGraphicsContext restoreGraphicsState];
}



@end
