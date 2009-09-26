//
//  $RCSfile: PreferenceWindowController.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import "PreferenceModal.h"
#import "PreferenceWindowController.h"

//-- addToolbarItem
// ツールバーのアイテムを追加するユーテリティ関数
static NSToolbarItem* addToolbarItem(NSMutableDictionary *inDict,
						   NSString *inIdentifier,
						   NSString *inLabel,
						   NSString *inPaletteLabel,
						   NSString *inToolTip,
						   id 	inTarget,
						   SEL 	inSettingSelector,
						   id 	inItemContent,
						   SEL 	inAction,
						   NSMenu   *inMenu)
{
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:inIdentifier] autorelease];
    
    [item setLabel:inLabel];
    [item setPaletteLabel:inPaletteLabel];
    [item setToolTip:inToolTip];
    [item setTarget:inTarget];
    
    [item performSelector:inSettingSelector withObject:inItemContent];
    [item setAction:inAction];
    
    if (inMenu != NULL) {
		NSMenuItem* menuItem=[[[NSMenuItem alloc] init] autorelease];
		[menuItem setSubmenu:inMenu];
		[menuItem setTitle:[inMenu title]];
		[item setMenuFormRepresentation:menuItem];
    }
    [inDict setObject:item forKey:inIdentifier];
	return item;
}


@implementation PreferenceWindowController

static PreferenceWindowController *sSharedInstance = nil;

//-- init
//
- (id) init
{
	[super init];
    // 初期設定値
    _preferenceModal = [PreferenceModal sharedPreference];
    
	return self;
}


//-- sharedPreference
// インスタンスを得る
+ (id) sharedPreference
{
    if (!sSharedInstance) {
        sSharedInstance = [[PreferenceWindowController alloc] init];
    }
    return sSharedInstance;
}


//-- showPanel
// 環境設定ダイアログを表示させる
- (void) showPanel
{
    if (!_preferenceWindow) {
		 if (![NSBundle loadNibNamed:@"Preferences" owner:self]) {
            NSLog(@"Failed to load Preferences.nib");
			NSBeep();
            return;
		}
		[_panelViews release];
		_panelViews = [[NSDictionary alloc] initWithObjectsAndKeys:
			_panelUserInfo, kTagUserInfo, _panelFont, kTagFontAndColor, _panelView, kTagView,
			_panelNotification, kTagNotification, _panelFriends, kTagFriend,
			_panelLog, kTagLog, _panelEtc, kTagEtc, nil];
		_displayedPanel = _panelBase;
		[_panelBase retain];
		
		//-- 音の設定を強制的に変更する
		[self createSoundMenu];
		
		NSString* keep = [PreferenceModal prefForKey:kBeepFile];
		[[PreferenceModal sharedPreference] setValue:@"" forKey:kBeepFile];
		[[PreferenceModal sharedPreference] setValue:keep forKey:kBeepFile];
		[self createToolbar];
        
		[_preferenceWindow setExcludedFromWindowsMenu:YES];
		[_preferenceWindow setMenu:nil];
        
		[_friendsController setDefaultValues:[NSDictionary dictionaryWithObject:@"nick" forKey:@"name"]];
		[_friendsController setPrimeColumn:@"friend"];
		[_keywordsController setDefaultValues:[NSDictionary dictionaryWithObject:@"keyword" forKey:@"name"]];
		[_keywordsController setPrimeColumn:@"keyword"];
		[_logChannelsController setDefaultValues:[NSDictionary dictionaryWithObject:@"#channel" forKey:@"name"]];
		[_logChannelsController setPrimeColumn:@"logchannel"];
		
		[self switchPrefPanelById:kTagUserInfo animate:NO];
		[[_preferenceWindow toolbar] setSelectedItemIdentifier:kTagUserInfo];
		[[_preferenceWindow standardWindowButton:NSWindowToolbarButton] setHidden:YES];
        [_preferenceWindow center];
    }
    [_preferenceWindow makeKeyAndOrderFront:nil];
}


//-- preferenceForKey
// 設定値を返す
+ (id) preferenceForKey : (NSString*) inKey
{
    return [[self sharedPreference] objectForKey:inKey];
}


//-- objectForKey
// 設定値を返す
- (id) objectForKey : (NSString*) inKey
{
	return [PreferenceModal prefForKey:inKey];
}


//-- saveDefaults
// 初期設定を保存する
- (void) saveDefaults
{
    [_preferenceModal savePreferencesToDefaults];
}

