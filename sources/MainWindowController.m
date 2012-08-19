//
//  $RCSfile: MainWindowController.m,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import "MainWindowController.h"
#import "ScrollView.h"

#import "PreferenceWindowController.h"
#import "ServersWindowController.h"

#import "IRCMessage.h"
#import "IRcatInterface.h"

#import "ChannelModal.h"
#import "NickListView.h"
#import "PopSplitView.h"
#import "InputSheet.h"
#import "TextFieldHistories.h"
#import "ConsoleTextView.h"
#import "BufferedFieldEditor.h"

#import "INAppStoreWindow.h"

NSString* const IRMainToolbarLabelTable	 = @"MainToolbar";
NSString* const IRTopicIdentifier		 = @"Topic";
NSString* const IRChannelPopupIdentifier = @"ChannelPopup";
NSString* const IRTopicPrefix			 = @"TopicPrefix";


@implementation MainWindowController

#pragma mark Init
//-- initWithInterface
// 初期化ルーチン. メインウィンドウの生成/表示を行う
- (id) initWithInterface:(IRcatInterface*) inInterface
{
    self = [super initWithInterface:inInterface];
    return self;
}


//-- dealloc
-(void) dealloc
{
#if !__has_feature(objc_arc)
    [_textFieldHistories release];
    [_channelPopup release];
    [_topicTextField release];
#endif
	[super dealloc];
}


//-- createWindow (over write)
// メインウィンドウをnibから生成する
- (void) createWindow
{
    NSImageCell *imageCell;
    
    if (!_window) {
		if (![NSBundle loadNibNamed:@"MainWindow" owner:self]) {
			NSLog(@"Failed to load MainWindow.nib");
			NSBeep();
            return;
		}
        
        INAppStoreWindow* window = (INAppStoreWindow*) _window;
        window.trafficLightButtonsLeftMargin = 7.0;
        window.fullScreenButtonRightMargin = 7.0;
        window.titleBarHeight = 36.0;
        window.centerFullScreenButton = YES;
        
		_channelMenu = [[NSMenu alloc] initWithTitle:@"Channel"];
		
		/*NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:@"MainToolbar"] autorelease];
		[toolbar setDelegate:self];
		[toolbar setAllowsUserCustomization:NO];
		[toolbar setAutosavesConfiguration:YES];
		[toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
		[toolbar setAllowsUserCustomization:YES];
		[_window setToolbar:toolbar];*/
		
		// NickListの設定
        imageCell = [[[NSImageCell alloc] init] autorelease];
        [_nickListView setIntercellSpacing:NSMakeSize(0.0, 0.0)]; // cell間隔を0にする
        [[_nickListView tableColumnWithIdentifier:@"icon"] setDataCell:imageCell];
        [[_nickListView tableColumnWithIdentifier:@"op"] setDataCell:imageCell];
		[_channelMenu setAutoenablesItems:NO];
		
		// clipのbackground colorを設定
		[_channelClipView setBackgroundColor:[NSColor windowBackgroundColor]];

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
		if((number = [defaults objectForKey:kPaneSplitRatio]) != NULL){
			[_paneSplitView setSplitRatio:[number floatValue] animate:NO];
		}
		[_paneSplitView setCollapse:NO];
		
		// Historyを生成
		_textFieldHistories = [[TextFieldHistories alloc] init];
		[_inputField setDelegate:_textFieldHistories];
        
        
        NSView *titleBarView = window.titleBarView;
        _channelPopup = [[self createToolbarChannelPopup] retain];
        [_channelPopup setFrame:NSMakeRect(70.0, 4.0, 160.0, [_channelPopup frame].size.height)];
        [titleBarView addSubview:_channelPopup];
        
        _topicTextField = [[self createToolbarTopicTextField] retain];
        CGFloat x = 70.0 + 160.0 + 8.0;
        CGFloat width = [titleBarView frame].size.width - (x + 32.0);
        [_topicTextField setFrame:NSMakeRect(x, 8.0, width, [_topicTextField frame].size.height)];
        [titleBarView addSubview:_topicTextField];
        
        [[_modeTextView cell] setBackgroundStyle:NSBackgroundStyleRaised];
    }
    
    NSDictionary* transformer = 
		[NSDictionary dictionaryWithObject:@"FontNameToFontTransformer"
									forKey:@"NSValueTransformerName"];
	NSObjectController* prefController = [_interface sharedPreferenceController];
	[_nickListView bind:@"font" toObject:prefController withKeyPath:@"selection.textFont" options:transformer];
	[_inputField bind:@"font" toObject:prefController withKeyPath:@"selection.textFont" options:transformer];
	[_commonTextView bind:@"font" toObject:prefController withKeyPath:@"selection.textFont" options:transformer];
	[_inputField bind:@"font" toObject:prefController withKeyPath:@"selection.textFont" options:transformer];
	
	NSDictionary* colorTransformer = 
		[NSDictionary dictionaryWithObject:@"ColorNameToColorTransformer"
									forKey:@"NSValueTransformerName"];
	[_commonTextView bind:@"textColor" toObject:prefController withKeyPath:@"selection.textColor" options:transformer];
	[_commonTextView bind:@"backgroundColor" toObject:prefController withKeyPath:@"selection.backgroundColor" options:colorTransformer];
	[_inputField bind:@"textColor" toObject:prefController withKeyPath:@"selection.textColor" options:colorTransformer];
	[_inputField bind:@"backgroundColor" toObject:prefController withKeyPath:@"selection.backgroundColor" options:colorTransformer];
	[_inputField setAllowsEditingTextAttributes:NO];
	
	[_window makeKeyAndOrderFront:nil];
}

