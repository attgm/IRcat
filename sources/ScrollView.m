//
//  $RCSfile: ScrollView.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ScrollView.h"


@implementation ScrollView

//-- initWithFrame:
// 初期化
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}



//-- verticalAccessoryViews
// 縦方向のアクセサリを返す
- (NSMutableArray*) verticalAccessoryViews
{
    if(_verticalAccessoryViews == nil){
        _verticalAccessoryViews = [[NSMutableArray alloc] init];
    }
    return _verticalAccessoryViews;
}


//-- addVerticalAccessoryView
// 縦方向のアクセサリを追加する
- (void) addVerticalAccessoryView : (NSView *) accessory
{
    [[self verticalAccessoryViews] addObject:accessory];
    [self addSubview : accessory];
}


//-- layoutVerticalViews
// 縦方向のアクセサリの位置変更
- (void) layoutVerticalViews
{
    NSScroller* vScroller = [self verticalScroller];
    NSRect	vFrame = [vScroller frame];
    NSRect	frame = [self frame];
    NSSize	vSize;
    NSPoint	origin;
    NSView*	accessory;
    
    NSEnumerator*	it;
    
    vSize.height = frame.size.height;
    vSize.width = vFrame.size.width;
    // アクセサリを配置する開始点を決定
    origin = NSMakePoint(vFrame.origin.x, 0.0f);
    
    it = [[self verticalAccessoryViews] objectEnumerator];
    while(accessory = [it nextObject]){
        float accessoryHeight;
        NSSize accessorySize = ([accessory frame]).size;
        
        //スクローラの幅に合わせる。
        accessorySize.width = vSize.width + 1.0f;
        
        //accessoryの位置の移動
        [accessory setFrameOrigin:origin];
        [accessory setFrameSize:accessorySize];
        [accessory setNeedsDisplay:YES];
        
        //原点と水平スクローラのサイズを調節
        accessoryHeight = accessorySize.height - 1;
        origin.y += accessoryHeight;
        vSize.height -= accessoryHeight;
    }
    // スクローラのサイズ変更
	vSize.height -= 2;
	origin.y += 1;	
    [vScroller setFrameOrigin:origin];
    [vScroller setFrameSize:vSize];
    [vScroller setNeedsDisplay:YES];
}


//-- tile [NSScrollView]
// スクローラの位置変更
- (void) tile
{
    [super tile];	
    [self layoutVerticalViews];
}

@end
