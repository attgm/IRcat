//
//  $RCSfile: IRcatInterface.m,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "IRcatInterface.h"
#import "ChannelModal.h"
#import "MainWindowController.h"
#import "IRcatConstants.h"
#import "FormatTable.h"
#import "PreferenceWindowController.h"
#import "ServersWindowController.h"
#import "IRCSession.h"
#import "IRcatUtilities.h"
#import "ContextMenuManager.h"
#import "InputSheet.h"
#import "ConsoleModal.h"
#import "ChannelViewController.h"
#import "ChannelWindowController.h"
#import "PreferenceModal.h"
#import "ServerModal.h"
#import "BindingItem.h"

#define kConsoleIndex 0
#define kCommandPrefix @"/"

const int kChannelMenuTag = 1005;
#define kPlainColorBindingIdentifier    @"plainColor"
#define kTimeColorBindingIdentifier     @"timeColor"
#define kErrorColorBindingIdentifier    @"errorColor"
#define kMessageColorBindingIdentifier  @"messageColor"
#define kFontBindingIdentifier          @"font"

static NSDictionary *ircatInterfaceBindings()
{
    static NSDictionary *bindings = nil;
    
    if(!bindings){
        bindings = [[NSDictionary alloc] initWithObjectsAndKeys:
			[BindingItem bindingItemFromSelector:@selector(syncTextColor:)
									  valueClass:[NSColor class]
									  identifier:kPlainColorBindingIdentifier]
			, kPlainColorBindingIdentifier,
			[BindingItem bindingItemFromSelector:@selector(syncTextColor:)
									  valueClass:[NSColor class]
									  identifier:kTimeColorBindingIdentifier]
			, kTimeColorBindingIdentifier,
			[BindingItem bindingItemFromSelector:@selector(syncTextColor:)
									  valueClass:[NSColor class]
									  identifier:kErrorColorBindingIdentifier]
			, kErrorColorBindingIdentifier,
			[BindingItem bindingItemFromSelector:@selector(syncTextColor:)
									  valueClass:[NSColor class]
									  identifier:kMessageColorBindingIdentifier]
			, kMessageColorBindingIdentifier,
			[BindingItem bindingItemFromSelector:@selector(syncTextFont:)
									  valueClass:[NSFont class]
									  identifier:kFontBindingIdentifier]
			, kFontBindingIdentifier,
			nil ];
	}
    return bindings;
};

MessageAttribute bindingIdentifier2MessageAttribute(void* identifier)
{
	if(identifier == kPlainColorBindingIdentifier){
		return kPlainAttribute;
	}else if(identifier == kTimeColorBindingIdentifier){
		return kTimeAttribute;
	}else if(identifier == kErrorColorBindingIdentifier){
		return kErrorMessageAttribute;
	}else if(identifier == kMessageColorBindingIdentifier){
		return kServerMessageAttribute;
	}
    NSLog(@"unknown identifier %@",(NSString*)identifier);
	return kPlainAttribute;
}


@implementation IRcatInterface

//-- init
- (id) init
{
    self = [super init];
    if (self == nil) return nil;
    
	PreferenceModal* preference = [PreferenceModal sharedPreference];
	_preferenceController = [[NSObjectController alloc] initWithContent:preference];

	
	
    _channelList = [[NSMutableArray alloc] init];
    _mainWindowController = [[MainWindowController alloc] initWithInterface:self];
    _keyWindowController = _mainWindowController;
	// session listの生成
    _sessionList = [[NSMutableArray alloc] init];
    // チャンネルメニューの初期化
    [self initChannelMenu];
    
    [self createNewChannel:NSLocalizedString(@"MTConsole", @"* console *") server:-1];
    [(ConsoleModal*)([self consoleChannelModal]) setSessionList:_sessionList];
	
	// format tableの初期化
    _formatTable = [[FormatTable alloc] init];
	_candidateChannel = [[NSMutableArray alloc] init];
	[_candidateChannel addObject:@"#"];
	
	
	// bindings
	_bindingItems = [[NSDictionary dictionaryWithDictionary:ircatInterfaceBindings()] retain];
	_attributeList = [[NSMutableArray alloc] initWithCapacity:kMessageAttributeNum];
	int i;
	for(i=0; i<kMessageAttributeNum; i++){
		[_attributeList addObject:[[NSMutableDictionary alloc] initWithCapacity:2]];
	}
	NSDictionary* transformer = [NSDictionary dictionaryWithObject:@"ColorNameToColorTransformer"
															forKey:@"NSValueTransformerName"];
	[self        bind : @"plainColor"
			 toObject : _preferenceController
		  withKeyPath : @"selection.textColor"
			  options : transformer];
	[self        bind : @"timeColor"
			 toObject : _preferenceController
	      withKeyPath : @"selection.timeColor"
			  options : transformer];
	[self		 bind : @"errorColor"
			 toObject : _preferenceController
		  withKeyPath : @"selection.errorColor"
			  options : transformer];
	[self		 bind : @"messageColor"
			 toObject : _preferenceController
		  withKeyPath : @"selection.commandColor"
			  options : transformer];
	[self		 bind : @"font"
			 toObject : _preferenceController
		  withKeyPath : @"selection.textFont"
			  options : [NSDictionary dictionaryWithObject:@"FontNameToFontTransformer"
													forKey:@"NSValueTransformerName"]];
    
    
    //[self showNotification:self];
    return self;
}


//-- showNotification
// 
-(void) showNotification:(NSString*)title message:(NSString*)message
{
    if([NSUserNotification class]){
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = title;
        notification.informativeText = message;
        notification.soundName = NSUserNotificationDefaultSoundName;
    
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}

//-- dealloc
- (void) dealloc
{
    [_mainWindowController release];
    [_channelList release];
    [_formatTable release];
    [_sessionList release];
	[_candidateChannel release];
	[_bindingItems release];
	[super dealloc];
}

#pragma mark Preference Controller
//-- sharedPreferenceController
//
-(NSObjectController*) sharedPreferenceController
{
	return _preferenceController;
}


#pragma mark -
#pragma mark Session Management
//-- createNewSession
// セッションの追加
- (void) createNewSession
{
	ServersModal* servers = [ServersModal sharedServersModal];
	[self createSession:[servers selectedServerModal]];
}


//-- createSessionByID
// server idを指定してsessionを開始する
- (void) createSessionByID:(NSInteger) inServerID
{
	if(inServerID > 0){
		[self createSession:[[ServersModal sharedServersModal] serverForID:inServerID]];
	}else{
		[self createNewSession];
	}
}


//-- selectAndCreateNewSession
// サーバを選択して新規チャンネルの生成
- (void) selectAndCreateNewSession
{
	ServersModal* servers = [ServersModal sharedServersModal];
	NSEnumerator* e = [[servers serverList] objectEnumerator];
	NSMenu* menu = [[NSMenu alloc] initWithTitle:@"servers"];
	
	id obj;
	NSMenuItem* item;
	while(obj = [e nextObject]){
		if([self findSessionWithID:[[obj valueForKey:kIdentifier] intValue]] == nil){
			item = [menu addItemWithTitle:[obj valueForKey:kServerName] action:nil keyEquivalent:@""];
			[item setImage:[NSImage imageNamed:[obj valueForKey:@"serverIconLabel"]]];
			[item setTag:[[obj valueForKey:kIdentifier] intValue]];
		}
	}
	// 接続可能なサーバがあった場合ダイアログを表示する
	if([menu numberOfItems] > 0){
		[_mainWindowController askFromMenu:menu
								   withTag:[[[servers selectedServerModal] valueForKey:kIdentifier] intValue]
								   caption:NSLocalizedString(@"MGSelectConnectServer", @"Select server")
									format:@"connect %d"];
	}
    [menu release];
}


//-- createSession
// sessionの開始
- (void) createSession:(ServerModal*) inServer
{
	if (!inServer) return;
	IRCSession* newSession = 
		[[[IRCSession alloc] initWithConfig:[inServer parameters]
								  interface:self
								   identify:[[inServer valueForKey:kIdentifier] intValue]] autorelease];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionConditionChanged:)
												 name:@"IRcatSessionConditionChangedNotification" object:newSession];
	[newSession connect];
    [_sessionList addObject:newSession];
	
	// console menuに追加
	ChannelModal* console = [self consoleChannelModal];
	if([self isActiveChannel:console]){
        [[console channelWindowController] refleshNickList];
    }
	// 接続アリにする
	[_mainWindowController setHasSession:YES];
}


