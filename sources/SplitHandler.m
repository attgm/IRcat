//
//  SplitHandler.m
//  ircat
//
//  Created by Atsushi on 2012/08/13.
//
//

#import "SplitHandler.h"

@implementation SplitHandler

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


//-- mouseDown
// trace mouse move
-(void) mouseDown:(NSEvent*)event
{
    if ([_splitView subviews] == 0) return;
    
    NSView* view = [[_splitView subviews] objectAtIndex:0];
    NSRect  viewFrame = [view frame];
    
    //NSDivideRect(frame, &trackingArea, &rect, 16.0f, NSMaxXEdge);
    //if ([self mouse:mouseLocation inRect:trackingArea]) {
        while (YES) {
            NSEvent* waitingEvent = [NSApp nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)
                                                       untilDate:[NSDate distantFuture]
                                                          inMode:NSEventTrackingRunLoopMode
                                                         dequeue:YES];
            if (waitingEvent == nil) {
                return;
            }
            
            if ([waitingEvent type] == NSLeftMouseDragged){
                NSInteger delta = [event locationInWindow].y - [waitingEvent locationInWindow].y;
                
                if (delta != 0) {
                    NSRect  newFrame;
                    newFrame = viewFrame;
                    newFrame.size.height += delta;
                    [view setFrame:newFrame];
                    
                    [_splitView adjustSubviews];
                }
            }else if ([waitingEvent type] == NSLeftMouseUp) {
                return;
            }
        }
    //}
    
    [super mouseDown:event];
}



//-- resetCursorRects
// set cursor rect
-(void) resetCursorRects
{
    [self discardCursorRects];
    
    [self addCursorRect:[self bounds] cursor:[NSCursor resizeUpDownCursor]];
}


//-- drawRect
// draw rect
-(void) drawRect:(NSRect)dirtyRect
{
    //BOOL highlighted = [[self window] isMainWindow] && [[NSApplication sharedApplication] isActive];
	[NSGraphicsContext saveGraphicsState];
	
	NSRect bounds = [self bounds];

	NSColor* startColor = [NSColor colorWithDeviceWhite:.90 alpha:1.0];
	NSColor* endColor = [NSColor colorWithDeviceWhite:.80 alpha:1.0];
	NSGradient *backgroundGradient = [[[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor] autorelease];
	[backgroundGradient drawInRect:bounds angle:270];
    
	[[NSColor colorWithDeviceWhite:.50 alpha:1.0] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))
							  toPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
	[[NSColor colorWithDeviceWhite:1.0 alpha:1.0] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds) - 1)
							  toPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds) - 1)];
	
	[NSGraphicsContext restoreGraphicsState];
}

@end
