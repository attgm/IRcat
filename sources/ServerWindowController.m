//
//  $RCSfile: ServerWindowController.m,v $
//  
//  $Revision: 48 $
//  $Date: 2008-04-15 11:21:38 +0900 (Tue, 15 Apr 2008) $
//

#import "ServerSetupController.h"
#import "PreferenceHeader.h"
#import "TextEncodings.h"

//#define kConnectServer @"ConnectServer"
//#define kServerList @"ServerList"

//-- addToolbarItem
// �c�[���o�[�̃A�C�e����ǉ����郆�[�e���e�B�֐�
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



@implementation ServerSetupController

static ServerSetupController *sSharedInstance = nil;


//-- init
// ������
- (id) init
{
    [super init];
    _serversModal = [[ServersModal alloc] init];
    
    return self;
}



//-- sharedPreference
// �C���X�^���X�𓾂�
+ (id) sharedPreference
{
    if (!sSharedInstance) {
        sSharedInstance = [[ServerSetupController alloc] init];
    }
    return sSharedInstance;
}



//-- showPanel
// ���ݒ�_�C�A���O��\��������
- (void) showPanel
{
    if (!_serverSetupWindow) {
        //NSImageCell *imageCell = [[[NSImageCell alloc] init] autorelease];
        if (![NSBundle loadNibNamed:@"ServerSetup" owner:self]) {
            NSLog(@"Failed to load ServerSetup.nib");
			NSBeep();
            return;
		}
		[_serverSetupWindow setExcludedFromWindowsMenu:YES];
		[_serverSetupWindow setMenu:nil];
        [self createToolbar];
        [self createLabelPopup];
		[self createEncordingPopup];
        // server list�̍�2��imageCell�ɂ���
        //[[mServersList tableColumnWithIdentifier:@"server_icon"] setDataCell:imageCell];
                
        //[_serversModal discardDisplayedValues];
        [self updateUI];
        [_serverSetupWindow center];
		//[mServersList selectRow:[_serversModal currentServerIndex] byExtendingSelection:NO];
		
		[_autoJoinChannelsController setDefaultValues:
			[NSDictionary dictionaryWithObject:@"#channel" forKey:@"name"]];
		[_autoJoinChannelsController setPrimeColumn:@"autojoin_channel"];
	}
    [_serverSetupWindow makeKeyAndOrderFront:nil];
}


//-- createToolbar
// �c�[���o�[�̐���
- (void) createToolbar
{
    NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:@"ServerSetupToolbar"] autorelease];
    
    [mToolbarItems release];
    mToolbarItems = [[NSMutableDictionary dictionary] retain];
    
    
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
/*    addToolbarItem(mToolbarItems,
                    kConnectServer,
                    @"Connect", @"Connect",
                    @"Connect to current server",
                    self,
                    @selector(setImage:), [NSImage imageNamed:@"toolbar_connect.tiff"],
                    @selector(openDrawer:),
                    NULL);*/
	addToolbarItem(mToolbarItems,
				   kAddServer,
				   NSLocalizedString(@"Add server", @"Add server"),
				   NSLocalizedString(@"Add server", @"Add server"),
				   @"Add server to server list",
				   _serversController,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_add_server.tiff"],
				   @selector(addItem:),
				   NULL);
	addToolbarItem(mToolbarItems,
				   kRemoveServer,
				   NSLocalizedString(@"Remove server", @"Remove server"),
				   NSLocalizedString(@"Remove server", @"Remove server"),
				   @"Remove server",
				   _serversController,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_del_server.tiff"],
				   @selector(remove:),
				   NULL);
    addToolbarItem(mToolbarItems,
                    kServerList,
					NSLocalizedString(@"Server list", @"Server list"),
					NSLocalizedString(@"Server list", @"Server list"),
				    @"Show/Hide Server List",
                    self,
                    @selector(setImage:), [NSImage imageNamed:@"toolbar_serverlist.tiff"],
                    @selector(openDrawer:),
                    NULL);
    
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    
    [_serverSetupWindow setToolbar:toolbar];
}



//-- createLabelPopup
// ���x���p��popup menu���쐬����
- (void) createLabelPopup
{
    NSEnumerator* e = [[NSArray arrayWithObjects:@"blue", 
                                                @"green",
                                                @"red",
                                                @"purple",
                                                @"orange", nil] objectEnumerator];
    id label;
    
    [_serverLabelPopup removeAllItems];
    
    while (label = [e nextObject]) {
        [_serverLabelPopup addItemWithTitle:NSLocalizedString(label, label)];
        [[_serverLabelPopup lastItem] setImage:[NSImage imageNamed:label]];
		[[_serverLabelPopup lastItem] setRepresentedObject:label];
    }
}


//-- createEncordingPopup
// Encording�p��popup menu���쐬����
- (void) createEncordingPopup
{
    NSEnumerator* e = [[TextEncodings encodingList] objectEnumerator];
    NSString* label;
    
    [_encordingPopup removeAllItems];
    
    while (label = [e nextObject]) {
		[_encordingPopup addItemWithTitle:NSLocalizedString(label, label)];
		[[_encordingPopup lastItem] setRepresentedObject:label];
	}
}