//-- findSessionWithID
// sessionIDからセッションを検索する
- (IRCSession*) findSessionWithID:(NSInteger) inSessionID
{
    NSEnumerator* e = [_sessionList objectEnumerator];
    id it;
    
    while(it = [e nextObject]){
        if([it serverid] == inSessionID){
            return it;
        }
    }
    return nil;
}


//-- connectedServerMenu
// 接続完了したセッションのメニューを返す
- (NSMenu*) connectedServerMenu
{
	NSEnumerator* e = [_sessionList objectEnumerator];
	NSMenu* menu = [[NSMenu alloc] initWithTitle:@"servers"];
	
	id session;
	NSMenuItem* item;
	while(session = [e nextObject]){
		if([session sessionCondition] == IRSessionConditionEstablished){
			item = [menu addItemWithTitle:[session name] action:nil keyEquivalent:@""];
			[item setImage:[NSImage imageNamed:[NSString stringWithFormat:@"server_%@", [session label]]]];
			[item setTag:[session serverid]];
		}
	}
	return [menu autorelease];
}


//-- removeSessionByID
// サーバの削除
- (void) removeSessionByID : (NSInteger) inServerID
{
	IRCSession* session = [self findSessionWithID:inServerID];
	if(session){
		[_sessionList removeObject:session];
		if([self isActiveChannel:[self consoleChannelModal]]){
			[[[self consoleChannelModal] channelWindowController] refleshNickList];
		}
		if([_sessionList count] == 0){
			[_mainWindowController setHasSession:NO];
		}
	}
}


//-- disconnectSessionByID
// サーバの切断
- (void) disconnectSessionByID : (NSInteger) inServerID
{
	//IRCSession* session = [self findSessionWithID:inServerID];
	[self obeyQuit:nil server:inServerID channel:nil];
}


//-- selectAndDisconnectSession
// サーバの削除
- (void) selectAndDisconnectSession
{
	// 接続しているサーバがあった場合ダイアログを表示する
	if([_sessionList count] > 0){
		[_mainWindowController askFromMenu:[self connectedServerMenu]
								   withTag:[self activeServer]
								   caption:NSLocalizedString(@"MGSelectDisconnectServer", @"Select server")
									format:@"disconnect %d"];
	}
}


//-- sessionConditionChanged
// セッション状態の変化
-(void) sessionConditionChanged:(NSNotification*) sender
{
	if([self isActiveChannel:[self consoleChannelModal]]){
        [[[self consoleChannelModal] channelWindowController] refleshNickList];
    }	
}


#pragma mark -
#pragma mark Channel
//-- createNewChannel:server:
// 新規チャンネルの生成
- (void) createNewChannel : (NSString*) inChannelName
                   server : (NSInteger) inServerID
{
    [self createNewChannel:inChannelName server:inServerID isActive:YES];
}


//-- createNewChannel:server:isActive
// 新規チャンネルの生成
- (void) createNewChannel : (NSString*) inChannelName
                   server : (NSInteger) inServerID
                 isActive : (BOOL) inActive
{
	if([_channelList count] == 1){ // consoleとチャンネルの間にセパレタを入れる
        [_channelList addObject:[[[ChannelModal alloc] init] autorelease]];
		[_mainWindowController addMenuItem:nil];
        [self addChannelMenuItem:nil];
    }
    
	ChannelModal *cv = [self reserveChannelModal:inChannelName server:inServerID];
	
	// popup menuに追加する
	NSString* iconName = nil;
	if(inServerID < 0){
		iconName = @"channel_console";
	}else{
		IRCSession* session = [self findSessionWithID:inServerID];
		if(session){
			if(IsChannel(inChannelName)){
				iconName = [NSString stringWithFormat:@"channel_%@", [session label]];
			}else{
				iconName = [NSString stringWithFormat:@"priv_%@", [session label]];
				[cv appendNick:inChannelName flag:IRFlagNoting];
				[cv appendNick:[session nickname] flag:IRFlagNoting];
			}
		}
	}
	[cv setIconName:iconName];
    
	// Menu Itemの構築
	//[_mainWindowController renameMenuItem:[cv aliasName] atIndex:[cv channelid]];
	//[_mainWindowController setMenuImage:[NSImage imageNamed:iconName] atIndex:[cv channelid]];
	[self renameMenuItem:[cv aliasName] atIndex:[cv channelid] withID:[cv channelid]];
    
	// logを記録するチャンネルかどうか
	if([[PreferenceWindowController sharedPreference] isLoggingChannel:inChannelName] ||
	   (!IsChannel(inChannelName) && inServerID >= 0
		&& [[PreferenceModal prefForKey:kLogPrivChannel] boolValue])){
		[cv setLoggingChannel:YES];
	}else{
		[cv setLoggingChannel:NO];
	}
	
	// active channelにする
    if(inActive == YES){
        [self switchChannelAtIndex:[cv channelid]];
    }
}


//-- reserveChannelModal
// 空いているチャンネルを検索する
- (ChannelModal*) reserveChannelModal:(NSString*) inChannelName
							   server:(NSInteger) inServerID;
{
	// 空きチャンネルを探す
    NSEnumerator* e = [_channelList objectEnumerator];
    id it;
    while(it = [e nextObject]){
        if([it isEmptyChannel]){
			// 同じチャンネルでなかった場合はクリアする
			if(![it compareForName:inChannelName server:inServerID]){
				[it clearChannel:inChannelName server:inServerID];
			}
			[it setEmptyChannel:NO];
			[it setChannelWindowController:_mainWindowController];
			return it;
        }
    }
	// なかった場合新規チャンネルの作成
	NSUInteger channelid = [_channelList count];
	// 表示viewの作成
	ChannelViewController* channelView = [[ChannelViewController alloc] initWithInterface:self];
	[channelView createChannelView];
	
	ChannelModal* channel;
	if(inServerID < 0){
		channel = [[[ConsoleModal alloc] initWithName:inChannelName
											 identify:channelid
											   server:inServerID] autorelease];
	}else{
		channel = [[[ChannelModal alloc] initWithName:inChannelName
											 identify:channelid
											   server:inServerID] autorelease];
	}
	[channelView setChannelModal:channel];
	[channel setChannelViewController:channelView];
	[channel setChannelWindowController:_mainWindowController];
	[channelView release];
	
	// menu にも追加する
	[self addChannelMenuItem:@""];
	//[_mainWindowController addMenuItem:@""];
	[_mainWindowController addMenuItemByChannelModal:channel];
	[_channelList addObject:channel];
	return channel;
}

//-- removeAllChannelAt:
// サーバ上のすべてのチャンネルをpartする
- (void) removeAllChannelAt:(NSInteger) inServerID
{
	for(id it in _channelList){
	    if([it serverid] == inServerID){
            [self removeChannel:it];
        }
    }
}


//-- removeChannel:server:
// チャンネルの削除
- (void) removeChannel : (NSString*) inChannelName
                server : (NSInteger) inServerID
{
    ChannelModal* channel = [self findChannelWithName:inChannelName server:inServerID];
    if(channel != nil){
		[self removeChannel:channel];
	}
}


//-- removeChannel
// チャンネルの削除
- (void) removeChannel:(ChannelModal*) inChannel
{
	NSUInteger index = [_channelList indexOfObject:inChannel];
	// tear off したwindowなら元にもどす
	[inChannel setChannelWindowController:nil];
	// ActiveChannelを削除する場合は consoleをactiveにする
	if([_mainWindowController activeChannel] == inChannel){
		[self switchChannelAtIndex:kConsoleIndex];
	}
	// チャンネルの開放
	[inChannel setEmptyChannel:YES];
	// どこのチャンネルを削除したかどうか
	if(index == ([_channelList count] - 1)){
		//最後のチャンネルだった場合
		ChannelModal* channel;
		do {
			[_channelList removeLastObject];
			// メニューからの削除
			[_mainWindowController removeLastMenuItem];
			[self removeLastChannelMenuItem];
			index--;
			channel = [_channelList objectAtIndex:index];
		} while(index > 0 && ([channel isEmptyChannel] || [channel channelid] < 0));
	}else{
		// 最後でない場合, メニューをセパレタにする.
		[_mainWindowController menuItemToSeparator:index];
		[self channelMenuItemToSeparator:index];
	}
}