#pragma mark User Interface

 
//-- setHasSession
// sessionの有無のセット
- (void) setHasSession:(BOOL)inHasSession
{
	[_window setDocumentEdited:inHasSession];
}


#pragma mark Popup Menu
//-- addMenuItem
// menu itemの追加
-(void) addMenuItemByChannelModal : (ChannelModal*) inChannelModal
{
	NSMenuItem* newItem;
	
	if(inChannelModal == nil){
		[_channelMenu addItem:[NSMenuItem separatorItem]];
	}else{
		newItem = [_channelMenu addItemWithTitle:@""
										  action:@selector(switchChannelbyChannelPopup:)
								   keyEquivalent:@""];
		[newItem setTarget:self];
		//[newItem setTag:([_channelMenu numberOfItems] - 1)];
		[newItem bind:@"tag" toObject:inChannelModal withKeyPath:@"channelid" options:nil];
		[newItem bind:@"title" toObject:inChannelModal withKeyPath:@"aliasName" options:nil];
		[newItem bind:@"image" toObject:inChannelModal withKeyPath:@"iconName"
			  options:[NSDictionary dictionaryWithObject:@"ImageNameToImageTransformer"
												  forKey:@"NSValueTransformerName"]];
		[newItem bind:@"enabled" toObject:inChannelModal withKeyPath:@"enableChannel" options:nil];
	}
}


- (void) addMenuItem : (NSString*) inChannelName
{
    NSMenuItem* newItem;
    
    // nilの場合はセパレタを追加する
    if(inChannelName == nil){
		[_channelMenu addItem:[NSMenuItem separatorItem]];
	}else{
        newItem = [_channelMenu addItemWithTitle:@""
										  action:@selector(switchChannelbyChannelPopup:)
								   keyEquivalent:@""];
        [newItem setTarget:self];
		[newItem setTag:([_channelMenu numberOfItems] - 1)];
		[newItem setEnabled:YES];
    }
}



