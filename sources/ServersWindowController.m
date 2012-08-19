//
//  $RCSfile: ServersWindowController.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ServersWindowController.h"
#import "PreferenceConstants.h"
#import "TextEncodings.h"


@implementation ServersWindowController

static ServersWindowController *sSharedInstance = nil;


//-- init
// 初期化
- (id) init
{
    self = [super init];
    if(self != nil){
        _serversModal = [ServersModal sharedServersModal];
        [_serversModal selectedServerModal];
    }
    return self;
}



//-- sharedPreference
// インスタンスを得る
+ (id) sharedPreference
{
    if (!sSharedInstance) {
		sSharedInstance = [[ServersWindowController alloc] init];
    }
	
	return sSharedInstance;
}



//-- showPanel
// 環境設定ダイアログを表示させる
- (void) showPanel
{
	[_serversModal selectedServerModal];
    if (!_serverSetupWindow) {
        if (![NSBundle loadNibNamed:@"ServerSetup" owner:self]) {
            NSLog(@"Failed to load ServerSetup.nib");
			NSBeep();
            return;
		}
		[_serverSetupWindow setExcludedFromWindowsMenu:YES];
		[_serverSetupWindow setMenu:nil];
        [self createLabelPopUp];
		[self createEncordingPopUp];
        [_serverSetupWindow center];
		
		[_autoJoinChannelsController setDefaultValues:[NSDictionary dictionaryWithObject:@"#channel" forKey:@"name"]];
		[_autoJoinChannelsController setPrimeColumn:@"autojoin_channel"];
	}
    [_serverSetupWindow makeKeyAndOrderFront:nil];
	[_serversModal selectedServerModal];
}


//-- createLabelPopUp
// ラベル用のpopup menuを作成する
- (void) createLabelPopUp
{
	NSEnumerator* e = [[NSArray arrayWithObjects:@"blue", 
                                                @"green",
                                                @"red",
                                                @"purple",
                                                @"orange", nil] objectEnumerator];
    id label;
    [_serverLabelPopUp removeAllItems];
    
    while (label = [e nextObject]) {
        [_serverLabelPopUp addItemWithTitle:NSLocalizedString(label, label)];
        [[_serverLabelPopUp lastItem] setImage:[NSImage imageNamed:[NSString stringWithFormat:@"server_%@",label]]];
		[[_serverLabelPopUp lastItem] setRepresentedObject:label];
    }
	[_serverLabelPopUp synchronizeTitleAndSelectedItem];
	[_serverLabelPopUp bind:@"selectedObject" toObject:_serversController withKeyPath:@"selection.serverLabel" options:nil];
}


//-- createEncordingPopUp
// Encording用のpopup menuを作成する
- (void) createEncordingPopUp
{
    NSEnumerator* e = [[TextEncodings encodingList] objectEnumerator];
    NSString* label;
    
    [_encordingPopUp removeAllItems];
    
    while (label = [e nextObject]) {
		[_encordingPopUp addItemWithTitle:NSLocalizedString(label, label)];
		[[_encordingPopUp lastItem] setRepresentedObject:label];
	}
	[_encordingPopUp synchronizeTitleAndSelectedItem];
	[_encordingPopUp  bind:@"selectedObject" toObject:_serversController withKeyPath:@"selection.encoding" options:nil];
}



//-- saveDefaults
// サーバ設定を保存する
- (void) saveDefaults
{
    [_serversModal savePreferencesToDefaults];
}


#pragma mark Actions
//-- pressOkey
// OKが押された時の処理
- (IBAction)pressOkey:(id)sender
{
    [_serverListDrawer close:self];
    [_serverSetupWindow close];
}



#pragma mark Interface

//-- serversModal
// サーバ設定を返す
- (ServersModal*) serversModal
{
    return _serversModal;
}

@end