//-- findChannelWithName:server:
// チャンネル構造体を検索する. 見つからなかったらnil
- (ChannelModal*) findChannelWithName:(NSString*) inChannel
							   server:(NSInteger) inServerID
{
    NSEnumerator* e = [_channelList objectEnumerator];	
    id it;
	while(it = [e nextObject]){
        if([it compareForName:inChannel server:inServerID] == YES){
            return it;
        }
    }
    return nil;
}


//-- consoleChannelModal
// console向けのchannelmodalを返す
- (ChannelModal*) consoleChannelModal
{
	return [self channelAtIndex:kConsoleIndex];
}


//-- channelAtIndex
// チャンネル構造体を返す
- (ChannelModal*) channelAtIndex:(NSInteger)inIndex
{
    return [_channelList objectAtIndex:inIndex];
}


//-- switchChannelAtIndex
// 表示チャンネルの切り替え
- (BOOL) switchChannelAtIndex:(NSInteger) inIndex
{
	ChannelModal* channel = [self channelAtIndex:inIndex];
	if([channel isEmptyChannel] == YES || [channel channelid] < 0){
		return NO;
	}
    [[channel channelWindowController] switchChannel:channel];
	
	return YES;
}


//-- switchNextChannel
// 表示チャンネルを1つ後のチャンネルにする
- (void) switchNextChannel
{
	NSUInteger index = [_channelList indexOfObject:[self activeChannel]];
	do {
		index = (index < [_channelList count] - 1) ? (index + 1) : 0;
	} while(![self switchChannelAtIndex:index]);
}


//-- switchPreviousChannel
// 表示チャンネルを1つ前のチャンネルにする
- (void) switchPreviousChannel
{
	NSUInteger index = [_channelList indexOfObject:[self activeChannel]];
	do {
		index = (index > 0) ? (index - 1) : ([_channelList count] - 1);
	} while (![self switchChannelAtIndex:index]);
}


//-- setTopic:channel:server:
// topicの変更を行う
- (void) setTopic:(NSString*)inTopic
		  channel:(NSString*)inChannelName
		   server:(NSInteger)inServerID
{
    ChannelModal* channel = [self findChannelWithName:inChannelName server:inServerID];
    if(channel){
        [channel setTopic:inTopic];
    }
	
	if([self isActiveChannel:channel]) {
		[[channel channelWindowController] setTopic:[channel topic]];
	}	
}



//-- setFlag:channel:server:nick:ison:
// flagの変更を行う
- (void) setFlag:(int)inFlag
		 channel:(NSString*)inChannelName
		  server:(NSInteger)inServerID
			nick:(NSString*)inNickname
			ison:(BOOL)inIsOn
{
    ChannelModal* channel = [self findChannelWithName:inChannelName server:inServerID];	
	NSString* label = inChannelName ? inNickname : nil;
	if(channel){
		[channel setFlag:inFlag nick:label ison:inIsOn];
		// もしアクティブなチャンネルならNickListも変更する
		[self refleshNickList:inChannelName server:inServerID];
	}
}


//-- setChannelFlag:channel:server:nick:ison:
// flagの変更を行う
- (void) setChannelFlag:(unichar)inFlag
				channel:(NSString*)inChannelName
				 server:(NSInteger)inServerID
				   ison:(BOOL)inIsOn
{
    ChannelModal* channel = [self findChannelWithName:inChannelName server:inServerID];	
	if(channel){
		[channel setChannelFlag:inFlag ison:inIsOn];
		// もしアクティブなチャンネルならNickListも変更する
		if([self isActiveChannel:channel]){
			[[channel channelWindowController] setModeString:[channel channelFlagString]];
		}
	}
}


//-- appendCandidateChannel
// 候補チャンネルを挿入する
- (void) appendCandidateChannel:(NSString*) inChannelName
{
	[_candidateChannel addObject:inChannelName];
	if([_candidateChannel count] > 5){
		[_candidateChannel removeObjectAtIndex:0];
	}
}

#pragma mark -
#pragma mark Window
//-- tearChannel
// チャンネルの切り離し
-(void) tearChannel:(ChannelModal*) inChannelModal
{
	if([inChannelModal channelWindowController] == _mainWindowController){
		ChannelWindowController* windowController = 
			[[[ChannelWindowController alloc] initWithInterface:self] autorelease];
		[_mainWindowController setEnableMenuItem:NO atIndex:[inChannelModal channelid]];
		[_mainWindowController setDocumentView:nil];
		[windowController switchChannel:inChannelModal];
		//[windowController setDocumentView:[inChannelModal channelView]];
		[inChannelModal setChannelWindowController:windowController];
	}else{
		[_mainWindowController setEnableMenuItem:YES atIndex:[inChannelModal channelid]];
		[_mainWindowController switchChannel:inChannelModal];
		[inChannelModal setChannelWindowController:_mainWindowController];
	}
}


#pragma mark -
//-- changeFont
// FONTをreloadする
/*- (void) changeFont:(NSNotification*)notification
{
	NSFont* font;
	if(notification){
		font = [[notification userInfo] objectForKey:@"Font"];
	}else{
		font = [PreferenceWindowController preferenceForKey:kTextFont];
	}
	[[[mActiveChannel channelView] documentView] setFont:font];
}*/



//-- refleshLogIcon
// ログアイコンのリフレッシュ
- (void) refleshLogIcon
{
	[_keyWindowController refleshLogIcon];
}


#pragma mark -

//-- activeServer
// 現在アクティブなサーバを返す
- (NSInteger) activeServer
{
	if([[self activeChannel] serverid] < 0){ // consoleの場合
		NSInteger index = [[[self activeChannel] channelWindowController] selectedIndexOnNickList];
		if(index >= 0){
			NSString* channel = [[self consoleChannelModal] stringSelected:index];
			NSRange range = NSMakeRange(0, [channel length]);
			NSString* number = PrefixString(channel, @":", &range);
			if(range.length > 0){
				return [number intValue];
			}
		}
		if([_sessionList count] > 0){
			return [[_sessionList objectAtIndex:0] serverid];
		}else{
			return 0;
		}
	}else{ // それ以外の場合
		return [[self activeChannel] serverid];
	}
}


//-- activeChannel
// 現在アクティブなチャンネルを返す
- (ChannelModal*) activeChannel
{
    return [_keyWindowController activeChannel];
}


#pragma mark -
#pragma mark Channel Menu

//-- initChannelMenu
// チャンネルメニューの初期化
- (void) initChannelMenu
{
    NSMenu* menu = [[[NSApp mainMenu] itemWithTag:kChannelMenuTag] submenu];
    _channelMenuOffset = [menu numberOfItems];
}


//-- addChannelMenuItem
// menu itemの追加
- (void) addChannelMenuItem:(NSString*) inChannelName
{
    NSMenuItem *newItem;
    NSMenu* menu = [[[NSApp mainMenu] itemWithTag:kChannelMenuTag] submenu];
    NSInteger tag = [menu numberOfItems] - _channelMenuOffset;
    NSInteger equivalent = (tag > 0) ? (tag - 1) : 0; // consoleとチャンネルの間にセパレタが入る
    
	// nilの場合はセパレタを追加する
    if(inChannelName == nil){
        [menu addItem:[NSMenuItem separatorItem]];
    }else{
        newItem = [menu addItemWithTitle:inChannelName
                                  action:@selector(switchChannelbyChannelMenu:)
                           keyEquivalent:[[NSNumber numberWithInteger:equivalent] stringValue]];
        [newItem setTarget:self];
        [newItem setTag:tag];
    }
}



//-- channelMenuItemToSeparator
// menu itemをセパレタに変更する
- (void) channelMenuItemToSeparator : (NSInteger) inIndex
{
	NSInteger index = inIndex + _channelMenuOffset;
    NSMenu* menu = [[[NSApp mainMenu] itemWithTag:kChannelMenuTag] submenu];
    
    NSMenuItem* item = [menu itemAtIndex:index];
	[item setTarget:nil];
}


