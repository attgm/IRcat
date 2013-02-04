//
//  $RCSfile: ChannelWindowController.m,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "IRcatInterface.h"
#import "NickListView.h"
#import "InputSheet.h"
#import "PopSplitView.h"
#import "PreferenceWindowController.h"
#import "ChannelModal.h"
#import "ChannelWindowController.h"
#import "BufferedFieldEditor.h"
#import "NickListItem.h"
#import "INAppStoreWindow.h"

@implementation ChannelWindowController

#pragma mark Init
//-- initWithInterface
// 初期化ルーチン. メインウィンドウの生成/表示を行う
-(id) initWithInterface:(IRcatInterface*) inInterface
{
	self = [super init];
	
	if(self != nil){
		_interface = [inInterface retain];
        _channelName = nil;
		[self createWindow];
	}
	return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
    [_nickListView unbind:@"font"];
    [_inputField unbind:@"font"];
    
    [_interface release];
	[_activeChannel release];
	[_window release];
	[_fieldEditor release];
    [_topicTextField release];
    [_channelName release];
	[super dealloc];
}


//-- createWindow
// メインウィンドウをnibから生成する
-(void) createWindow
{
	if (!_window) {
		if(![NSBundle loadNibNamed:@"TearOffWindow" owner:self]){
			NSLog(@"Failed to load TearOffWindow.nib");
			NSBeep();
			return;
		}
		
        if([[_window class] isSubclassOfClass:[INAppStoreWindow class]]){
            INAppStoreWindow* window = (INAppStoreWindow*) _window;
            window.trafficLightButtonsLeftMargin = 7.0;
            window.fullScreenButtonRightMargin = 7.0;
            window.titleBarHeight = 36.0;
            window.hideTitleBarInFullScreen = NO;
        }
        
		NSImageCell* cell = [[[NSImageCell alloc] init] autorelease];
		[_nickListView setIntercellSpacing:NSMakeSize(0.0, 0.0)];
		[[_nickListView tableColumnWithIdentifier:@"icon"] setDataCell:cell];
        [[_nickListView tableColumnWithIdentifier:@"op"] setDataCell:cell];
        
        // splitの位置を設定
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSNumber* number;
		if((number = [defaults objectForKey:kWindowCollapseRatio]) != NULL){
			[_popSplitView setCollapseRatio:[number floatValue]];
		}
		if((number = [defaults objectForKey:kWindowSplitRatio]) != NULL){
			[_popSplitView setSplitRatio:[number floatValue] animate:NO];
		}
		[_popSplitView setCollapse:YES];
		
		
		NSObjectController* prefController = [_interface sharedPreferenceController];
		
		[_nickListView bind:@"font" toObject:prefController withKeyPath:@"selection.textFont"
					options:[NSDictionary dictionaryWithObject:@"FontNameToFontTransformer"
														forKey:@"NSValueTransformerName"]];
		[_inputField bind:@"font" toObject:prefController withKeyPath:@"selection.textFont"
				  options:[NSDictionary dictionaryWithObject:@"FontNameToFontTransformer"
													  forKey:@"NSValueTransformerName"]];
		[_inputField setAllowsEditingTextAttributes:NO];
        
        [[_modeTextView cell] setBackgroundStyle:NSBackgroundStyleRaised];
        
        
        if([[_window class] isSubclassOfClass:[INAppStoreWindow class]]){
            INAppStoreWindow* window = (INAppStoreWindow*) _window;
            //NSButton *fullScreen = [_window standardWindowButton:NSWindowFullScreenButton];
            NSButton *zoomButton = [window standardWindowButton:NSWindowZoomButton];
            
            CGFloat leftOffset = zoomButton.frame.origin.x + zoomButton.frame.size.width + window.trafficLightButtonsLeftMargin;
            CGFloat rightOffset = window.trafficLightButtonsLeftMargin;
            
            NSView *titleBarView = window.titleBarView;
            
            _channelName = [[self createToolbarChannelNameTextField] retain];
            [_channelName setFrame:NSMakeRect(leftOffset, 8.0, 160.0, [_channelName frame].size.height)];
            [titleBarView addSubview:_channelName];
            
            _topicTextField = [[self createToolbarTopicTextField] retain];
            CGFloat x = NSMaxX([_channelName frame]) + 8.0;
            CGFloat width = titleBarView.frame.size.width - rightOffset - x;
            [_topicTextField setFrame:NSMakeRect(x, 8.0, width, [_topicTextField frame].size.height)];
            [titleBarView addSubview:_topicTextField];
            
            
            
        }

	}
	[_window makeKeyAndOrderFront:nil];
    
}


