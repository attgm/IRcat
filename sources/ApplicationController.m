//
//  $RCSfile: ApplicationController.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ServersWindowController.h"
#import "PreferenceWindowController.h"
#import "PreferenceModal.h"
#import "IRcatInterface.h"
#import "ApplicationController.h"
#import "ChannelModal.h"

#import "FontNameToFontTransformer.h"
#import "ColorNameToColorTransformer.h"
#import "ImageNameToImageTransformer.h"
#import "IsEmptyStringTransformer.h"
#import "SelectedValueToIndexTransformer.h"

#import "IRcatConstants.h"

#import "IRCMessage.h"


static NSArray *commandMenu()
{
    static NSArray *menu = nil;
    
    if(!menu){
        menu = [[NSArray alloc] initWithObjects:
			[NSString stringWithString:@"JOIN"], // 0
            [NSString stringWithString:@"PART"], // 1
            [NSString stringWithString:@"JOIN"], // 2 ぷりぶ
            [NSString stringWithString:@"NICK"], // 3
            [NSString stringWithString:@"WHOIS"], // 4
            [NSString stringWithString:@"INVITE"], // 5
            [NSString stringWithString:@"TOPIC"], // 6
            [NSString stringWithString:@"MODE"], // 7
            [NSString stringWithString:@"ACTION"], // 8
            [NSString stringWithString:@"COMMAND"], // 9
            [NSString stringWithString:@"CTCP VERSION"], // 10
            nil];
    }
    return menu;
};


@implementation ApplicationController

#pragma mark Launch and Terminate
//-- applicationDidFinishLaunching
// アプリケーション起動後に呼ばれる
- (void) applicationDidFinishLaunching : (NSNotification *) aNotification
{
	[NSValueTransformer setValueTransformer:[[[FontNameToFontTransformer alloc] init] autorelease]
									forName:[FontNameToFontTransformer className]];
	[NSValueTransformer setValueTransformer:[[[ColorNameToColorTransformer alloc] init] autorelease]
									forName:[ColorNameToColorTransformer className]];
	[NSValueTransformer setValueTransformer:[[[ImageNameToImageTransformer alloc] init] autorelease]
									forName:[ImageNameToImageTransformer className]];
	[NSValueTransformer setValueTransformer:[[[IsEmptyStringTransformer alloc] init] autorelease]
									forName:[IsEmptyStringTransformer className]];
	[NSValueTransformer setValueTransformer:[[[SelectedValueToIndexTransformer alloc] init] autorelease]
									forName:[SelectedValueToIndexTransformer className]];

    _interface = [[IRcatInterface alloc] init];
	
#ifdef NOG_PATCH	
	mList = [[NSMutableArray alloc] init];
	[mList addObject:_interface];
#endif
}


//--- applicationWillTerminate
// アプリケーション終了時に呼ばれる
- (void) applicationWillTerminate : (NSNotification *) aNotification
{
    // 初期設定の保存
    [[PreferenceModal sharedPreference] savePreferencesToDefaults];
    [[ServersWindowController sharedPreference] saveDefaults];
}


#pragma mark Preference
//-- showPreferenceDialog
// 環境設定ダイアログの表示
- (IBAction)showPreferenceDialog:(id)sender
{
    [[PreferenceWindowController sharedPreference] showPanel];
}


//-- showServerSetupDialog
// サーバ設定ダイアログの表示
- (IBAction)showServerSetupDialog:(id)sender
{
	[[ServersWindowController sharedPreference] showPanel];
}


#pragma mark Obey command
//-- obeyConnect
// サーバへの接続を行う
- (IBAction) obeyConnect : (id)sender
{
    [_interface createNewSession];
}


//-- obeyConnectTo
// サーバを選択して接続を行う
- (IBAction) obeyConnectTo : (id)sender
{
	[_interface selectAndCreateNewSession];
}


//-- obeyDisconnect
// サーバの切断を行う
- (IBAction) obeyDisconnect : (id) sender
{
	[_interface selectAndDisconnectSession];
}


//-- obeyCommand
// command messageが送信された時の処理
- (IBAction)obeyCommand:(id)sender
{
    NSArray* menuitems = commandMenu();
    int tag = [sender tag];
    
    if(0 <= tag && tag < [menuitems count]){
		[_interface obeyIRCCommand:[menuitems objectAtIndex:tag] to:[_interface activeChannel]];
    }
}


//-- startLogging
// ログの開始/停止
- (IBAction)startLogging:(id)sender
{
	[[_interface activeChannel] setLoggingChannel:![[_interface activeChannel] loggingChannel]];
	[_interface refleshLogIcon];
}


//-- validateMenuItem
// menu item のenable/disenable
- (BOOL) validateMenuItem:(NSMenuItem*) inItem
{
	int tag = [inItem tag];
	if(tag == mt_logging){
		[inItem setState:(([[_interface activeChannel] loggingChannel]) ? NSOnState : NSOffState)];
	}
	
	if(tag == 101 || tag > 199){
		return YES;
	}else if(tag == 100){
		if([[_interface connectedServerMenu] numberOfItems] == 0){
			return YES;
		}
	}else if(tag == mt_disconnect){
		int servers = [[_interface connectedServerMenu] numberOfItems];
		if(servers == 1){
			[inItem setTitle:NSLocalizedString(@"MTDisconnect", @"Disconnect")];
			return YES;
		}else if(servers > 1){
			[inItem setTitle:NSLocalizedString(@"MTDisconnectTo", @"Disconnect...")];
			return YES;
		}
		return NO;
	}else{
		if([[_interface connectedServerMenu] numberOfItems] > 0){
			return YES;
		}
	}
	return NO;
}


//-- nextChannel
// チャンネルの移動
- (IBAction)nextChannel:(id)sender
{
	[_interface switchNextChannel];
}


//-- previousChannel
// チャンネルの移動
- (IBAction)previousChannel:(id)sender
{
	[_interface switchPreviousChannel];
}

#pragma mark -
#pragma mark test
- (IBAction)testAction:(id)sender
{
	/*
    IRCMessage* message;
    
    message = [[IRCMessage alloc] initWithMessage:@"" server:0];
    [message isCtcpCommand];
    [_interface appendMessage:message format:kPrivmsgChannelFormat];
    [message release];
*/}

@end
