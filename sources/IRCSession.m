//
//  $RCSfile: IRCSession.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "IRCSession.h"
#import "IRCMessage.h"
#import "PreferenceConstants.h"
#import "TextEncodings.h"
#import "IRcatInterface.h"


@implementation IRCSession
//-- initWithConfig
// 初期化
- (id) initWithConfig : (NSDictionary*) inConfig
            interface : (id) inInterface
            identify : (int) inID
{
    [super init];
    
    _config = [inConfig copyWithZone:[self zone]];
	_nickname = [inConfig objectForKey:kNickname];
    _serverid = inID;
    
    _interface = [inInterface retain];
	_sessionCondition = IRSessionConditionDisconnected;
	
	_encodingFilter = [TextEncodings filterFromEncoding:[inConfig objectForKey:kTextEncoding]];
	
	NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(windowCloseQuit)
				   name:@"IRcatWindowWillCloseNotification" object:_interface];
	
	_pingInterval = 0.0;
	_prevousPing = nil;
	_sessionTimer = nil;
	
    return self;
}


//-- windowCloseQuit
// windowが閉じるときの処理
- (void) windowCloseQuit
{
	[_interface obeyQuit:nil server:_serverid channel:nil];
}


//-- dealloc
// あとしまつ
- (void) dealloc
{
    [_config release];
    [_nickname release];
    if(_connection){
        [self sendQUIT:nil];
        [_connection release];
    }
    [_interface release];
	[_prevousPing release];
		
	[super dealloc];
}


#pragma mark -
#pragma mark Propaties
//-- name
// sessionの名前
- (NSString*) name
{
	return [_config objectForKey:kServerName];
}


//-- label
// iconの名前
- (NSString*) label
{
	return [_config objectForKey:kServerLabel];
}


#pragma mark -
#pragma mark Parametors
//-- setNickname
// nicknameの変更
- (void) setNickname:(NSString*) inNewNick
{
    NSString* old;
    
    if(inNewNick && [inNewNick length] > 0){
        old = _nickname;
        _nickname = [inNewNick copyWithZone:[self zone]];
        [old release];
    }
}

//-- nickname
// nickname を返す
-(NSString*) nickname
{
	return _nickname;
}

//-- sessionCondition
// sessionの状態を返す
- (SessionCondition) sessionCondition
{
	return _sessionCondition;
}


//-- setSessionCondition
// Sessionの状態を設定する 変化があればNotificationを飛ばす
-(void) setSessionCondition:(SessionCondition) inSessionCondition
{
	if(_sessionCondition != inSessionCondition){
		_sessionCondition = inSessionCondition;
		[[NSNotificationCenter defaultCenter]
			postNotificationName:@"IRcatSessionConditionChangedNotification" object:self userInfo:nil];
	}
}


//-- serverid
// サーバID
- (int) serverid
{
    return _serverid;
}

#pragma mark -
#pragma mark Connect/Disconnect

//-- connect
// 接続処理をおこなう
- (void) connect
{
	if(_sessionCondition == IRSessionConditionDisconnected){
		[self handleInternalMessage:NSLocalizedString(@"MGMessageConnecting", @"CONNECTING")];
		[self setSessionCondition:IRSessionConditionConnecting];
		_connection = [[TCPConnection alloc] initWithSession:self];
		[_connection connectTo:[_config objectForKey:kServerAddress]
						  port:[[_config objectForKey:kPortNumber] intValue]];
    }
}


//-- isConnected
// 接続しているかどうか
- (BOOL) isConnected
{
	return (_sessionCondition == IRSessionConditionEstablished);
}

#pragma mark -
#pragma mark Protcol<Session>
//-- handleConnected
// 接続完了後の認証処理を行う (rfc2812 3.1 Connection Registration)
- (void) handleConnected
{
    NSString * password;
    
    [self handleInternalMessage:NSLocalizedString(@"Registering", @"Registering")];
	[self setSessionCondition:IRSessionConditionRegistering];
    // negotiate login
    password = [_config objectForKey:kServerPassword];
    if (password != nil && ![password isEqualToString:@""]) {
        [self sendPASS:password];
    }
    [self sendNICK:_nickname];
    [self sendUSER:[_config objectForKey:kMailAddress] server:nil realname:[_config objectForKey:kRealName]];
}


//-- handleRegistered
// 認証終了時に呼び出される
- (void) handleRegistered
{
    // 接続完了のnotification
	[self setSessionCondition:IRSessionConditionEstablished];
	// auto join channelの設定
	NSEnumerator* e = [[_config objectForKey:kAutoJoinChannels] objectEnumerator];
	id channel;
	while(channel = [e nextObject]) {
		NSString* password = [channel objectForKey:@"password"];
		if(password && [password length] > 0){
			[_interface obeyJoin:[NSString stringWithFormat:@"%@ %@", [channel objectForKey:@"name"], password]
						  server:[self serverid] channel:nil];
		}else{
			[_interface obeyJoin:[channel objectForKey:@"name"] server:[self serverid] channel:nil];
		}
	}
	// user modeの設定
	if([[_config objectForKey:kInvisibleMode] boolValue] == YES){
		[_interface obeyMode:[NSString stringWithFormat:@"%@ +i", _nickname] server:[self serverid] channel:nil]; 
	}
}


//-- handleDisconnect
// 切断処理
- (void) handleDisconnect
{
    [self handleInternalError:NSLocalizedString(@"MGMessageDisconnect", @"DISCONNECT")];
	[self setSessionCondition:IRSessionConditionDisconnected];
	[_interface removeAllChannelAt:[self serverid]];
	[_interface removeSessionByID:[self serverid]];
}


//-- handleIncommingData
// 到着データの処理を行う
- (void) handleIncommingData : (NSData*) inIncommingData
{
    IRCMessage* message;
    NSString* incommingMessage = [_encodingFilter stringFromIncommingData:inIncommingData];
    
#ifdef IRCAT_DEBUG
    NSLog(@"%d:%@", [self serverid], incommingMessage);
#endif
    message = [[[IRCMessage alloc] initWithMessage:incommingMessage server:_serverid] autorelease];
    [self handleIRCMessage:message];
}


//-- handleError
// エラー処理を行う
- (void) handleConnectionError:(int) inErrorCode
{
	switch(inErrorCode){
		case IRErrorIllegalAddress:
			[self handleInternalError:NSLocalizedString(@"MGErrorIlligualAddress", @"Illigual address")];
			[self setSessionCondition:IRSessionConditionDisconnected];
			break;
		case IRErrorCannotConnect:
			[self handleInternalError:NSLocalizedString(@"MGErrorCannotConnect", @"Cannot connect")];
			[self setSessionCondition:IRSessionConditionDisconnected];
			break;
		default:
			[self handleInternalError:@"unknown error"];
			[self setSessionCondition:IRSessionConditionDisconnected];
			break;
	}
}

//-- sendCommand:immediately::
// command messageを送信する
-(void) sendCommand:(NSString*) command
		immediately:(BOOL) immediate
{
#ifdef IRCAT_DEBUG
    NSLog(@"...%@", command);
#endif
    NSData* data = [_encodingFilter outgoingDataFromString:command];
    
	[_connection sendData:data immediately:immediate];
}


//-- sendCommand
// command messageを送信する
- (void) sendCommand:(NSString*)command
{
	[self sendCommand:command immediately:NO];
}


@end