//-- renameChannelMenuItem:atIndex
// menuitemをrenameする
- (void) renameMenuItem:(NSString*)inString
                atIndex:(NSInteger) inIndex
				 withID:(NSInteger) inChannelID
{
    NSMenuItem *item;
    NSInteger index = inIndex + _channelMenuOffset;
    NSMenu* menu = [[[NSApp mainMenu] itemWithTag:kChannelMenuTag] submenu];
    
    item = [menu itemAtIndex:index];
    // セパレタだった場合削除して新しいitemを挿入する
    if([item isSeparatorItem] == YES){
        [menu removeItemAtIndex:index];
        item = [menu insertItemWithTitle:inString
                                  action:@selector(switchChannelbyChannelMenu:)
                           keyEquivalent:[[NSNumber numberWithInteger:inChannelID] stringValue]
                                 atIndex:(index - 1)];
        [item setTag:([menu numberOfItems] - _channelMenuOffset - 1)];
        [item setTarget:self];
    }else{
        [item setTitle:inString];
		[item setTarget:self];
	}
}


//-- setChannelMenuName:atIndex
// channel名を設定する
- (void) setChannelMenuName:(NSString*)inString
					atIndex:(NSInteger) inIndex
{
    NSMenu* menu = [[[NSApp mainMenu] itemWithTag:kChannelMenuTag] submenu];
    NSMenuItem *item;
    NSInteger index = inIndex + _channelMenuOffset;
    
    if(index < [menu numberOfItems]){
		item = [menu itemAtIndex:index];
	    [item setTitle:inString];
		[item setTarget:self];
	}else{
		// menuが足りない場合追加する
		[self addChannelMenuItem:inString];
	}
}


//-- removeLastMenuItem
// 最後のitemを削除する
- (void) removeLastChannelMenuItem
{
    NSMenu* menu = [[[NSApp mainMenu] itemWithTag:kChannelMenuTag] submenu];
	
    [menu removeItemAtIndex:([menu numberOfItems] - 1)];
}


//-- switchChannelbyChannelMenu
// チャンネルMenuが選択された時の処理
- (IBAction) switchChannelbyChannelMenu:(id) inSender
{
    [self switchChannelAtIndex:[inSender tag]];
}


//-- isActiveChannel
// activeなチャンネルかどうかの判断
-(BOOL) isActiveChannel:(ChannelModal*) inChannelModal
{
	return ([[inChannelModal channelWindowController] activeChannel] == inChannelModal);
}

#pragma mark -
#pragma mark ･･･  Send Message ･･･
- (void) enterMessageByString:(NSString*) inMessage
						   to:(ChannelModal*) inChannelModal
{
	const unichar linkSeparator[] = {0x000d, 0x000A, 0x2028, 0x2029};
	static NSCharacterSet* lineCharaters = nil;
	if(!lineCharaters){
		lineCharaters =  [[NSCharacterSet characterSetWithCharactersInString:
			[NSString stringWithCharacters:linkSeparator length:4]] retain];
	}
	NSScanner* scanner = [NSScanner scannerWithString:inMessage];
	[scanner setCharactersToBeSkipped:nil]; // スペースを飛ばさないよ
	NSString* message;
	while(![scanner isAtEnd]){
		if([scanner scanUpToCharactersFromSet:lineCharaters intoString:&message]){
			if([message hasPrefix:kCommandPrefix] &&
			   [[PreferenceModal prefForKey:kUseCommand] boolValue]){
				[self obeyIRCCommand:[message substringWithRange:NSMakeRange(1, [message length] - 1)]
								  to:inChannelModal];
			}else{
				[self sendMessage:message to:inChannelModal];
			}
			if([[PreferenceModal prefForKey:kAllowMultiLineMessage] boolValue] == NO){
				break;
			}
		}
		[scanner scanCharactersFromSet:lineCharaters intoString:nil];
	}
}

//-- sendMessage
// メッセージの送信を行う
- (void) sendMessage:(NSString*) inMessage
				  to:(ChannelModal*) inChannelModal
{
    IRCSession* session = [self findSessionWithID:[inChannelModal serverid]];
    
    if(session != nil){
        [session sendPRIVMSG:inMessage to:[inChannelModal name]];
    }
}



#pragma mark -
#pragma mark Append/Remove Nick
//-- appendNick:toChannelModal
// channel に nicknameを追加する
- (void) appendNick:(NSString*) inNick
	 toChannelModal:(ChannelModal*) inChannelModal
{
	if (!inChannelModal) return;
	
    UserModeFlag flag = [inNick hasPrefix:@"@"] ? IRFlagOperator : 
		([inNick hasPrefix:@"+"] ? IRFlagSpeakAbility : IRFlagNoting);
    // flagがある場合は先頭の1文字をskipする
    if(flag != IRFlagNoting){
        [inChannelModal appendNick:[inNick substringWithRange:NSMakeRange(1, [inNick length] - 1)] flag:flag];
    }else{
        [inChannelModal appendNick:inNick flag:flag];
    }
}


//-- appendNick:toChannel:server
// nickを追加する
- (void) appendNick:(NSString*) inNick
          toChannel:(NSString*) inChannel
             server:(NSInteger)  inServerID
{
    ChannelModal* channel;
	
    channel = [self findChannelWithName:inChannel server:inServerID];
	[self appendNick:inNick toChannelModal:channel];
    [self refleshNickList:inChannel server:inServerID];
}


// -- appendNicks:toChannel:server
// nickを複数同時に挿入する
- (void) appendNicks:(NSArray*) inNicks
           toChannel:(NSString*) inChannel
              server:(NSInteger)  inServerID
{
    NSEnumerator* e;
    NSString* nick;
    ChannelModal* channel;
    
    channel = [self findChannelWithName:inChannel server:inServerID];
    e = [inNicks objectEnumerator];
    while(nick = [e nextObject]){
		[self appendNick:nick toChannelModal:channel];
	}
	[self refleshNickList:inChannel server:inServerID];
}


//-- removeNick
// nicknameを削除する
- (void) removeNick:(NSString*) inNick
        fromChannel:(NSString*) inChannel
             server:(NSInteger)  inServerID
{
    ChannelModal* channel;
	
    channel = [self findChannelWithName:inChannel server:inServerID];
    if(channel){
        [channel removeNick:inNick];
    }
    
    if([channel isActiveChannel] == YES){
        [[channel channelWindowController] refleshNickList];
    }
}


//-- removeNick:server
// server上のnicknameをすべて削除する
- (void) removeNick:(NSString*) inNick
             server:(NSInteger)  inServerID
{
    NSEnumerator* e;
    ChannelModal* channel;
	
    e = [_channelList objectEnumerator];
    while(channel = [e nextObject]){
        // inNickが参加しているchannelであった場合削除する
        if ([channel serverid] == inServerID){
            if([channel removeNick:inNick] == YES){ // 削除された場合
                if([channel isActiveChannel] == YES){
                    [[channel channelWindowController] refleshNickList];
                }
            }
        }
    }
}


//-- renameNick:to:server
// server上のnicknameをrenameする
- (void) renameNick:(NSString*) inNick
                 to:(NSString*) inNewNick
             server:(NSInteger)  inServerID
{
    NSEnumerator* e;
    ChannelModal* channel;
	
    e = [_channelList objectEnumerator];
    while(channel = [e nextObject]){
        // inNickが参加しているserverであった場合変更する
        if ([channel serverid] == inServerID){
            if([channel renameNick:inNick to:inNewNick] == YES){ // 参加していた場合
																 // nicklistの更新
                if([channel isActiveChannel] == YES){
                    [[channel channelWindowController] refleshNickList];
                }
			}
			// PRIVCHANNELであった場合, channel名の変更
			if([[channel name] isEqualToString:inNick]){
				[channel setChannelName:inNewNick];
				// menuの更新
				[_mainWindowController renameMenuItem:inNewNick atIndex:[channel channelid]];
				[self renameMenuItem:inNewNick atIndex:[channel channelid] withID:[channel channelid]];
			}
        }
    }
}


//-- refleshNickList:server:
// NickListを更新する
- (void) refleshNickList:(NSString*)inChannel
                  server:(NSInteger) inServerID
{
    ChannelModal* channel;
	
    channel = [self findChannelWithName:inChannel server:inServerID];
    if([channel isActiveChannel]){
        [[channel channelWindowController] refleshNickList];
    }
}