#pragma mark Action
//-- enterMessage
// 発言fieldでenterキーが押された時の処理
- (IBAction)enterMessage:(id)sender
{
    [_interface enterMessageByString:[_inputField stringValue] to:_activeChannel];
    [_inputField setStringValue:@""];
    [self focusTextField];
}


#pragma mark User Interface
//-- updatePreferences
// fontのreload
/* - (void) updatePreferences:(NSNotification*) notification
{
    NSLog(@"updatePreferences");
	[self changeFont:nil];
	[_inputField setBackgroundColor:[PreferenceModal prefForKey:kBackgroundColor]];
	[_inputField setTextColor:[PreferenceModal prefForKey:kTextColor]];	
}*/


//-- preferenceController
// 共通の初期設定コントローラを返す
-(NSObjectController*) preferenceController
{
	return [_interface sharedPreferenceController];
}


#pragma mark -
#pragma mark Channel
//-- refleshNickList
// NickListの再読込みを行う
- (void) refleshNickList
{
    [_nickListView reloadData]; 
}


//-- refleshLogIcon
// log iconの再読込みを行う
- (void) refleshLogIcon
{
    [_logImage setImage:
		[NSImage imageNamed:([_activeChannel loggingChannel] ? @"log_on" : @"log_off")]];
}


//-- selectedIndexOnNickList
// nicklist上で選択されている要素を返す
- (NSInteger) selectedIndexOnNickList
{
	return [_nickListView selectedRow];
}


//-- setTopic
// topicの設定
- (void) setTopic:(NSString*) inTopic
{
    [_topicTextField setStringValue:inTopic];
}


//-- setModeString
// mode 文字列を設定
- (void) setModeString:(NSString*)inModeString
{
	if([inModeString length] > 0){
		[_modeTextView setStringValue:[NSString stringWithFormat:@"[%@]", inModeString]];
	}else{
		[_modeTextView setStringValue:@"[ ]"];
	}	
}



#pragma mark -
#pragma mark Sheet
//-- applySheet
- (IBAction)applySheet:(id)sender
{
    [[NSApplication sharedApplication] endSheet:_activeSheet returnCode:NSOKButton];
}


//-- cancelSheet
- (IBAction)cancelSheet:(id)sender
{
    [[NSApplication sharedApplication] endSheet:_activeSheet returnCode:NSCancelButton];
}


//-- showSheet
- (void) showSheet:(InputSheet*) inSheet
{
    // もしシートが既に表示されていた場合, そのシートを閉じる
    if(_activeSheet != nil){
        [[NSApplication sharedApplication] endSheet:_activeSheet returnCode:NSCancelButton];
    }
    // シートの表示
    [[NSApplication sharedApplication] beginSheet:[inSheet sheet]
								   modalForWindow:_window
									modalDelegate:self
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
									  contextInfo:[inSheet retain]];
	_activeSheet = [inSheet sheet];
}


//-- sheetDidEnd:returnCode:contextInfo:
// 2つの文字列を訪ねるタイプのSheetが終了した時の処理
- (void) sheetDidEnd : (NSSavePanel *) inSheet
		  returnCode : (int) inReturnCode
		 contextInfo : (id) inContextInfo
{
    [_activeSheet orderOut:self];
    [_activeSheet close];
    _activeSheet = nil;
    // OKが押されたらformatに従ったコマンドの実行
    if (inReturnCode == NSOKButton) {
		[inContextInfo performAction];
    }
    [inContextInfo release];
}

#pragma mark -


//-- focusTextField
// text fieldにfocusを移す
- (void)focusTextField
{
    if([_window firstResponder] != _inputField) {
        [_window makeFirstResponder:_inputField];
    }
}


//-- setChannelModal
// channel modalの設定
-(void) switchChannel:(ChannelModal*) inChannelModal
{
	if(inChannelModal != _activeChannel){
		[self setActiveChannel:inChannelModal];
		[self setDocumentView:[inChannelModal channelView]];
	
		//-- NickListの変更
		[_nickListView setDataSource:inChannelModal];
		[_nickListView reloadData];
		[_nickListView setContextMenu:inChannelModal target:_interface];
		//-- topicの変更
		[self setTopic:[inChannelModal topic]];
		//-- statusの更新
		[self refleshLogIcon];
		[self setModeString:[inChannelModal channelFlagString]];
		//-- window titleの設定
		[_window setTitle:[inChannelModal aliasName]];
        [_channelName setStringValue:[inChannelModal aliasName]];
	}
	[_window makeKeyAndOrderFront:nil];
}


