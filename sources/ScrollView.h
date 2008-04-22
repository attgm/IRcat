//
//  $RCSfile: ScrollView.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <AppKit/AppKit.h>

//アクセサリの表示位置
typedef enum _AccessoryPosition{
    //水平方向のアクセサリ
    LeftAccessoryViewPosition   = 1 << 0,		
    RightAccessoryViewPosition  = 1 << 1,
    //垂直方向のアクセサリ
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
