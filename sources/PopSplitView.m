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
	[super init];
	_splitRatio = 0.0;
	_isCollapse = NO;
	return self;
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
	float ratio = [self splitRatio];
	// 現在の分割比が0.1以下ならば, 閉じた状態とする
	if(ratio < 0.1){
		ratio = _splitRatio;
	}else{
		_splitRatio = ratio;
		ratio = 0.0;
	}
	[self setSplitRatio:ratio];
}


//-- splitRatio
// 分割比を返す
- (float) splitRatio
{
	NSView* tView = [[self subviews] objectAtIndex:1];
	NSRect tFrame = [tView frame];
	NSRect pFrame = [self frame];
	
	return [self isVertical] ? (tFrame.size.width / pFrame.size.width)
							 : (tFrame.size.height / pFrame.size.height);
}


//-- setSplitRatio
// 分割比の設定
- (void) setSplitRatio:(float) inRatio
{
	if (inRatio < 0.0 || inRatio > 1.0) return;
	
	float thickness = [self dividerThickness]; // 幅
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
		tFrame.origin.x = oFrame.size.height + thickness;
	}
	[oView setFrame:oFrame];
	[tView setFrame:tFrame];
	[self setNeedsDisplay:YES];
}


//-- collapseRatio
// 保存しているratioを返す
- (float) collapseRatio
{
	return _splitRatio;
}


//-- setCollapseRatio
// 伸張用ratioを設定する
- (void) setCollapseRatio:(float)inRatio
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