#pragma mark Append Message

//-- appendMessage:format
// formatに従ってmessageを表示させる
- (void) appendMessage:(IRCMessage*) inMessage
                format:(NSString*) inFormatNumber
{
    FormatItem* format;
    // messageに応じたformatの検索
    format = [_formatTable dataForKey:inFormatNumber];
    // formatがない場合はデフォルトのフォーマットを使用する
    if(!format){
        switch([inMessage messageType]){
            case IRC_CommandMessage:
                format = [_formatTable dataForKey:kDefaultCommandFormat];
                break;
            case IRC_ReplyMessage:
                format = [_formatTable dataForKey:kDefaultReplyFormat];
                break;
            case IRC_ErrorMessage:
            default:
                format = [_formatTable dataForKey:kDefaultErrorFormat];
                break;
        }
    }
    // フォーマットの展開
    [inMessage applyFormat:format attributes:_attributeList];
    // 出力先に応じて表示する
    switch([format displayPlace]){
        case IRInsertConsole:
            [self appendMessageToConsole:inMessage];
            break;
        case IRInsertJoinedChannel:
            [self appendMessageToJoinedChannel:inMessage];
            break;
        case IRInsertChannel:
            [self appendMessageToChannel:inMessage];
            break;
        case IRInsertNothing:
            break;
    }
	// キーワードの処理
    
	if([inMessage useNotification] == YES){
        [self showNotification:[inMessage nickname] message:[[inMessage commonMessage] string]];
		/*if([[PreferenceModal prefForKey:kBeepKeyword] boolValue]){
			[[NSSound soundNamed:[PreferenceModal prefForKey:kBeepFile]] play];
		}
		[NSApp requestUserAttention:NSCriticalRequest];*/
        
	}
}



//-- appendMessageToConsole:append:
// consoleにメッセージを追加する
- (void) appendMessageToConsole:(IRCMessage*) inMessage
{
    ChannelModal* console = [self channelAtIndex:kConsoleIndex]; // 0 always console
    [console appendString:[inMessage expandedMessage]
                   append:[inMessage additionalMessage]
                       at:[inMessage additionalPosition]];
    
    if([console isActiveChannel] == NO){
        [_mainWindowController appendStringToCommon:[inMessage commonMessage]
                                             append:[inMessage additionalMessage]
                                                 at:[inMessage commonAdditionalPosition]];
    }
}


//-- appendMessageToChannel
//	チャンネルにTextを表示させる
- (void) appendMessageToChannel:(IRCMessage*) inMessage
{
    ChannelModal* channel;
    
    if((channel = [self findChannelWithName:[inMessage channel]
                                     server:[inMessage serverid]]) != nil) {
        [channel appendString:[inMessage expandedMessage]
                       append:[inMessage additionalMessage]
                           at:[inMessage additionalPosition]];
    }else{
        [[self channelAtIndex:kConsoleIndex] appendString:[inMessage expandedMessage]
                                                   append:[inMessage additionalMessage]
                                                       at:[inMessage additionalPosition]];
    }
    
	if([channel isActiveChannel] == NO){
        [_mainWindowController appendStringToCommon:[inMessage commonMessage]
                                             append:[inMessage additionalMessage]
                                                 at:[inMessage commonAdditionalPosition]];
    }
}


//-- AppendMessageToJoinedChannel
//	Nickの人がいるチャンネルとConsoleに表示する
- (void) appendMessageToJoinedChannel:(IRCMessage*) inMessage
{
    NSString* nick;
    BOOL isAppend = NO;
    
    nick = [inMessage nickname];
	
    if(nick == nil || [nick length] == 0){
        [self appendMessageToConsole:inMessage];
    }
    
	BOOL isHidden = NO;
    for(id it in _channelList){
		// 異なるサーバである場合はskipする
        if ([it serverid] != [inMessage serverid])
            continue;
        // 参加していた場合, メッセージを表示する
        if([it isJoined:nick] == YES){
            isAppend = YES;
			[it appendString:[inMessage expandedMessage]
					  append:[inMessage additionalMessage]
						  at:[inMessage additionalPosition]];
			isHidden = (isHidden || ![it isActiveChannel]);
        }
    }
    // どこにも表示してない場合 consoleに表示する
    if(isAppend == NO){
        [[self channelAtIndex:kConsoleIndex]
				 appendString:[inMessage expandedMessage]
					   append:[inMessage additionalMessage]
						   at:[inMessage additionalPosition]];
		isHidden = ![[self channelAtIndex:kConsoleIndex] isActiveChannel];
    }
	
	if(isHidden == YES){
        [_mainWindowController appendStringToCommon:[inMessage commonMessage]
                                             append:[inMessage additionalMessage]
                                                 at:[inMessage commonAdditionalPosition]];
    }	
}

#pragma mark Obey Commands
//-- ObeyJoin
// チャンネルに入る
- (void) obeyJoin:(NSString*)inParams
		   server:(NSInteger) inServerID
		  channel:(ChannelModal*)inChannelModal	
{
    NSString *channel, *password;
    NSRange content;
    ChannelModal* channelModal;
    NSString* channelName;
    
    NSInteger server = (inServerID > 0) ? inServerID : [self activeServer];
    if(inParams){
        content = NSMakeRange(0, [inParams length]);
        channel = PrefixString(inParams, @" ", &content);
		if(content.length == 0){ // passwordがない場合
			password =nil;
		}else{
			password = [inParams substringWithRange:content];
		}
		channelName = [[PreferenceWindowController sharedPreference] realChannelName:channel];
		
		channelModal = [self findChannelWithName:channelName server:server];
		if(channelModal){ // すでにチャンネルにJOINしている場合, そのチャンネルをアクティブにする
			[self switchChannelAtIndex:[channelModal channelid]];
		}else{// 新規チャンネルの生成
			if(IsNick(channelName)){
				[self createNewChannel:channelName server:server isActive:YES];
			}else{
				IRCSession* session;
				session = [self findSessionWithID:server];
				[session sendJOIN:channelName password:password];
			}
		}
	}else{
		JoinInputsSheet* sheet = [JoinInputsSheet sharedJoinInputsSheet];
		[sheet setCaption:NSLocalizedString(@"MGJoinDialog", @"JOIN")];
		[sheet setFirstTitle:NSLocalizedString(@"MGInputChannel", @"CHANNEL") value:[_candidateChannel lastObject]];
		[sheet setCandidateChannels:_candidateChannel];
		[sheet setSecondTitle:NSLocalizedString(@"MGInputPassword", @"PASSWORD") value:@""];
		[sheet setServerMenu:[self connectedServerMenu] value:server];
		[sheet setFormat:@"JOIN@%d %@ %@" reverse:NO];
		[sheet setAction:@selector(obeyIRCCommand:) target:self];
		[[inChannelModal channelWindowController] showSheet:sheet];
		[sheet resetFirstResponder];
	}
}



//-- ObeyPart
// チャンネルから抜ける
- (void) obeyPart:(NSString*)inParams
		   server:(NSInteger) inServerID
		  channel:(ChannelModal*)inChannelModal	
{
    ChannelModal* channelModal;
    
    NSInteger server = (inServerID > 0) ? inServerID : [self activeServer];
    
    if(inParams){
        NSRange content = NSMakeRange(0, [inParams length]);
		NSString* channel = PrefixString(inParams, @" ", &content);
        NSString* message = PrefixString(inParams, @" ", &content);
		
		NSString* channelName = [[PreferenceWindowController sharedPreference] realChannelName:channel];    
		channelModal = [self findChannelWithName:channelName server:server];
		
		if(channelModal){
			if(IsNick([channelModal name])){ // ぷりぶの場合チャンネルを削除する
				[self removeChannel:[channelModal name] server:server];
			}else{
				IRCSession* session = [self findSessionWithID:server];
				[session sendPART:[channelModal name] message:message];
			}
		}
	}else{
        channelModal = [self activeChannel];
        
		OneInputSheet* sheet = [OneInputSheet sharedOneInputSheet];
		[sheet setCaption:NSLocalizedString(@"MGPartDialog", @"PART")];
		[sheet setTitle:NSLocalizedString(@"MGInputChannel", @"CHANNEL")
				  value:(([channelModal serverid] > 0) ? [channelModal aliasName] : @"#")];
		[sheet setServerMenu:[self connectedServerMenu] value:server];
		[sheet setFormat:@"PART@%d %@"];
		[sheet setAction:@selector(obeyIRCCommand:) target:self];
		[[inChannelModal channelWindowController] showSheet:sheet];
		[sheet resetFirstResponder];
	}
}


