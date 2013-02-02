//
//  $RCSfile: ChannelViewController.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import "ChannelViewController.h"
#import "ChannelModal.h"
#import "IRcatInterface.h"
#import "ConsoleTextView.h"

@implementation ChannelViewController

#pragma mark Init
//-- initWithChannelModal
// 初期化
- (id) initWithInterface:(IRcatInterface*) inInterface;
{
    self = [super init];
    if(self != nil){
        [self setInterface:inInterface];
        [self setChannelModal:nil];
    }
    return self;
}


//-- dealloc
// データの削除
- (void) dealloc
{
    [_channelView unbind:@"font"];
	[_channelView unbind:@"urlColor"];
	[_channelView unbind:@"backgroundColor"];
    
#if !__has_feature(objc_arc)
    [_scrollView release];
	[_channelModal release];
	[_channelView release];
	[_interface release];
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

//-- setInterface
// interfaceの設定
-(void) setInterface:(IRcatInterface*) inInterface
{
	[_interface release];
	_interface = [inInterface retain];
}

//-- setChannelModal
// channelmodalの設定
-(void) setChannelModal:(ChannelModal*) inChannelModal
{
	[_channelModal release];
	_channelModal = [inChannelModal retain];
}


//-- createChannelView
// create channel view text field
- (void) createChannelView
{
    NSNotificationCenter*   center;
    
    _scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0,0,200,200)];
    [_scrollView setBorderType:NSNoBorder];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:NO];
    [_scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    NSSize contentSize = [_scrollView contentSize];
    
    _channelView = [[ConsoleTextView alloc] initWithFrame:NSMakeRect(0,0, contentSize.width, contentSize.height)];
    [_channelView setMinSize:NSMakeSize(0.0, 0.0)];
    [_channelView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [_channelView setVerticallyResizable:YES];
    [_channelView setHorizontallyResizable:NO];
    [_channelView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [_channelView setEditable:YES];
    
    [[_channelView textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
    [[_channelView textContainer] setWidthTracksTextView:YES];
    
    [_scrollView setDocumentView:_channelView];
    
    // サイズ変更の notificationを受け取る
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didScroll:)
				   name:NSViewBoundsDidChangeNotification
				 object:_channelView];
    [_channelView setPostsBoundsChangedNotifications:YES];
    
	NSObjectController* prefController = [_interface sharedPreferenceController];
	[_channelView bind:@"font" toObject:prefController withKeyPath:@"selection.textFont"
			options:[NSDictionary dictionaryWithObject:@"FontNameToFontTransformer"
												forKey:@"NSValueTransformerName"]];
	[_channelView bind:@"urlColor" toObject:prefController withKeyPath:@"selection.urlColor"
			options:[NSDictionary dictionaryWithObject:@"ColorNameToColorTransformer"
												forKey:@"NSValueTransformerName"]];
	[_channelView bind:@"backgroundColor" toObject:prefController withKeyPath:@"selection.backgroundColor"
			   options:[NSDictionary dictionaryWithObject:@"ColorNameToColorTransformer"
												   forKey:@"NSValueTransformerName"]];

}



#pragma mark Scroll Lock
//-- didScroll
// TextViewのスクロールが発生した時に呼び出される
- (void) didScroll : (NSNotification*) inNote
{
    NSRect bounds = [[_scrollView contentView] bounds];
    NSRect frame = [[_scrollView documentView] frame];
    float diff = (frame.size.height + frame.origin.y) - (bounds.origin.y + bounds.size.height);
    [self setLockedScroll:((diff > 16.0) ? NSOnState : NSOffState)];
}


//-- setLockedScroll
//
-(void) setLockedScroll:(NSCellStateValue) value
{
	_lockedScroll = value;
}


//-- lockedScroll
//
-(NSCellStateValue) lockedScroll
{
	return _lockedScroll;
}


#pragma mark Tear Window
//-- setTearSwitch
// Tear on/offが押された時に呼び出される
-(IBAction) setTearSwitch:(id) sender
{
	[_interface tearChannel:_channelModal];
}


//-- channelView
// ChannelViewを返す
- (id) channelView
{
    if(!_scrollView)
        [self createChannelView];
    
    return _scrollView;
}

//-- moveToEndOfDocument
// 一番下までスクロールさせる
-(void) moveToEndOfDocument
{
	[_channelView moveToEndOfDocument:self];
	[self setLockedScroll:NSOffState];
}


//-- removeAllString
// すべての文字列を削除する
- (void) removeAllString
{
	NSTextStorage* storage = [_channelView textStorage];
    [storage beginEditing];
	[storage deleteCharactersInRange:NSMakeRange(0, [storage length])];
    [storage endEditing];
}


//-- appendString:append:
// 文字列の追加を行う
- (BOOL) appendString:(NSAttributedString*)inString append:(NSAttributedString*)inAppend at:(NSInteger)inAppendIndex
{
	return [_channelView appendString:inString append:inAppend at:inAppendIndex scrollLock:_lockedScroll];
}




@end


