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
const NSInteger IRVerticalMargin = 2;
const NSInteger IRTextOffset = 4;

static NSImage* sLeftImage = nil;
static NSImage* sRightImage = nil;
static NSImage* sMiddleImage = nil;

//-- inits
// initilize
-(id) init
{
    self = [super init];
    if(self != nil){
        [ChatTextFieldCell loadImages];
    }
    return self;
}

-(id) initImageCell:(NSImage *)image
{
    self = [super initImageCell:image];
    if(self != nil){
        [ChatTextFieldCell loadImages];
    }
    return self;
}

-(id) initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    if(self != nil){
        [ChatTextFieldCell loadImages];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self != nil){
        [ChatTextFieldCell loadImages];
    }
    return self;
}

-(void) awakeFromNib
{
    [ChatTextFieldCell loadImages];
}

//-- loadImages
// load image files if needs
+(void) loadImages
{
    if (sLeftImage == nil) sLeftImage = [NSImage imageNamed:@"chat_left"];
    if (sRightImage == nil) sRightImage = [NSImage imageNamed:@"chat_right"];
    if (sMiddleImage == nil) sMiddleImage = [NSImage imageNamed:@"chat_middle"];
}


//-- textFieldRectForFrame
// returen text area's rect expect border
-(NSRect) textFieldRectForFrame:(NSRect)frame {
    frame.origin.x += IRHorizonalMargin + [sLeftImage size].width;
    frame.origin.y += IRTextOffset + IRVerticalMargin;
    frame.size.width -= IRHorizonalMargin * 2 + [sLeftImage size].width + [sRightImage size].width;
    frame.size.height -= IRTextOffset + IRVerticalMargin * 2;
    return frame;
}


//-- drawInteriorWithFrame
// draw border
- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView*)view
{
    NSRect bounds = frame;
    NSRect  destRect;
    
    [[NSColor whiteColor] set];
    NSRectFill(bounds);
    
    // draw left cap
    destRect.origin = NSMakePoint(bounds.origin.x + IRHorizonalMargin, IRVerticalMargin);
    destRect.size = [sLeftImage size];
	[sLeftImage drawInRect:destRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f respectFlipped:YES hints:nil];
	// draw right Cap
    destRect.origin = NSMakePoint(bounds.origin.x + bounds.size.width - [sRightImage size].width - IRHorizonalMargin, IRVerticalMargin);
    destRect.size = [sRightImage size];
	[sRightImage drawInRect:destRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f respectFlipped:YES hints:nil];
	// draw middle
    destRect.origin = NSMakePoint(bounds.origin.x + IRHorizonalMargin + [sLeftImage size].width, IRVerticalMargin);
    destRect.size = [sMiddleImage size];
    destRect.size.width =  bounds.size.width - (IRHorizonalMargin * 2 + [sRightImage size].width + [sLeftImage size].width);
    [sMiddleImage drawInRect:destRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f  respectFlipped:YES hints:nil];
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

@end