//-- menuItemToSeparator
// menu itemをセパレタに変更する
- (void) menuItemToSeparator : (int) inIndex
{
	NSMenuItem* item = [_channelMenu itemAtIndex:inIndex];
	[item setImage:[NSImage imageNamed:@"channel_none"]];
	[item setTarget:nil];
	[item setEnabled:NO];
}


//-- setEnableMenuItem:atIndex:
// popupへの選択可能の設定
-(void) setEnableMenuItem:(BOOL) inEnable
				  atIndex:(int) inIndex
{
	NSMenuItem* item = [_channelMenu itemAtIndex:inIndex];
	[item setEnabled:inEnable];
}


//-- renameMenuItem:atIndex
// menuitemをrenameする
- (void) renameMenuItem:(NSString*)inString
                atIndex:(int) inIndex
{
	return;
	
    NSMenuItem* item;
	
    item = [_channelMenu itemAtIndex:inIndex];
    // セパレタだった場合削除して新しいitemを挿入する
    if([item isSeparatorItem] == YES){
        [_channelMenu removeItemAtIndex:inIndex];
        item = [_channelMenu insertItemWithTitle:inString
										  action:@selector(switchChannelbyChannelPopup:)
								   keyEquivalent:@""
										 atIndex:(inIndex - 1)];
        [item setTarget:self];
        [item setImage:[NSImage imageNamed:@"channel_console"]];
    }else{
		[item setTarget:self];
		[item setTitle:inString];
    }
	[item setEnabled:YES];
}


//-- setMenuImage:atIndex
// menuitemをrenameする
- (void) setMenuImage:(NSImage*)inImage
			  atIndex:(int) inIndex
{
	NSMenuItem* item = [_channelMenu itemAtIndex:inIndex];
    // セパレタだった場合削除して新しいitemを挿入する
    [item setImage:inImage];
}



//-- removeLastMenuItem
// 最後のitemを削除する
-(void) removeLastMenuItem
{
    [_channelMenu removeItemAtIndex:([_channelMenu numberOfItems] - 1)];
}


//-- switchChannelbyChannelPopup
// チャンネルPOPUPが選択された時の処理
- (IBAction) switchChannelbyChannelPopup:(id) inSender
{
	[_interface switchChannelAtIndex:[inSender tag]]; 
}


//-- switchChannel
// チャンネルの更新
- (void) switchChannel:(ChannelModal*) inNewChannel
{
    NSScrollView* view = [inNewChannel channelView];
    [self setDocumentView:view];
	//[[inNewChanel channelViewController] setInputField:
	_activeChannel = inNewChannel;
	//-- NickListの変更
    [_nickListView setDataSource:inNewChannel];
    [_nickListView reloadData];
    [_nickListView setContextMenu:inNewChannel target:_interface];
    //-- topicの変更
    [self setTopic:[inNewChannel topic]];
	//-- statusの更新
	[self refleshLogIcon];
	[self setModeString:[inNewChannel channelFlagString]];
	
	
    [_channelPopup selectItemWithTag:[inNewChannel channelid]];
    NSEnumerator* e = [[[_channelPopup menu] itemArray] objectEnumerator];
    NSMenuItem* mi;
	while(mi = [e nextObject]){
        [mi setState:NSOffState];
    }

	[_window makeKeyAndOrderFront:nil];
}


-(BOOL) validateMenuItem:(NSMenuItem*)item
{
	if([item action] == @selector(switchChannelbyChannelPopup:)){
		[item setState:(([_activeChannel channelid] == [item tag]) ? NSOnState : NSOffState)];
	}
	return YES;
}

#pragma mark -
#pragma mark SplitView
//-- collapseChannelSplitView
// collapse console view
-(IBAction) collapseChannelSplitView:(id)sender
{
    
}


#pragma mark -
#pragma mark Channel