//-- setActiveChannel
// controlしているチャンネルの設定
-(void) setActiveChannel:(ChannelModal*) inChannelModal
{
	if(inChannelModal != _activeChannel){
		[_activeChannel release];
		_activeChannel = [inChannelModal retain];
	}
}


//-- activeChannel
// controllしているチャンネルを返す
-(ChannelModal*) activeChannel
{
	return _activeChannel;
}


//-- setDocumentView
// text viewの設定
- (void) setDocumentView:(NSScrollView*) inChannelView
{
    [inChannelView setFrame:[_channelClipView frame]];
    [_channelClipView setDocumentView:inChannelView];
	[[inChannelView documentView] moveToEndOfDocument:self];
}


#pragma mark delegate:NSWindow
//-- windowWillColse
// ウィンドウが閉じる時に呼び出される
- (void) windowWillClose : (NSNotification*) aNotification
{
	[_window retain]; // Windowの解放を遅らせる
	[_interface tearChannel:_activeChannel];
}


//-- windowDidBecomeKey
-(void) windowDidBecomeKey : (NSNotification*) aNotification
{
	[_interface setKeyWindowController:self];
}

#pragma mark Field Editor
//-- fieldEditor
// オリジナルのフィールドエディタを返す
-(id) fieldEditor
{
	if(!_fieldEditor){
		_fieldEditor = [[BufferedFieldEditor alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
		[_fieldEditor setFieldEditor:YES];
		[_fieldEditor setKeyView:_inputField];
	}
	return _fieldEditor;
}


//-- windowWillReturnFieldEditor:toObject:
// フィールドエディタを返す
-(id) windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id) obj
{
	return [self fieldEditor];
}


#pragma mark Delegate : NSPopupView
//-- splitViewDidResizeSubviews
// change popup button icon in accordance with the devider position
- (void)    splitViewDidResizeSubviews:(NSNotification *) notification
{
    if(notification.object && [[notification.object class] isSubclassOfClass:[PopSplitView class]]){
        PopSplitView* view = (PopSplitView*) notification.object;
        if(view.splitRatio > 0.0f){
            [view.popButton setImage:[NSImage imageNamed:(view.isVertical ? @"icon_right" : @"icon_down")]];
        }else{
            [view.popButton setImage:[NSImage imageNamed:(view.isVertical ? @"icon_left" : @"icon_up")]];
        }
    }
}

#pragma mark Toolbar Control
//-- createToolbarTopicTextField
// create topic text field on toolbar (title bar)
-(NSTextField*) createToolbarTopicTextField
{
	NSTextField *field = [[[NSTextField alloc] initWithFrame:NSZeroRect] autorelease];
	
	[[field cell] setControlSize:NSRegularControlSize];
	[field setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
	[field setDrawsBackground:NO];
	[[field cell] setWraps:NO];
	[[field cell] setScrollable:YES];
	[field setEditable:NO];
	[field setBezeled:NO];
	[field setStringValue:@""];
	[field sizeToFit];
	[field setAutoresizingMask:(NSViewMinYMargin | NSViewWidthSizable)];
    
    return field;
}


//-- createToolbarChannelNameTextField
// create topic text field on toolbar (title bar)
-(NSTextField*) createToolbarChannelNameTextField
{
	NSTextField *field = [[[NSTextField alloc] initWithFrame:NSZeroRect] autorelease];
	
	[[field cell] setControlSize:NSRegularControlSize];
	[field setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
	[field setDrawsBackground:NO];
	[[field cell] setWraps:NO];
	[[field cell] setScrollable:YES];
    [[field cell] setBackgroundStyle:NSBackgroundStyleRaised];
	[field setEditable:NO];
	[field setBezeled:NO];
	[field setStringValue:@""];
	[field sizeToFit];
	[field setAutoresizingMask:(NSViewMinYMargin | NSViewWidthSizable)];
    
    return field;
}


#pragma mark Delegate : NSPopupView

//-- splitView:constrainMinCoordinate:ofSubviewAt:
//
-(CGFloat)          splitView:(NSSplitView *)splitView
       constrainMinCoordinate:(CGFloat)proposedMin
                  ofSubviewAt:(NSInteger)dividerIndex
{
    if(splitView == _popSplitView){
        if(dividerIndex == 0){
            return 120.0f;
        }
    }
    return proposedMin;
}


//-- interface
-(IRcatInterface*) interface
{
    return _interface;
}

@end