//-- saveDefaults
// �T�[�o�ݒ��ۑ�����
- (void) saveDefaults
{
//    [_serversModal commitDisplayedValues];
    [_serversModal savePreferencesToDefaults];
}


#pragma mark ��� actions ���
//-- openDrawer:
// drawer�̊J�������Ȃ�
- (IBAction) openDrawer:(id)sender
{
    [_serverListDrawer toggle:self];
}




//-- pressOkey
// OK�������ꂽ���̏���
- (IBAction)pressOkey:(id)sender
{
    [_serverListDrawer close:self];
    [self miscChanged:self];
//    [_serversModal commitDisplayedValues];
    [_serverSetupWindow close];
}


#pragma mark Update / Changed
//-- miscChanged:
// ���炩�̓��͂����������ɌĂяo�����
- (IBAction) miscChanged : (id) sender
{/*
    static NSNumber* yes = nil;
    static NSNumber* no = nil;
    
    if(!yes){
        yes = [[NSNumber alloc] initWithBool:YES];
        no = [[NSNumber alloc] initWithBool:NO];
    }

    //[mRevertButton setEnable:YES];
    
    //[_serversModal setObject:([mConvertCodeSwitch state] ? yes : no) forKey:kUseJISCode];
    [_serversModal setObject:([mInvisibleSwitch state] ? yes : no) forKey:kInvisibleMode];    
    [_serversModal setObject:[mMailAddress stringValue] forKey:kMailAddress];    
    [_serversModal setObject:[mNickName stringValue] forKey:kNickname];    
    [_serversModal setObject:[mPassword stringValue] forKey:kServerPassword];    
    [_serversModal setObject:[mPortNumber stringValue] forKey:kPortNumber];    
    [_serversModal setObject:[mRealname stringValue] forKey:kRealName];    
    [_serversModal setObject:[mServerAddress stringValue] forKey:kServerAddress];
    [_serversModal setObject:[[mServerLabelPopup selectedItem] representedObject] forKey:kServerLabel];
	[_serversModal setObject:[[mEncordingPopup selectedItem] representedObject] forKey:kTextEncoding];
	
    if(sender == mServerLabelPopup){
        [mServersList reloadData];
    }*/
}


//-- updateUI
//panel�̓��e��displayedValues�ɍ��킹��
- (void) updateUI
{
   /* NSDictionary* dic = [_serversModal displayedValues];
    
    //[mConvertCodeSwitch setState:([[dic objectForKey:kUseJISCode] boolValue] ? 1 : 0)];
    [mInvisibleSwitch setState:([[dic objectForKey:kInvisibleMode] boolValue] ? 1 : 0)];    
    [mMailAddress setStringValue:[dic objectForKey:kMailAddress]];    
    [mNickName setStringValue:[dic objectForKey:kNickname]];    
    [mPassword setStringValue:[dic objectForKey:kServerPassword]];    
    [mPortNumber setStringValue:[dic objectForKey:kPortNumber]];    
    [mRealname setStringValue:[dic objectForKey:kRealName]];    
    [mServerAddress setStringValue:[dic objectForKey:kServerAddress]];    
    NSString* label = [dic objectForKey:kServerLabel];
	[mServerLabelPopup selectItemWithTitle:NSLocalizedString(label, label)];
	label = [dic objectForKey:kTextEncoding];
	[mEncordingPopup selectItemWithTitle:NSLocalizedString(label, label)];
    [mServerName setStringValue:[dic objectForKey:kServerName]];
    
    [mAutoJoinChannels reloadData];*/
}



#pragma mark Interface

//-- serversModal
// �T�[�o�ݒ��Ԃ�
- (ServersModal*) serversModal
{
    return _serversModal;
}


//-- serverForID
// index�����ɃT�[�o�ݒ��Ԃ�
- (NSDictionary*) serverForID:(int) inIdentifier
{
	return [_serversModal serverForID:inIdentifier];
}


#pragma mark deletage : NSToolbar
//-- toolbarDefaultItemIdentifiers
// ����toolbar�̓��e��Ԃ�
- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:
								kAddServer,
								kRemoveServer,
                                NSToolbarFlexibleSpaceItemIdentifier,
                                kServerList,
                                nil];
}

//-- toolbarAllowedItemIdentifiers
// �ݒ�\��toolbar�̑I������Ԃ�
- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:
								kAddServer,
								kRemoveServer,
                                    kServerList,
                                    NSToolbarSeparatorItemIdentifier,
                                    NSToolbarSpaceItemIdentifier,
                                    NSToolbarFlexibleSpaceItemIdentifier,
                                    nil];
}


//-- toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar
// toolbar�̃G���g����Ԃ�
- (NSToolbarItem *)     toolbar : (NSToolbar *) toolbar
          itemForItemIdentifier : (NSString *) itemIdentifier
      willBeInsertedIntoToolbar : (BOOL) flag
{
    NSToolbarItem *newItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    NSToolbarItem *item=[mToolbarItems objectForKey:itemIdentifier];
    
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


@end