//-- setTopic (over write)
// topicの設定
- (void) setTopic:(NSString*)inTopic
{
	if (_topicString) { [_topicString release]; }
	_topicString = [[NSString stringWithString:(inTopic ? inTopic : @"no topic")] retain];
	
    if(_topicTextField != nil){
        [_topicTextField setStringValue:_topicString];
    }
	/*NSToolbarItem* it = [self toolbarItemByIdentifier:@"Topic"];
	if(it){
		NSTextField* topicField = (NSTextField*)([it view]);
		if(topicField){
			[topicField setStringValue:_topicString];
		}
		
		NSMenuItem* item = [it menuFormRepresentation];
		if(item != nil){
			[item setTitle:[NSString stringWithFormat:@"Topic:%@", _topicString]];
			[it setMenuFormRepresentation:item];
		}
	}*/
}


//-- selectedChannel 
// 選択されているチャンネルを返す
-(ChannelModal*) selectedChannel
{
	return _activeChannel;
}


#pragma mark -
#pragma mark Toolbar
//-- toolbarItemByIdentifier
// IDから現在表示されているNSToolbarのtoolbarItemを返す
- (NSToolbarItem*) toolbarItemByIdentifier:(NSString*) inIdentifier
{
	NSToolbar* toolbar = [_window toolbar];
	NSArray* items = [toolbar items];
	NSEnumerator* e = [items objectEnumerator];
	NSToolbarItem* it;
	while(it = [e nextObject]){
		if([[it itemIdentifier] isEqualToString:inIdentifier]){
			return it;
		}
	}
	return nil;
}


//-- actionToolbar
// toolbar上のボタンが押された時の関数
- (IBAction) actionToolbar : (id) sender
{
	// とりあえず何もしないっ！
}


#pragma mark -
#pragma mark Sheet
//-- askFromMenu
// Menuから選択させる
- (void) askFromMenu:(NSMenu*) inMenu
			 withTag:(int) inDefaultTag
			 caption:(NSString*) inCaption
			  format:(NSString*) inFormat
{
	// もしシートが既に表示されていた場合, そのシートを閉じる
    if(_activeSheet != nil){
        [[NSApplication sharedApplication] endSheet:_activeSheet returnCode:NSCancelButton];
    }
	// シートの生成
    if(!_menuSheet){
        if (![NSBundle loadNibNamed:@"MenuSheet" owner:self]) {
            NSLog(@"Failed to load MenuSheet.nib");
			NSBeep();
            return;
		}
	}
	[_menuTitle setStringValue:NSLocalizedString(@"Server :", @"Server :")];
    // キャプションとメニューを更新
	[_menuCaption setStringValue:inCaption];
	[_menuPopUp setMenu:inMenu];
	[_menuPopUp selectItemWithTag:inDefaultTag];
	if([_menuPopUp indexOfSelectedItem] < 0){
		[_menuPopUp selectItemAtIndex:0];
	}
	// シートの表示
    _activeSheet = _menuSheet;
    [_menuSheet makeFirstResponder:_menuPopUp];
    [[NSApplication sharedApplication] beginSheet:_menuSheet
								   modalForWindow:_window
									modalDelegate:self
								   didEndSelector:@selector(sheetMenuDidEnd:returnCode:contextInfo:)
									  contextInfo:[inFormat copyWithZone:[self zone]]];
}


//-- sheetMenuDidEnd:returnCode:contextInfo:
// メニューで訪ねるタイプのSheetが終了した時の処理
- (void) sheetMenuDidEnd : (NSSavePanel *) inSheet
             returnCode : (int) inReturnCode
            contextInfo : (id) inContextInfo
{
    [_activeSheet orderOut:self];
    [_activeSheet close];
    _activeSheet = nil;
    
    // OKが押されたらformatに従ったコマンドの実行
    if (inReturnCode == NSOKButton) {
		[_interface obeyIRCCommand:[NSString stringWithFormat:inContextInfo, [[_menuPopUp selectedItem] tag]]
								to:_activeChannel];
    }
	[inContextInfo release];
}