//-- ObeyNick
// nicknameの変更
- (void) obeyNick:(NSString*)inParams
		   server:(NSInteger) inServerID
		  channel:(ChannelModal*)inChannelModal
{
    NSInteger server;
    NSString *nick;
	
    server = (inServerID > 0) ? inServerID : [self activeServer];
    
    if(inParams){
        NSRange content = NSMakeRange(0, [inParams length]);
        nick = PrefixString(inParams, @" ", &content);
		IRCSession* session = [self findSessionWithID:server];
		if(session){
			[session sendNICK:nick];
		}
    }else{
		OneInputSheet* sheet = [OneInputSheet sharedOneInputSheet];
		[sheet setCaption:NSLocalizedString(@"MGNickDialog", @"NICK")];
		[sheet setTitle:NSLocalizedString(@"MGInputNickname", @"NICK")
				  value:@""];
		[sheet setServerMenu:[self connectedServerMenu] value:server];
		[sheet setFormat:@"NICK@%d %@"];
		[sheet setAction:@selector(obeyIRCCommand:) target:self];
		[[inChannelModal channelWindowController] showSheet:sheet];
    	[sheet resetFirstResponder];
	}
}



//-- ObeyQuit
// 終了処理
- (void) obeyQuit:(NSString*)inParams
		   server:(NSInteger) inServerID
		  channel:(ChannelModal*)inChannelModal
{
    NSString* message;
    IRCSession* session;
    
    // 何もparamがない場合は初期設定で設定してあるメッセージを送信
    if(inParams == nil || [inParams isEqualToString:@""]){
        message = [PreferenceModal prefForKey:kQuitMessage];
    }else{ 
        message = inParams;
    }
    
    session = [self findSessionWithID:inServerID];
    if(session){
        if([message isEqualToString:@""]){
            [session sendCommand:kCommandQuit];
        }else{
            [session sendCommand:[NSString stringWithFormat:@"%@ :%@", kCommandQuit, message]];
        }
    }
}


//-- ObeyWhois
// whoisの処理
- (void) obeyWhois:(NSString*)inParams
			server:(NSInteger) inServerID
		   channel:(ChannelModal*)inChannelModal
{
    NSInteger server = (inServerID > 0) ? inServerID : [self activeServer];
    
    if(inParams){
        IRCSession* session = [self findSessionWithID:server];
		if(session){
            [session sendWHOIS:inParams];
		}
	}else{
		OneInputSheet* sheet = [OneInputSheet sharedOneInputSheet];
		[sheet setCaption:NSLocalizedString(@"MGWhoisDialog", @"WHOIS")];
		[sheet setTitle:NSLocalizedString(@"MGInputNickname", @"NICK")
				  value:@""];
		[sheet setServerMenu:[self connectedServerMenu] value:server];
		[sheet setFormat:@"WHOIS@%d %@"];
		[sheet setAction:@selector(obeyIRCCommand:) target:self];
		[[inChannelModal channelWindowController] showSheet:sheet];
    	[sheet resetFirstResponder];
	}
}



//-- ObeyTopic
// topicの処理
- (void) obeyTopic:(NSString*)inParams
			server:(NSInteger) inServerID
		   channel:(ChannelModal*)inChannelModal
{
	ChannelModal* channelModal = inChannelModal ? inChannelModal : [self activeChannel];   
    NSInteger server = (inServerID > 0) ? inServerID : [self activeServer];
    
    if(inParams){
        NSRange content = NSMakeRange(0, [inParams length]);
        NSString* channel = [[PreferenceWindowController sharedPreference]
								realChannelName:PrefixString(inParams, @" ", &content)];
		NSString* topic;
		if(IsChannel(channel)){
			topic = [inParams substringWithRange:content];
		}else{
			channel = [channelModal name];
			topic = inParams;
		}
		IRCSession* session = [self findSessionWithID:server];
		if(session){
			[session sendTOPIC:topic to:channel];
		}
    }else{
		TwoInputsSheet* sheet = [TwoInputsSheet sharedTwoInputsSheet];
		[sheet setCaption:NSLocalizedString(@"MGTopicDialog", @"TOPIC")];
		[sheet setFirstTitle:NSLocalizedString(@"MGInputTopic", @"TOPIC")
					   value:(channelModal ? [channelModal topic] : @"")];
		[sheet setSecondTitle:NSLocalizedString(@"MGInputChannel", @"CHANNEL")
						value:(channelModal ? [channelModal aliasName] : @"#")];
		[sheet setServerMenu:[self connectedServerMenu] value:server];
		[sheet setFormat:@"TOPIC@%d %@ %@" reverse:YES];
		[sheet setAction:@selector(obeyIRCCommand:) target:self];
		[[inChannelModal channelWindowController] showSheet:sheet];
		[sheet resetFirstResponder];
	}
}




//-- obeyMode
// modeの処理
- (void) obeyMode:(NSString*)inParams
		   server:(NSInteger) inServerID
		  channel:(ChannelModal*)inChannelModal
{
    ChannelModal* channelModal = inChannelModal ? inChannelModal : [self activeChannel];   
    NSInteger server = (inServerID > 0) ? inServerID : [self activeServer];
    NSString* command;
	
	// mode #channel_name commands
    if(inParams){
		NSRange content = NSMakeRange(0, [inParams length]);
        NSString* channel = [[PreferenceWindowController sharedPreference] 
								realChannelName:PrefixString(inParams, @" ", &content)];
		//パラメタが2つ以上の場合 /mode <channel> <mode>
		if(content.length > 0){
			command = [inParams substringWithRange:content];
			if(!IsMode(command)){ // 後ろがmodeでなかった場合は /mode <mode> <params>
				if(channelModal) {
					channel = [channelModal name];
					command = inParams;
				}else{
					return;
				}
			}
		}else{
			// パラメタが1つの場合…
			if(IsMode(channel)){
				if(channelModal) {
					channel = [channelModal name];
					command = inParams;
				}else{
					return;
				}
			}else{
				command = @"";
			}
		}
		IRCSession* session = [self findSessionWithID:server];
		if(session){
			[session sendMODE:command to:channel];
		}
    }else{
		if(channelModal){
			TwoInputsSheet* sheet = [TwoInputsSheet sharedTwoInputsSheet];
			[sheet setCaption:NSLocalizedString(@"MGModeDialog", @"MODE")];
			[sheet setFirstTitle:NSLocalizedString(@"MGInputMode", @"Mode") value:@""];
			[sheet setSecondTitle:NSLocalizedString(@"MGInputChannel", @"CHANNEL")
							value:(channelModal ? [channelModal aliasName] : @"#")];
			[sheet setServerMenu:[self connectedServerMenu] value:server];
			[sheet setFormat:@"MODE@%d %@ %@" reverse:YES];
			[sheet setAction:@selector(obeyIRCCommand:) target:self];
			[[inChannelModal channelWindowController] showSheet:sheet];
			[sheet resetFirstResponder];
		}
	}
}


