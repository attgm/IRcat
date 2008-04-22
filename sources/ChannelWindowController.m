//
//  $RCSfile: ChannelWindowController.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "IRcatInterface.h";
#import "NickListView.h";
#import "InputSheet.h";
#import "PopSplitView.h";
#import "PreferenceWindowController.h";
#import "ChannelModal.h"
#import "ChannelWindowController.h"
#import "BufferedFieldEditor.h"

@implementation ChannelWindowController

#pragma mark Init
//-- initWithInterface
// 初期化ルーチン. メインウィンドウの生成/表示を行う
-(id) initWithInterface:(IRcatInterface*) inInterface
{
	[super init];
	
	if(self){
		_interface = [inInterface retain];
		[self createWindow];
	}
	return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[_activeChannel release];
	[_window release];
	[_fieldEditor release];
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
		
		NSImageCell* cell = [[[NSImageCell alloc] init] autorelease];
		[_nickListView setIntercellSpacing:NSMakeSize(0.0, 0.0)];
		[[_nickListView tableColumnWithIdentifier:@"icon"] setDataCell:cell];
        [[_nickListView tableColumnWithIdentifier:@"op"] setDataCell:cell];
        // splitの位置を設定
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSNumber* number;
		if(number = [defaults objectForKey:kWindowCollapseRatio]){
			[_popSplitView setCollapseRatio:[number floatValue]];
		}
		if(number = [defaults objectForKey:kWindowSplitRatio]){
			[_popSplitView setSplitRatio:[number floatValue]];
		}
		[_popSplitView setCollapse:YES];
		
		
		NSObjectController* prefController = [_interface sharedPreferenceController];
		
		[_nickListView bind:@"font" toObject:prefController withKeyPath:@"selection.textFont"
					options:[NSDictionary dictionaryWithObject:[NSString stringWithString:@"FontNameToFontTransformer"]
														forKey:@"NSValueTransformerName"]];
		[_inputField bind:@"font" toObject:prefController withKeyPath:@"selection.textFont"
				  options:[NSDictionary dictionaryWithObject:[NSString stringWithString:@"FontNameToFontTransformer"]
													  forKey:@"NSValueTransformerName"]];
		
		[_inputField setAllowsEditingTextAttributes:NO];
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
- (void) updatePreferences:(NSNotification*) notification
{
	[self changeFont:nil];
	[_inputField setBackgroundColor:[PreferenceModal prefForKey:kBackgroundColor]];
	[_inputField setTextColor:[PreferenceModal prefForKey:kTextColor]];	
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
- (int) selectedIndexOnNickList 
{
	return [_nickListView selectedRow];
}


//-- setTopic
// topicの設定
- (void) setTopic:(NSString*) inTopic
{
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

@end
