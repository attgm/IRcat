//
//  $RCSfile: ChannelViewController.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import "ChannelViewController.h"
#import "ChannelModal.h"
#import "ScrollView.h"
#import "IRcatInterface.h"
#import "ConsoleTextView.h"

@implementation ChannelViewController

#pragma mark Init
//-- initWithChannelModal
// 初期化
- (id) initWithInterface:(IRcatInterface*) inInterface;
{
    [super init];
	[self setInterface:inInterface];
	[self setChannelModal:nil];
    return self;
}


//-- dealloc
// データの削除
- (void) dealloc
{
    [_scrollView release];
	[_channelModal release];
	[_channelView release];
	[_interface release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


//-- finalize
// 後片付け
-(void) finalize
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super finalize];
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
// Channel Viewをnibから作成する
- (void) createChannelView
{
    id textView;
    NSNotificationCenter*   center;
    
    if (![NSBundle loadNibNamed:@"ChannelView" owner:self]) {
        NSLog(@"Failed to load ChannelView.nib");
        NSBeep();
        return;
    }

    // scroll viewのaccessoryの設定
    [_scrollView addVerticalAccessoryView:_tearButton];
    [_scrollView addVerticalAccessoryView:_latchButton];
    
    [_scrollView tile];
    textView = [_scrollView contentView];
    // サイズ変更の notificationを受け取る
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didScroll:)
				   name:NSViewBoundsDidChangeNotification
				 object:textView];
    [textView setPostsBoundsChangedNotifications:YES];
    [_scrollView retain];
	[_channelView retain];
	// 親viewは使用しないので捨てる.
	NSView* view = [_scrollView superview];
    [_scrollView removeFromSuperview];
	[view release];
   
	NSObjectController* prefController = [_interface sharedPreferenceController];
	[_channelView bind:@"font" toObject:prefController withKeyPath:@"selection.textFont"
			options:[NSDictionary dictionaryWithObject:[NSString stringWithString:@"FontNameToFontTransformer"]
												forKey:@"NSValueTransformerName"]];
	[_channelView bind:@"urlColor" toObject:prefController withKeyPath:@"selection.urlColor"
			options:[NSDictionary dictionaryWithObject:[NSString stringWithString:@"ColorNameToColorTransformer"]
												forKey:@"NSValueTransformerName"]];
	[_channelView bind:@"backgroundColor" toObject:prefController withKeyPath:@"selection.backgroundColor"
			   options:[NSDictionary dictionaryWithObject:[NSString stringWithString:@"ColorNameToColorTransformer"]
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
- (BOOL) appendString:(NSAttributedString*)inString append:(NSAttributedString*)inAppend at:(int)inAppendIndex
{
	return [_channelView appendString:inString append:inAppend at:inAppendIndex scrollLock:_lockedScroll];
}

@end