//-- preferenceModal
//
-(id) preferenceModal
{
	return _preferenceModal;
}


#pragma mark User Interface
- (void) createSoundMenu
{
	[_beepMenu removeAllItems];
    
	NSArray* titles = [PreferenceModal soundArray];
	[_beepMenu addItemsWithTitles:titles];
	[_beepMenu synchronizeTitleAndSelectedItem];
}



//-- createToolBar
// tool barの生成
-(void) createToolbar
{
	NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:@"PreferenceToolBar"] autorelease];

	[_toolbarItems release];
	_toolbarItems = [[NSMutableDictionary dictionary] retain];

	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization:NO];
	addToolbarItem(_toolbarItems, kTagUserInfo,
				   NSLocalizedString(@"UserInfo", @"UserInfo"), NSLocalizedString(@"UserInfo", @"UserInfo"),
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_userinfo"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagFontAndColor,
				   NSLocalizedString(@"Font", @"Font"), NSLocalizedString(@"Font", @"Font"),
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_font"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagView,
				   NSLocalizedString(@"View", @"View"), NSLocalizedString(@"View", @"View"),
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_view"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagNotification,
				   NSLocalizedString(@"Notification", @"Notification"), NSLocalizedString(@"Notification", @"Notification"),
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_notification"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagFriend,
				   NSLocalizedString(@"Friends", @"Friends"), NSLocalizedString(@"Friends", @"Friends"),
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_friends"],
				   @selector(switchPrefPanel:), NULL);	
	addToolbarItem(_toolbarItems, kTagLog,
				   NSLocalizedString(@"Log", @"Log"), NSLocalizedString(@"Log", @"Log"),
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_log"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagEtc,
				   NSLocalizedString(@"Etc", @"Etc"), NSLocalizedString(@"Etc", @"Etc"),
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_etc"],
				   @selector(switchPrefPanel:), NULL);
	[toolbar setAutosavesConfiguration:YES];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];

	[_preferenceWindow setToolbar:toolbar];
}


//-- switchPrefPanel
// PrefPanelの切り替え
-(IBAction) switchPrefPanel:(id) sender
{
	[self switchPrefPanelById:[sender itemIdentifier] animate:YES];
}

//-- switchPrefPanelById
// PrefPanelの切り替え
-(void) switchPrefPanelById:(NSString*) identifier
					animate:(BOOL) animate
{
	NSView* view = [_panelViews objectForKey:identifier];
	NSRect windowFrame = [_preferenceWindow frame];
	NSRect contentFrame = [_displayedPanel frame];
	NSRect newFrame = [view frame];
	float diff = newFrame.size.height - contentFrame.size.height;
	windowFrame.size.height += diff;
	windowFrame.origin.y -= diff;
	newFrame.origin = contentFrame.origin;
	newFrame.size.width = contentFrame.size.width;
	
	BOOL viewHeightSizable = (([view autoresizingMask] & NSViewHeightSizable) != 0);
	
	[view setFrame:newFrame];
	[_preferenceWindow setMinSize:(viewHeightSizable ? NSMakeSize(420, 360) : NSMakeSize(420, 0))];
	[_preferenceWindow setMaxSize:NSMakeSize(FLT_MAX,FLT_MAX)];
	[[_preferenceWindow contentView] replaceSubview:_displayedPanel with:_panelBase];
	[_preferenceWindow setFrame:windowFrame display:YES animate:animate];
	[[_preferenceWindow contentView] replaceSubview:_panelBase with:view];
	_displayedPanel = view;
	[_preferenceWindow setShowsResizeIndicator:viewHeightSizable];
	
	NSButton *zoomButton = [_preferenceWindow standardWindowButton:NSWindowZoomButton];
	[zoomButton setEnabled:viewHeightSizable];
}

#pragma mark -

//-- aliasChannelName
// aliasに変換する
- (NSString*) aliasChannelName:(NSString*)inString safe:(BOOL)inSafeChannel
{
    if (inString == nil) return @"";
    
    if([inString hasPrefix:@"!"] && inSafeChannel && [inString length] > 5){ // safe channelの処理
        return [NSString stringWithFormat:@"!%@",
                [inString substringWithRange:NSMakeRange(6, [inString length] - 6)]];
    }
    if([inString hasPrefix:@"#"]){
        if([inString hasSuffix:@":*.jp"]){
            return [NSString stringWithFormat:@"%%%@",
                [inString substringWithRange:NSMakeRange(1, [inString length] - 6)]];
        }
    }
    return inString;
}


