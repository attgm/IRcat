//
//  ChatTextFieldCell.m
//  ircat
//
//  Created by Atsushi on 2012/08/10.
//
//

#import "ChatTextFieldCell.h"

@implementation ChatTextFieldCell

const NSInteger IRHorizonalMargin = 8;
const NSInteger IRVerticalMargin = 3;
const NSInteger IRTextOffset = 4;


//-- inits
// initilize
-(id) init
{
    self = [super init];
    return self;
}

-(id) initImageCell:(NSImage *)image
{
    self = [super initImageCell:image];
    return self;
}

-(id) initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

-(void) awakeFromNib
{
}


//-- textFieldRectForFrame
// returen text area's rect expect border
-(NSRect) textFieldRectForFrame:(NSRect)frame {
    NSInteger radius = frame.size.height / 2;
    frame.origin.x += IRHorizonalMargin + radius;
    frame.origin.y += IRTextOffset + IRVerticalMargin;
    frame.size.width -= (IRHorizonalMargin + radius) * 2;
    frame.size.height -= IRTextOffset + IRVerticalMargin * 2;
    return frame;
}


//-- drawInteriorWithFrame
// draw border
- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView*)view
{
    [NSGraphicsContext saveGraphicsState];
    
    NSRect bounds = NSInsetRect(frame, IRHorizonalMargin - 0.5, IRVerticalMargin - 0.5);
    
    [[self backgroundColor] set];
    NSRectFill(frame);
    
    //[context setCompositingOperation:NSCompositePlusDarker];
    
    CGFloat radius = (bounds.size.height / 2);
    
    NSBezierPath* path = [NSBezierPath bezierPath];    
    [path moveToPoint:NSMakePoint(NSMinX(bounds) + radius, NSMaxY(bounds))];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(bounds) + radius, NSMidY(bounds)) radius:radius startAngle:90 endAngle:270];
    [path lineToPoint:NSMakePoint(NSMaxX(bounds) - (radius * 2), NSMinY(bounds))];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(bounds) - (radius * 2), NSMidY(bounds)) radius:radius startAngle:-90 endAngle:30];
    [path lineToPoint:NSMakePoint(NSMaxX(bounds) - radius / 2, NSMaxY(bounds))];
    [path curveToPoint:NSMakePoint(NSMaxX(bounds) - (radius * 2) + radius * cosf(M_PI*60/180), NSMidY(bounds) + radius * sinf(M_PI*60/180))
          controlPoint1:NSMakePoint(NSMaxX(bounds) - radius, NSMaxY(bounds))
          controlPoint2:NSMakePoint(NSMaxX(bounds) - (radius * 2) + radius * cosf(M_PI*60/180), NSMidY(bounds) + radius * sinf(M_PI*60/180))];
    
    //[path lineToPoint:NSMakePoint(NSMaxX(bounds) - (radius * 2) + radius * cosf(M_PI*60/180), NSMidY(bounds) + radius * sinf(M_PI*60/180))];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(bounds) - (radius * 2), NSMidY(bounds)) radius:radius startAngle:60 endAngle:90];
    [path lineToPoint:NSMakePoint(NSMaxX(bounds) - (radius * 2), NSMaxY(bounds))];
    [path lineToPoint:NSMakePoint(NSMinX(bounds) + radius, NSMaxY(bounds))];
    [path closePath];
    
    
    [[NSColor colorWithDeviceWhite:0.75f alpha:1.0f] setStroke];
    
    NSShadow * shadow = [[[NSShadow alloc] init] autorelease];
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0f alpha:0.10f]];
    [shadow setShadowBlurRadius:4.0f];
    [shadow setShadowOffset:NSZeroSize];
    [shadow set];
    
    [path setLineWidth:3.0f];
    [path addClip];
    [path stroke];
    
    [NSGraphicsContext restoreGraphicsState];
    
    [super drawInteriorWithFrame:frame inView:view];
}



//-- resetCursorRect
//
-(void) resetCursorRect:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super resetCursorRect:[self textFieldRectForFrame:cellFrame] inView:controlView];
}



//-- editWithFrame:inView:editor:delegate:event
//
-(void) editWithFrame:(NSRect)aRect
               inView:(NSView *)controlView
               editor:(NSText *)textObj
             delegate:(id)anObject
                event:(NSEvent *)theEvent
{
    [super editWithFrame:[self textFieldRectForFrame:aRect]
                  inView:controlView
                  editor:textObj
                delegate:anObject
                   event:theEvent];
}


//-- selectWithFrame:inView:editor:delegate:start:length
//
-(void) selectWithFrame:(NSRect)aRect
                 inView:(NSView *)controlView
                 editor:(NSText *)textObj
               delegate:(id)anObject
                  start:(NSInteger)selStart
                 length:(NSInteger)selLength
{
    [super selectWithFrame:[self textFieldRectForFrame:aRect]
                    inView:controlView
                    editor:textObj
                  delegate:anObject
                     start:selStart
                    length:selLength];
}


//--- drawingRectForBounds
-(NSRect)drawingRectForBounds:(NSRect)aRect
{
    return [self textFieldRectForFrame:aRect];
}

@end