//-- obeyCtcp
// ctcpコマンドの処理
- (void) obeyCtcp:(NSString*)inParams
		   server:(NSInteger) inServerID
		  channel:(ChannelModal*)inChannelModal
{
	NSInteger server = (inServerID > 0) ? inServerID : [self activeServer];
    
	// mode #channel_name commands
    if(inParams){
		NSRange content = NSMakeRange(0, [inParams length]);
        NSString* command = PrefixString(inParams, @" ", &content);
		NSString* nick;
		if(content.length > 0){ // パラメタが2つの場合
			nick = [inParams substringWithRange:content];
		}else{
			OneInputSheet* sheet = [OneInputSheet sharedOneInputSheet];
			[sheet setCaption:[NSString stringWithFormat:
				NSLocalizedString(@"Whom do you send CTCP %@ message ?", @"Whom do you send CTCP %@ message ?"), command]];
			[sheet setTitle:NSLocalizedString(@"MGInputNickname", @"NICK")
					  value:@""];
			[sheet setServerMenu:[self connectedServerMenu] value:server];
			[sheet setFormat:[NSString stringWithFormat:@"CTCP@%%d %@ %%@", command]];
			[sheet setAction:@selector(obeyIRCCommand:) target:self];
			[[inChannelModal channelWindowController] showSheet:sheet];
			[sheet resetFirstResponder];
			return;
		}
		
		//-- 各コマンドの処理
		if([command caseInsensitiveCompare:kCommandCtcpPing] == NSOrderedSame){ // pingの時は今のtickを返す	
			long tick =  (long) ([[NSDate date] timeIntervalSince1970]);
			command = [NSString stringWithFormat:@"PING %ld", tick];
		}
		
		//--
		IRCSession* session = [self findSessionWithID:server];
		if(session){
			[session sendCtcpCommand:command to:nick];
		}
    }else{
		OneInputSheet* sheet = [OneInputSheet sharedOneInputSheet];
		[sheet setCaption:NSLocalizedString(@"MGCtcpDialog", @"CTCP")];
		[sheet setTitle:NSLocalizedString(@"MGInputCommand", @"COMMAND")
				  value:@""];
		[sheet setServerMenu:[self connectedServerMenu] value:server];
		[sheet setFormat:@"CTCP@%d %@"];
		[sheet setAction:@selector(obeyIRCCommand:) target:self];
		[[inChannelModal channelWindowController] showSheet:sheet];
		[sheet resetFirstResponder];
	}
}


//-- ObeyAction
// actionの処理
- (void) obeyAction:(NSString*)inParams
			 server:(NSInteger)inServerID
			channel:(ChannelModal*) inChannelModal
{	
	ChannelModal* channelModal = inChannelModal ? inChannelModal : [self activeChannel];   
    NSInteger server = (inServerID > 0) ? inServerID : [self activeServer];
    
    if(inParams){
        NSRange content = NSMakeRange(0, [inParams length]);
        NSString* channel = [[PreferenceWindowController sharedPreference]
							realChannelName:PrefixString(inParams, @" ", &content)];
		NSString* message;
		if(IsChannel(channel)){
			message = [inParams substringWithRange:content];
		}else{
			channel = [channelModal name];
			message = inParams;
		}
		IRCSession* session = [self findSessionWithID:server];
		if(session){
			[session sendAction:message to:channel];
		}	
    }else{
		if(channelModal){
			TwoInputsSheet* sheet = [TwoInputsSheet sharedTwoInputsSheet];
			[sheet setCaption:NSLocalizedString(@"MGActionDialog", @"ACTION")];
			[sheet setFirstTitle:NSLocalizedString(@"MGInputMessage", @"MESSAGE") value:@""];
			[sheet setSecondTitle:NSLocalizedString(@"MGInputChannel", @"CHANNEL")
							value:(channelModal ? [channelModal aliasName] : @"#")];
			[sheet setServerMenu:[self connectedServerMenu] value:server];
			[sheet setFormat:@"ACTION@%d %@ %@" reverse:YES];
			[sheet setAction:@selector(obeyIRCCommand:) target:self];
			[[inChannelModal channelWindowController] showSheet:sheet];
			[sheet resetFirstResponder];
		}
	}	
}


//-- ObeyNotice
// notifyの処理
- (void) obeyNotice:(NSString*)inParams
			 server:(NSInteger)inServerID
			channel:(ChannelModal*) inChannelModal
{	
	ChannelModal* channelModal = inChannelModal ? inChannelModal : [self activeChannel];   
    NSInteger server = (inServerID > 0) ? inServerID : [self activeServer];
    
    if(inParams){
        NSRange content = NSMakeRange(0, [inParams length]);
        NSString* channel = [[PreferenceWindowController sharedPreference]
							realChannelName:PrefixString(inParams, @" ", &content)];
		NSString* message;
		if(IsChannel(channel)){
			message = [inParams substringWithRange:content];
		}else{
			channel = [channelModal name];
			message = inParams;
		}
		IRCSession* session = [self findSessionWithID:server];
		if(session){
			[session sendNotice:message to:channel];
		}	
    }else{
		if(channelModal){
			TwoInputsSheet* sheet = [TwoInputsSheet sharedTwoInputsSheet];
			[sheet setCaption:NSLocalizedString(@"Please input notice message.", @"Please input notice message.")];
			[sheet setFirstTitle:NSLocalizedString(@"MGInputMessage", @"MESSAGE") value:@""];
			[sheet setSecondTitle:NSLocalizedString(@"MGInputChannel", @"CHANNEL")
							value:(channelModal ? [channelModal aliasName] : @"#")];
			[sheet setServerMenu:[self connectedServerMenu] value:server];
			[sheet setFormat:@"NOTICE@%d %@ %@" reverse:YES];
			[sheet setAction:@selector(obeyIRCCommand:) target:self];
			[[inChannelModal channelWindowController] showSheet:sheet];
			[sheet resetFirstResponder];
		}
	}	
}


//-- ObeyInvite
// inviteの処理
- (void) obeyInvite:(NSString*)inParams
			 server:(NSInteger)inServerID
			channel:(ChannelModal*)inChannelModal
{
    IRCSession* session;
	ChannelModal* channelModal = inChannelModal ? inChannelModal : [self activeChannel];
    NSInteger server = (inServerID > 0) ? inServerID : [self activeServer];
    if(inParams){
		NSRange content = NSMakeRange(0, [inParams length]);
        NSString* channel = [[PreferenceWindowController sharedPreference]
								realChannelName:PrefixString(inParams, @" ", &content)];
		NSString* nick;
		
		if(content.length > 0){ // パラメタが2つの場合
			nick = [inParams substringWithRange:content];
		}else{
			channel = [channelModal name];
			nick = inParams;
		}
		
		session = [self findSessionWithID:server];
		if(session && channelModal){
			[session sendINVITE:nick to:channel]; 
		}
    }else{
		TwoInputsSheet* sheet = [TwoInputsSheet sharedTwoInputsSheet];
		[sheet setCaption:NSLocalizedString(@"MGInviteDialog", @"Invite")];
		[sheet setFirstTitle:NSLocalizedString(@"MGInputNickname", @"NICK") value:@""];
		[sheet setSecondTitle:NSLocalizedString(@"MGInputChannel", @"CHANNEL")
						value:(channelModal ? [channelModal aliasName] : @"#")];
		[sheet setServerMenu:[self connectedServerMenu] value:server];
		[sheet setFormat:@"INVITE@%d %@ %@" reverse:YES];
		[sheet setAction:@selector(obeyIRCCommand:) target:self];
		[[inChannelModal channelWindowController] showSheet:sheet];
		[sheet resetFirstResponder];
		
        return;
    }
	
}


//-- obeyCommand
// command menuの処理
- (void) obeyCommand:(NSString*)inParams
			  server:(NSInteger)inServerID
			 channel:(ChannelModal*) inChannelModal
{
    //ChannelModal* channelModal = [self activeChannel];
    NSInteger server = (inServerID > 0) ? inServerID : [self activeServer];
	
    if(inParams){
        IRCSession* session = [self findSessionWithID:server];
		if(session){
			[session sendCommand:inParams]; 
		}
    }else{
		OneInputSheet* sheet = [OneInputSheet sharedOneInputSheet];
		[sheet setCaption:NSLocalizedString(@"MGCommandDialog", @"COMMAND")];
		[sheet setTitle:NSLocalizedString(@"MGInputCommand", @"COMMAND")
				  value:@""];
		[sheet setServerMenu:[self connectedServerMenu] value:server];
		[sheet setFormat:@"COMMAND@%d %@"];
		[sheet setAction:@selector(obeyIRCCommand:) target:self];
		[[inChannelModal channelWindowController] showSheet:sheet];
		[sheet resetFirstResponder];
	}
}


//-- obeyDisconnect:server:
// 切断処理
- (void) obeyDisconnect:(NSString*)inParams
				 server:(NSInteger)inServerID
				channel:(ChannelModal*) inChannelModal
{
	if(inParams){
		[self disconnectSessionByID:[inParams intValue]];
	}else{
		[self selectAndDisconnectSession];
	}
}


//-- obeyIRCCommand
// IRCCommandの処理
- (void) obeyIRCCommand:(NSString*)inMessage
{
	[self obeyIRCCommand:inMessage to:nil];
}

