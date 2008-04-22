//
//  $RCSfile: ScrollView.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <AppKit/AppKit.h>

//�A�N�Z�T���̕\���ʒu
typedef enum _AccessoryPosition{
    //���������̃A�N�Z�T��
    LeftAccessoryViewPosition   = 1 << 0,		
    RightAccessoryViewPosition  = 1 << 1,
    //���������̃A�N�Z�T��
    TopAccessoryViewPosition    = 1 << 2,
    BottomAccessoryViewPosition = 1 << 3,
} AccessoryPosition;


@interface ScrollView : NSScrollView {
    //NSMutableArray  *_horizontalAccessoryViews;
    NSMutableArray  *_verticalAccessoryViews;
    
//    AccessoryPosition _accesoryPosition;
}

- (NSMutableArray*) verticalAccessoryViews;

- (void) addVerticalAccessoryView : (NSView *) accessory;

- (void) layoutVerticalViews;

- (void) tile;

@end
