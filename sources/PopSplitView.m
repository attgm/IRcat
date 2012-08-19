//
//  $RCSfile: PopSplitView.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import "PopSplitView.h"

@implementation PopSplitView


//-- init
// 初期化
- (id) init
{
	self = [super init];
    if(self !=  nil){
        _splitRatio = 0.0;
        _isCollapse = NO;
	}
    return self;
}

//-- dealloc
//
-(void) dealloc
{
    [super dealloc];
}

//-- collapse
//
-(IBAction) collapse:(id)sender
{
    [self collapseSubView];
}


//-- setCollapse
// popupするかどうかの設定
- (void) setCollapse:(BOOL) inCollapse
{
	_isCollapse = inCollapse;
}


//-- conposeSubView
// SubViewをPopupさせる.
- (void) collapseSubView
{
	// 変換前の分割比を求める
	CGFloat ratio = [self splitRatio];
	// 現在の分割比が0.1以下ならば, 閉じた状態とする
	if(ratio < 0.1){
		ratio = _splitRatio;
	}else{
		_splitRatio = ratio;
		ratio = 0.0;
	}
	[self setSplitRatio:ratio animate:YES];
}


//-- splitRatio
// 分割比を返す
- (CGFloat) splitRatio
{
	NSView* tView = [[self subviews] objectAtIndex:1];
	NSRect tFrame = [tView frame];
	NSRect pFrame = [self frame];
	
	return (CGFloat)([self isVertical] ? (tFrame.size.width / pFrame.size.width)
                                        : (tFrame.size.height / pFrame.size.height));
}


//-- setSplitRatio
// 分割比の設定
-(void) setSplitRatio:(CGFloat)inRatio animate:(BOOL)animate
{
	if (inRatio < 0.0 || inRatio > 1.0) return;
    
	CGFloat thickness = [self dividerThickness]; // 幅
	// sub viewのサイズを変更する
	NSRect pFrame = [self frame];
	NSView* oView = [[self subviews] objectAtIndex:0];
	NSRect oFrame = [oView frame];
	NSView* tView = [[self subviews] objectAtIndex:1];
	NSRect tFrame = [tView frame];
    
    // 縦分割か横分割かで2通り
	if([self isVertical]){
		tFrame.size.width = ceil(pFrame.size.width * inRatio);
		oFrame.size.width = pFrame.size.width - tFrame.size.width - thickness;
		tFrame.origin.x = oFrame.size.width + thickness;
	}else{
		tFrame.size.height = ceil(pFrame.size.height * inRatio);
		oFrame.size.height = pFrame.size.height - tFrame.size.height - thickness;
		tFrame.origin.y = oFrame.size.height + thickness;
	}
    
    /*NSArray* animation = [NSArray arrayWithObjects:
                          [NSDictionary dictionaryWithObjectsAndKeys:
                            oView, NSViewAnimationTargetKey,
                           soFrame, NSViewAnimationStartFrameKey,
                            [NSValue valueWithRect:oFrame], NSViewAnimationEndFrameKey,
                            nil]
                          , [NSDictionary dictionaryWithObjectsAndKeys:
                           tView, NSViewAnimationTargetKey,
                             stFrame, NSViewAnimationStartFrameKey,
                           [NSValue valueWithRect:tFrame], NSViewAnimationEndFrameKey,
                           nil]
                          , nil];
    NSViewAnimation* viewAnimation = [[NSViewAnimation alloc] initWithViewAnimations:animation];
    [viewAnimation setDuration:.25f];
    [viewAnimation startAnimation];
    [viewAnimation release];*/
    
    if(animate == YES){
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.2f];
        [[oView animator] setFrame:oFrame];
        [[tView animator] setFrame:tFrame];
        [NSAnimationContext endGrouping];
    }else{
        [[oView animator] setFrame:oFrame];
        [[tView animator] setFrame:tFrame];
    }
//    [self adjustSubviews];
//    [self setNeedsDisplay:YES];
//	[oView setFrame:oFrame];
//	[tView setFrame:tFrame];
//	[self setNeedsDisplay:YES];
}


//-- collapseRatio
// 保存しているratioを返す
- (CGFloat) collapseRatio
{
	return _splitRatio;
}


//-- setCollapseRatio
// 伸張用ratioを設定する
- (void) setCollapseRatio:(CGFloat) inRatio
{
	if(inRatio >= 0.0 && inRatio <= 1.0){
		_splitRatio = inRatio;
	}
}


//-- mouseDown
// マウスが押されたときの処理
- (void) mouseDown:(NSEvent*) inEvent
{
	if([inEvent clickCount] == 2 && _isCollapse){ //ダブルクリックなら collapseする
		[self collapseSubView];
	}else{
		[super mouseDown:inEvent];
	}
}


@end