//-- obeyIRCCommand
// IRCCommandの処理
- (void) obeyIRCCommand:(NSString*)inMessage
					 to:(ChannelModal*)inChannelModal
{
    NSString *command, *param, *prefix;
    NSRange range;
    
	// kCoomandPrefixが重なる場合はメッセージを送信する
    if([inMessage hasPrefix:kCommandPrefix]){
        [self sendMessage:inMessage to:inChannelModal];
		return;
    }

	// コマンドを切り出す
    // prefix部分の切り出し
    range = NSMakeRange(0, [inMessage length]);
    prefix = PrefixString(inMessage, @" ", &range);
    param = (range.location == NSNotFound) ? nil : [inMessage substringWithRange:range];
    // command@serverの切り出し
    range = NSMakeRange(0, [prefix length]);
    command = PrefixString(prefix, @"@", &range);
    NSInteger serverid = (range.location == NSNotFound) ? [inChannelModal serverid]
                                              : [[prefix substringWithRange:range] intValue];
    if ([command length] < 1) return;
	
	// IRC内部用特殊コマンド
	if([command caseInsensitiveCompare:kCommandConnect] == NSOrderedSame){
		[self createSessionByID:[param intValue]];
		return;
	}
	// 接続しているサーバがない場合, 処理しない
	if([[self connectedServerMenu] numberOfItems] == 0){
		return;
	}
    // 規定のコマンドかどうか確認する
    if([command caseInsensitiveCompare:kCommandJoin] == NSOrderedSame){	
        [self obeyJoin:param server:serverid channel:inChannelModal];
    } else if([command caseInsensitiveCompare:kCommandPart] == NSOrderedSame){	
        [self obeyPart:param server:serverid channel:inChannelModal];
    } else if([command caseInsensitiveCompare:kCommandNick] == NSOrderedSame){	
        [self obeyNick:param server:serverid channel:inChannelModal];
    } else if([command caseInsensitiveCompare:kCommandWhois] == NSOrderedSame){	
        [self obeyWhois:param server:serverid channel:inChannelModal];
    } else if([command caseInsensitiveCompare:kCommandTopic] == NSOrderedSame){	
        [self obeyTopic:param server:serverid channel:inChannelModal];
	}else if([command caseInsensitiveCompare:kCommandMode] == NSOrderedSame){
		[self obeyMode:param server:serverid channel:inChannelModal];
	}else if([command caseInsensitiveCompare:kCommandCtcp] == NSOrderedSame){
		[self obeyCtcp:param server:serverid channel:inChannelModal];
	}else if([command caseInsensitiveCompare:kCommandAction] == NSOrderedSame){
		[self obeyAction:param server:serverid channel:inChannelModal];
	}else if([command caseInsensitiveCompare:kCommandInvite] == NSOrderedSame){
		[self obeyInvite:param server:serverid channel:inChannelModal];
    }else if([command caseInsensitiveCompare:kCommandQuit] == NSOrderedSame){
        [self obeyQuit:param server:serverid channel:inChannelModal];
	}else if([command caseInsensitiveCompare:kCommandNotice] == NSOrderedSame){
		[self obeyNotice:param server:serverid channel:inChannelModal];
		// IRC内部用特殊コマンド
	}else if([command caseInsensitiveCompare:kCommandCommand] == NSOrderedSame){
		[self obeyCommand:param server:serverid channel:inChannelModal];
    }else if([command caseInsensitiveCompare:kCommandDisconnect] == NSOrderedSame){
		[self obeyDisconnect:param server:serverid channel:inChannelModal];
	}else{
        // コマンドを送信する
        if(![command isEqualToString:@""] && serverid > 0){
            IRCSession* session = [self findSessionWithID:serverid];
            
            if(param){
				NSRange content = NSMakeRange(0, [param length]);
				NSString* channel = PrefixString(param, @" ", &content);
				if(content.length > 0){
					[session sendCommand:[NSString stringWithFormat:@"%@ %@ %@", command
						, [[PreferenceWindowController sharedPreference] realChannelName:channel]
						, [param substringWithRange:content]]];
				}else{
					[session sendCommand:[NSString stringWithFormat:@"%@ %@", command
						, [[PreferenceWindowController sharedPreference] realChannelName:channel]]];
				}
            }else{
                [session sendCommand:command];
            }
        }
    }
}


//-- performContextMenu
// context menuの実行
- (void) performContextMenu:(NSString*)inCommand
					context:(NSArray*)inContext
					channel:(ChannelModal*)inChannel
{
	int i;
	for(i=0; i<[inContext count]; i+=kIRCModeMax){
		NSRange range = NSMakeRange(i, ((i+kIRCModeMax > [inContext count]) ? [inContext count] - i : kIRCModeMax));
		NSString* command = [ContextMenuManager expandFormat:inCommand
													   param:[inContext subarrayWithRange:range]
													 context:inChannel];
		[self obeyIRCCommand:command to:inChannel];
	}
}


//-- setKeyWindowController
// key controllerの設定
-(void) setKeyWindowController:(ChannelWindowController*) inWindowController
{
	_keyWindowController = inWindowController;
}


#pragma mark Bindings

//-- valueClassForBinding:
//
- (Class) valueClassForBinding:(NSString *)binding {
	BindingItem* item = [_bindingItems objectForKey:binding];
	if(item){
		return [item valueClass];
	}else{
		return [super valueClassForBinding:binding];
	}
}

//-- bind:toObject:withKeyPath:options:
//
- (void)		bind : (NSString *) binding
			toObject : (id) observableObject
		 withKeyPath : (NSString *) keyPath
			 options : (NSDictionary *) options
{
	BindingItem* item = [_bindingItems objectForKey:binding];
	if(item){
		[item setObservedController:observableObject];
		[item setObservedKeyPath:keyPath];
		[item setTransformerName:[options objectForKey:@"NSValueTransformerName"]];
		[observableObject addObserver:self
						   forKeyPath:keyPath
							  options:0
							  context:[item identifier]];
		[self performSelector:[item selector] withObject:item];
	}else{
		[super bind:binding toObject:observableObject withKeyPath:keyPath options:options];
	}
}    



//-- observeValueForKeyPath:ofObject:change:context:
//
- (void) observeValueForKeyPath : (NSString *) keyPath
					   ofObject : (id) object
						 change : (NSDictionary *) change
						context : (void *) context
{
	BindingItem* item = [_bindingItems objectForKey:context];
	if(item){
		[self performSelector:[item selector] withObject:item];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}    


//-- infoForBinding
//
- (NSDictionary*) infoForBinding : (NSString *) binding
{
	BindingItem* item = [_bindingItems objectForKey:binding];
	if(item){
		return [item infoForBinding];
	}else{
		return [super infoForBinding:binding];
	}
}


//-- unbind
// 
- (void) unbind : (NSString *) binding
{
	BindingItem* item = [_bindingItems objectForKey:binding];
	if(item){
		[item unbind];
	}else{
		[super unbind:binding];
	}
}

#pragma mark Bindings Selector

//-- syncTextColor
// sync text color to 
-(void) syncTextColor:(BindingItem*) item
{
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if ([item transformerName] != nil) {
		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:[item transformerName]];
		value = [transformer transformedValue:value];
	}
	
	unsigned index = bindingIdentifier2MessageAttribute([item identifier]);
	
	NSMutableDictionary* attribute = [_attributeList objectAtIndex:index];
	[attribute setObject:value forKey:NSForegroundColorAttributeName];
}

//-- syncTextFont
// sync text color to 
-(void) syncTextFont:(BindingItem*) item
{
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if ([item transformerName] != nil) {
		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:[item transformerName]];
		value = [transformer transformedValue:value];
	}
	NSEnumerator* e = [_attributeList objectEnumerator];
	id attribute;
	while((attribute = [e nextObject])){
		[attribute setObject:value forKey:NSFontAttributeName];
	}
}

#pragma mark Bindings Interface
//-- setValue:forKey
//
/*-(void) setValue:(id) value
		  forKey:(NSString*) key
{
	id newValue = value ? value : [NSNull null];
	[self willChangeValueForKey:key];
	[_preferences setObject:newValue forKey:key];
    [self didChangeValueForKey:key];
}*/


//-- valueForKey
//
-(id) valueForKey:(NSString*) key
{
	return nil;
}

@end