//
//  SplitHandler.m
//  ircat
//
//  Created by Atsushi on 2012/08/13.
//
//

#import "SplitHandler.h"

@implementation SplitHandler
@synthesize splitView = _splitView;

//-- initWithFrame
// init
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


//-- dealloc
// dealloc
-(void) dealloc
{
    self.splitView = nil;
    
    [super dealloc];
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


@end