#pragma mark -
//-- appendStringToCommon:appendString:at:
// 共有Viewにメッセージを追加する
- (BOOL) appendStringToCommon:(NSAttributedString*)inString
                       append:(NSAttributedString*)inAppend
                           at:(int)inIndex
{
	return [_commonTextView appendString:inString append:inAppend at:inIndex scrollLock:NO];
}

#pragma mark -
#pragma mark Delegate:NSWindow

//-- windowShouldClose (over write)
// ウィンドウを閉じていいかの呼び出し
- (BOOL) windowShouldClose : (NSNotification*) aNotification
{
	if([_window isDocumentEdited]){
		[_window makeKeyAndOrderFront:nil];
		NSBeginAlertSheet(NSLocalizedString(@"MGSessionConnected", @"There is active session. Close?"),
						  NSLocalizedString(@"OK", @"OK"),
						  @"",
						  NSLocalizedString(@"Cancel", @"Cancel"),
						  _window,
						  self,
						  nil,
						  @selector(didEndCloseSheet:returnCode:contextInfo:), 
						  nil,
						  NSLocalizedString(@"MGSessionClose", @"If this window is closed, all session is disconnected."));
		return NO;
	}
	return YES;
}


//-- didEndCloseSheet:returnCode:contextInfo
- (void)didEndCloseSheet:(NSWindow *)sheet
			  returnCode:(int)returnCode
			 contextInfo:(void *)contextInfo
{	
    if (returnCode == NSAlertDefaultReturn) {       // "OK"
		[_window close];
	} else if (returnCode == NSAlertOtherReturn) {  // "Cancel"
	}
}


//-- windowWillColse
// ウィンドウが閉じる時に呼び出される
- (void) windowWillClose : (NSNotification*) aNotification
{
	if([aNotification object] == _window){
		// splitの位置を保存
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[NSNumber numberWithFloat:[_popSplitView collapseRatio]]
					forKey:kWindowCollapseRatio];
		[defaults setObject:[NSNumber numberWithFloat:[_popSplitView splitRatio]]
					 forKey:kWindowSplitRatio];
		[defaults setObject:[NSNumber numberWithFloat:[_paneSplitView splitRatio]]
					 forKey:kPaneSplitRatio];
		[defaults synchronize];
		
		[[NSNotificationCenter defaultCenter]
			postNotificationName:@"IRcatWindowWillCloseNotification" object:_interface userInfo:nil];
		[NSApp terminate:nil];
	}
}


#pragma mark -
//-- focusNotified
- (void)focusNotified:(NSNotification*)notification
{
    [self focusTextField];
}

//-- focusTextField
//
- (void)focusTextField
{
    if([_window firstResponder] != _inputField) {
        [_window makeFirstResponder:_inputField];
    }
}

//-- setDocumentView
// text viewの設定
- (void) setDocumentView:(NSScrollView*) inChannelView
{
    [inChannelView setFrame:[_channelClipView frame]];
    [_channelClipView setDocumentView:inChannelView];
	[[inChannelView documentView] moveToEndOfDocument:self];
}


//-- windowDidBecomeKey
-(void) windowDidBecomeKey : (NSNotification*) aNotification
{
	[_interface setKeyWindowController:self];
}


//-- activeChannel
//
-(ChannelModal*) activeChannel
{
	return _activeChannel;
}


#pragma mark deletage : NSToolbar
//-- toolbarDefaultItemIdentifiers
// 初期toolbarの内容を返す
- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:IRChannelPopupIdentifier, IRTopicIdentifier, nil];
}


//-- toolbarAllowedItemIdentifiers
// 設定可能なtoolbarの選択肢を返す
- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:
		IRChannelPopupIdentifier, IRTopicIdentifier, NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
		nil];
}


