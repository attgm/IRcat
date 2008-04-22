//
//  $RCSfile: PopSplitView.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>

@interface PopSplitView : NSSplitView
{
	float _splitRatio;
	BOOL _isCollapse;
}

- (id) init;
- (void) collapseSubView;
- (float) splitRatio;
- (void) setSplitRatio:(float)inRatio;
- (void) setCollapse:(BOOL) inCollapse;

- (float) collapseRatio;
- (void) setCollapseRatio:(float)inRatio;

- (void) mouseDown:(NSEvent*) inEvent;

@end