//-- realChannelName
// aliasから本当のチャンネル名前を返す
- (NSString*) realChannelName:(NSString*) inString
{
    // %で始まっている場合, 元に戻す
    if([inString hasPrefix:@"%"]){
        return [NSString stringWithFormat:@"#%@:*.jp",
                [inString substringWithRange:NSMakeRange(1, [inString length] - 1)]];
    }
    return inString;
}


//-- isLoggingChannel
// logを取るチャンネルかどうかの判定
- (BOOL) isLoggingChannel:(NSString*) inString
{
	NSString* alias = [self aliasChannelName:inString safe:YES];
	NSEnumerator* e = [[PreferenceModal prefForKey:kLogChannels] objectEnumerator];
	
	id obj;
	while(obj = [e nextObject]){
		NSString* channel = [obj objectForKey:@"name"];
		if([inString isEqualToString:channel] || [alias isEqualToString:channel]){
			return YES;
		}
	}
	return NO;
}


#pragma mark Sound
//-- playSelectedSound
// NSPopupが選択された時の処理
- (IBAction) playSelectedSound:(id) sender
{
	NSSound* sound = [NSSound soundNamed:[[sender selectedItem] title]];
	[sound play];
}

#pragma mark Log Folder Selector

//-- selectLogFolder
// logを保存するディレクトリの指定
- (IBAction)selectLogFolder:(id)sender
{
	NSOpenPanel  *op = [NSOpenPanel openPanel];
	
	[op setCanChooseFiles:NO];
	[op setCanChooseDirectories:YES];
	[op setResolvesAliases:YES];
	[op setCanCreateDirectories:YES];
	
	[op beginSheetForDirectory:[_preferenceModal valueForKey:kLogFolder]
						  file:nil
						 types:nil
				modalForWindow:_preferenceWindow
				 modalDelegate:self
				didEndSelector:@selector(didSelectLogFolder:returnCode:contextInfo:)
				   contextInfo:nil];
}


//-- didSelectLogFolder:returnCode:contextInfo:
// log保存場所の反映
- (void) didSelectLogFolder : (NSOpenPanel *) inSheet
				 returnCode : (int) inReturnCode
				contextInfo : (void *) inContextInfo
{
    if (inReturnCode == NSOKButton) {
		[_preferenceController setValue:[inSheet filename] forKeyPath:
			[NSString stringWithFormat:@"selection.%@", kLogFolder]];
	}
}


#pragma mark deletage : NSToolbar
//-- toolbarDefaultItemIdentifiers
// 初期toolbarの内容を返す
- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:kTagUserInfo, kTagFontAndColor, kTagView, kTagNotification, kTagFriend, kTagLog, kTagEtc, nil];
}


//-- toolbarSelectableItemIdentifiers
//
- (NSArray*) toolbarSelectableItemIdentifiers:(NSToolbar*) toolbar
{
	return  [NSArray arrayWithObjects:kTagUserInfo, kTagFontAndColor, kTagView, kTagNotification, kTagFriend, kTagLog, kTagEtc, nil];
}


//-- toolbarAllowedItemIdentifiers
// 設定可能なtoolbarの選択肢を返す
- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:
		kTagUserInfo,
		kTagFontAndColor,
		kTagView, kTagNotification, kTagFriend, kTagLog, kTagEtc,
		NSToolbarSeparatorItemIdentifier,
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
    NSToolbarItem *newItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    NSToolbarItem *item=[_toolbarItems objectForKey:itemIdentifier];
    
    [newItem setLabel:[item label]];
    [newItem setPaletteLabel:[item paletteLabel]];
    if ([item view] != NULL){
		[newItem setView:[item view]];
    } else {
		[newItem setImage:[item image]];
    }
    [newItem setToolTip:[item toolTip]];
    [newItem setTarget:[item target]];
    [newItem setAction:[item action]];
    [newItem setMenuFormRepresentation:[item menuFormRepresentation]];
    
    if ([newItem view]!=NULL) {
		[newItem setMinSize:[[item view] bounds].size];
		[newItem setMaxSize:[[item view] bounds].size];
    }
    return newItem;
}

#pragma mark deletage : NSWindow

//-- windowShouldClose
// ウィンドウが閉じた時の処理
- (BOOL) windowShouldClose : (id) sender
{
	[self saveDefaults];
	return YES;
}


@end
