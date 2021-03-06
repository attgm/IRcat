//
//  $RCSfile: PopSplitView.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>

@interface PopSplitView : NSSplitView
{
	CGFloat _splitRatio;
	BOOL _isCollapse;
    
    NSButton* _popupButton;
}

@property (assign, nonatomic) CGFloat collapseRatio;
@property (retain, nonatomic) IBOutlet NSButton* popButton;


-(IBAction) collapse:(id)sender;

- (id) init;
- (void) collapseSubView;

- (CGFloat) splitRatio;
- (void) setSplitRatio:(CGFloat)inRatio animate:(BOOL)animate;
- (void) setCollapse:(BOOL) inCollapse;

- (void) mouseDown:(NSEvent*) inEvent;

@end