//-- toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar
// toolbarのエントリを返す
- (NSToolbarItem *)     toolbar : (NSToolbar *) toolbar
          itemForItemIdentifier : (NSString *) itemIdentifier
      willBeInsertedIntoToolbar : (BOOL) flag
{
	if([itemIdentifier isEqualToString:IRTopicIdentifier]){
		return [self toolbarTopicItem:flag];
	}else if([itemIdentifier isEqualToString:IRChannelPopupIdentifier]){
		return [self toolbarChannelItem:flag];
	}
	return nil;
}


//-- toolbarTopicItem
// topic toolbarを返す
-(NSToolbarItem*) toolbarTopicItem : (BOOL) flag
{
	static NSString*    label = nil;
	if(!label){ label = [NSLocalizedStringFromTable(IRTopicIdentifier, IRMainToolbarLabelTable, nil) retain]; }
	
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:IRTopicIdentifier] autorelease];
	[item setLabel:label];
	[item setPaletteLabel:label];
	
	NSTextField *field = [[[NSTextField alloc] initWithFrame:NSZeroRect] autorelease];
	
	[[field cell] setControlSize:NSSmallControlSize];
	[field setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
	[field setDrawsBackground:NO];
	[[field cell] setWraps:NO];
	[[field cell] setScrollable:YES];
	[field setEditable:NO];
	[field setBezeled:NO];
	[field setStringValue:(_topicString ? _topicString : @"")];
	[field sizeToFit];
	[field setAutoresizingMask:NSViewWidthSizable];
	[item setView:field];
	[item setMinSize:NSMakeSize(64, [field frame].size.height)];
	[item setMaxSize:NSMakeSize(1024, [field frame].size.height)];
	if(flag){
		NSMenuItem* mi =[[[NSMenuItem alloc] init] autorelease];
		[mi setAction:@selector(actionToolbar:)];
		[mi setTarget:self];
		[mi setTitle:NSLocalizedStringFromTable(IRTopicPrefix, IRMainToolbarLabelTable, nil)];
		[item setMenuFormRepresentation:mi];
	}
	
	return item;
}


//-- toolbarChannelItem
// channel toolbarを返す
-(NSToolbarItem*) toolbarChannelItem:(BOOL) flag
{
	static NSString*    label = nil; 
	if(!label){ label = [NSLocalizedStringFromTable(IRChannelPopupIdentifier, IRMainToolbarLabelTable, nil) retain]; }

	
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:IRChannelPopupIdentifier] autorelease];
	[item setLabel:label];
	[item setPaletteLabel:label];
	
	NSPopUpButton *popup = [self createToolbarChannelPopup];

    [item setView:popup];
	[item setMinSize:NSMakeSize(160, [popup frame].size.height)];
	[item setMaxSize:NSMakeSize(160, [popup frame].size.height)];
	if(flag){
		NSMenuItem* mi = [[[NSMenuItem alloc] init] autorelease];
		[mi setSubmenu:_channelMenu];
		[mi setTitle:[_channelMenu title]];
		[item setMenuFormRepresentation:mi];
	}	
	return item;
}


//-- createToolbarChannelPopup
// create channel popup on toolbar (title bar)
-(NSPopUpButton*) createToolbarChannelPopup
{
    NSPopUpButton* popup = [[[NSPopUpButton alloc] initWithFrame:NSZeroRect] autorelease];
    [[popup cell] setBezelStyle:NSTexturedRoundedBezelStyle];
	[[popup cell] setArrowPosition:NSPopUpArrowAtBottom];
    [[popup cell] setControlSize:NSRegularControlSize];
    [popup setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
	[popup setMenu:_channelMenu];
	[popup sizeToFit];
	[popup setAction:@selector(switchChannelbyChannelPopup:)];
	[popup setTarget:self];
	[popup selectItemWithTag:[_activeChannel channelid]];
	[popup setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin)];
    
    return popup;
}

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
	[field setStringValue:(_topicString ? _topicString : @"")];
	[field sizeToFit];
	[field setAutoresizingMask:(NSViewMinYMargin | NSViewWidthSizable)];
    
    return field;

}

@end
