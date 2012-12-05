//
//  $RCSfile: IRCSession_Handle.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
//#import <Carbon/Carbon.h>

#import "IRCSession.h"
#import "IRcatInterface.h"
#import "IRcatConstants.h"
#import "IRcatUtilities.h"
#import "PreferenceConstants.h"
#import "PreferenceWindowController.h"


@implementation IRCSession(Handle)

//-- handleIRCMessage
// command message/reply message/error messageに分けて処理する
- (void) handleIRCMessage:(IRCMessage*) inMessage
{
    switch([inMessage messageType]){
        case IRC_CommandMessage:
            [self handleCommandMessage:inMessage];
            break;
        case IRC_ReplyMessage:
        case IRC_ErrorMessage:
            [self handleReplyMessage:inMessage];
            break;
        default:
            [self handleReplyMessage:inMessage];
            break;
    }
}


//-- handleCommandMessage
// command messageの処理
- (void) handleCommandMessage:(IRCMessage*) inMessage
{
    NSString* command = [inMessage commandNumber];
    
    if([command caseInsensitiveCompare:kCommandPrivmsg] == NSOrderedSame)
        [self handlePrivmsg:inMessage];
    else if([command caseInsensitiveCompare:kCommandJoin] == NSOrderedSame)
        [self handleJoin:inMessage];
    else if([command caseInsensitiveCompare:kCommandPart] == NSOrderedSame)
        [self handlePart:inMessage];
    else if([command caseInsensitiveCompare:kCommandQuit] == NSOrderedSame)
        [self handleQuit:inMessage];
    else if([command caseInsensitiveCompare:kCommandTopic] == NSOrderedSame)
        [self handleTopic:inMessage];
    else if([command caseInsensitiveCompare:kCommandNotice] == NSOrderedSame)
        [self handleNotice:inMessage];
    else if([command caseInsensitiveCompare:kCommandInvite] == NSOrderedSame)
        [self handleInvite:inMessage];
    else if([command caseInsensitiveCompare:kCommandKick] == NSOrderedSame)
        [self handleKick:inMessage];
    else if([command caseInsensitiveCompare:kCommandNick] == NSOrderedSame)
        [self handleNick:inMessage];
    else if([command caseInsensitiveCompare:kCommandSQuit] == NSOrderedSame)
        [self handleSQuit:inMessage];
    else if([command caseInsensitiveCompare:kCommandObject] == NSOrderedSame)
        [self handleObject:inMessage];
    else if([command caseInsensitiveCompare:kCommandMode] == NSOrderedSame)
        [self handleMode:inMessage];
    else if([command caseInsensitiveCompare:kCommandPing] == NSOrderedSame)
        [self handlePing:inMessage];
    else if([command caseInsensitiveCompare:kCommandError] == NSOrderedSame)
        [self handleError:inMessage];
    /*else
*/       // [self appendMessage:inMessage format:DEFAULT_COMMAND_FORMAT];
}



//------------ HandleReplyMessage
//	reply messageと error messageを処理する
//		inMessage : メッセージ
- (void) handleReplyMessage:(IRCMessage*) inMessage
{
    [_interface appendMessage:inMessage format:[inMessage commandNumber]];
 
    switch([[inMessage commandNumber] intValue]){
        case 001:
            [self handleRegistered];
            break;
        case RPL_TOPIC:
            [self handleTopicReply:inMessage];
            break;
        case RPL_NAMREPLY:
            [self handleNamesReply:inMessage];
            break;
        case RPL_ENDOFNAMES:
            [self handleNamesEndReply:inMessage];
            break;
        case RPL_CHANNELMODEIS:
            [self handleChannelModeReply:inMessage];
            break;
        case ERR_NOSUCHNICK:
            [self handleNoSuchNickError:inMessage];
            break;
        case ERR_NICKNAMEINUSE:
		case ERR_UNAVAILRESOURCE:
            [self handleNickInUseError:inMessage];
            break;
        case ERR_BADCHANNELKEY:
            [self handleBadChannelKey:inMessage];
            break;
    }
}


#pragma mark -
#pragma mark Command Message
//-- handleJOIN
// JOINコマンドに対する応答
// JOIN :<channel>\a<mode>
- (void) handleJoin:(IRCMessage*)inMessage
{
    NSString *channel, *flag;
    
    // チャンネル名の解析
    [inMessage devideTrailingBy:@"\a"];
    channel = [inMessage paramAtIndex:1];
    flag = [inMessage paramAtIndex:2];
    
    // 自分がチャンネルに入ったかどうかのチェック
    if([self isMyself:[inMessage nickname]]){
        [_interface createNewChannel:channel server:_serverid];
        // ModeRequestの送信
        [self sendModeRequest:channel];
    }else{
        // 誰かがチャンネルに入った場合
        // nicknameの整形
        NSString* nick = (flag == nil) ?
            [inMessage nickname] : [NSString stringWithFormat:@"%@%@", flag, [inMessage nickname]];
        [_interface appendMessage:inMessage format:kJoinFormat]; // メッセージの表示
        [_interface appendNick:nick toChannel:channel server:_serverid];
    }
}


//-- handlePart
// PARTコマンドに対する応答
// PART <channel> :<message>
- (void) handlePart:(IRCMessage*)inMessage
{
    NSString *channel = [inMessage paramAtIndex:1];
    
    // 自分がチャンネルから抜けたかどうかのチェック
    if([self isMyself:[inMessage nickname]]){
        [_interface removeChannel:channel server:_serverid];
        [_interface appendMessage:inMessage format:kPartSelfFormat]; // メッセージの表示
		[_interface appendCandidateChannel:[inMessage paramAtIndex:1]];
    }else{
        // 誰かがチャンネルから抜けた
        [_interface appendMessage:inMessage format:kPartFormat]; // メッセージの表示
        [_interface removeNick:[inMessage nickname] fromChannel:channel server:_serverid];
    }
}



//-- handleTopic
// TOPICコマンドに対する応答
// TOPIC <channel> :<topic>
- (void) handleTopic:(IRCMessage*)inMessage
{
    [_interface appendMessage:inMessage format:kTopicFormat]; // メッセージの表示
    [_interface setTopic:[inMessage paramAtIndex:2] channel:[inMessage paramAtIndex:1] server:_serverid];
}


//-- handlePrivmsg
// PRIVMSGコマンドに対する処理
// :nick!server PRIVMSG channel :message
// :nick!server PRIVMSG nick :\001ctcp_command params\001 (ctcp command)
- (void) handlePrivmsg:(IRCMessage*) inMessage
{
    if([inMessage isCtcpCommand] == YES){
        [self handleCtcpCommand:inMessage];
    }else if([self isMyself:[inMessage paramAtIndex:1]]){ // private messageの場合
        [self handlePrivateMessage:inMessage];
    }else if([self isMyself:[inMessage nickname]]){ // 自分の発言の場合
		if(IsNick([inMessage paramAtIndex:1])){
			[_interface appendMessage:inMessage format:kPrivmsgUserSelfFormat];
		}else{
			[_interface appendMessage:inMessage format:kPrivmsgChannelSelfFormat];
		}
    }else{
        [_interface appendMessage:inMessage format:kPrivmsgChannelFormat];
    }
}



//-- handlePrivateMessage
// private message(PRIVMSG)に対する処理
// :nick!server PRIVMSG myself :message
- (void) handlePrivateMessage:(IRCMessage*) inMessage
{
    if([inMessage nickname] != nil){
        // もしその人と間のチャンネルが無かった場合チャンネルを作る
        if([_interface findChannelWithName:[inMessage nickname] server:[inMessage serverid]] == nil){
            [_interface createNewChannel:[inMessage nickname] server:[inMessage serverid] isActive:NO];
			// イベントフック
			if([[PreferenceModal prefForKey:kNotifyOfNewPrivChannel] boolValue]){
				[inMessage setNotification:YES];
			}
		}
        [_interface appendMessage:inMessage format:kPrivmsgUserFormat];
    }else{
        [_interface appendMessage:inMessage format:kPrivmsgConsoleFormat];
    }
}


//-- handleNotice
// NOTICEコマンドに対する処理
// :nick!server NOTICE channel :message
// :nick!server NOTICE nick :\001ctcp_command params\001 (ctcp reply)
-(void) handleNotice:(IRCMessage*) inMessage
{
    if([inMessage isCtcpCommand] == YES){
        [self handleCtcpReply:inMessage];
    }else if([self isMyself:[inMessage paramAtIndex:1]]){ // private messageの場合
        [self handlePrivateMessage:inMessage];
    }else{
        [_interface appendMessage:inMessage format:kNoticeChannelFormat];
    }
}


//-- handleInvite
// INVITEコマンドに対する処理
// :nick!server INVITE nick channel
- (void) handleInvite:(IRCMessage*) inMessage
{
    if([self isMyself:[inMessage paramAtIndex:1]]){ // 自分が招待された場合
        [_interface appendMessage:inMessage format:kInviteSelfFormat];
		if([[PreferenceModal prefForKey:kNotifyOfInvitedChannel] boolValue]){
			[inMessage setNotification:YES];
		}
		if([[PreferenceModal prefForKey:kAutoJoin] boolValue]){
			[_interface obeyJoin:[inMessage paramAtIndex:2] server:[self serverid] channel:nil]; // auto join
		}else{
			[_interface appendCandidateChannel:[inMessage paramAtIndex:2]];
		}
    }else{ // 自分が招待した場合
        [_interface appendMessage:inMessage format:kInviteFormat];
    }
}


//-- handleKick
// KICKコマンドに対する処理
// :nick!server KICK chnanel nick :comment
- (void) handleKick:(IRCMessage*) inMessage
{
    // 自分が蹴られた場合
    if([self isMyself:[inMessage paramAtIndex:2]]){
        [_interface removeChannel:[inMessage paramAtIndex:1] server:_serverid];
        [_interface appendMessage:inMessage format:kKickSelfFormat];
    }else{ // 他人が蹴られた場合
        [_interface removeNick:[inMessage paramAtIndex:2]
                    fromChannel:[inMessage paramAtIndex:1] server:_serverid];    
        [_interface appendMessage:inMessage format:kKickFormat];
    }
}


//-- handleNick
// NICKコマンドに対する処理
// :nick!server NICK newnick
- (void) handleNick:(IRCMessage*) inMessage
{
    // 自分のnickの変更
    if([self isMyself:[inMessage nickname]]){
        [self setNickname:[inMessage paramAtIndex:1]];
    }
    // nickの変更
    [_interface appendMessage:inMessage format:kNickFormat];
    [_interface renameNick:[inMessage nickname] to:[inMessage paramAtIndex:1] server:_serverid];
}


//-- handleSQuit
// SQUITコマンドに対する処理
- (void) handleSQuit:(IRCMessage*) inMessage
{
    /* 何もしない! */
}


//-- handleObject
// OBJECTコマンドに対する処理
- (void) handleObject:(IRCMessage*) inMessage
{
    /* 何もしない! */
}


//-- handleMode
// MODEコマンドに対する処理
// MODE <channel> <mode> :<params> 
- (void) handleMode:(IRCMessage*) inMessage
{
	NSString* channel = [inMessage paramAtIndex:1];
    // user mode
    if([self isMyself:channel]){
        [_interface appendMessage:inMessage format:kModeUserFormat];
    // channel mode
    }else{
		[_interface appendMessage:inMessage format:kModeChannelFormat];
		[self handleChannelMode:inMessage at:2 for:channel];
	}
}


//-- handleChannelMode
// チャンネルmodeの解析
// modeの解析
- (void) handleChannelMode:(IRCMessage*) inMessage
						at:(int) inStartParam
					   for:(NSString*) inChannel
{
	unichar flag;
	int i;
	BOOL ison = TRUE;
	BOOL hasParam = FALSE;
	int paramIndex = inStartParam + 1;
	NSString* modes = [inMessage paramAtIndex:inStartParam];
	NSString* param = [inMessage paramAtIndex:paramIndex++];
	NSInteger serverid = [inMessage serverid];

	for(i=0; i<[modes length]; i++){
		flag = [modes characterAtIndex:i];
		switch(flag) {
			case '+':
			case '-':
				ison = (flag == '+');
				continue;
			case IRModeChanOperatorPrivs:
				[_interface setFlag:IRFlagOperator channel:inChannel server:serverid nick:param ison:ison];
				hasParam = TRUE;
				break;
			case IRModeChanSpeakAbility:
				[_interface setFlag:IRFlagSpeakAbility channel:inChannel server:serverid nick:param ison:ison];
				hasParam = TRUE;
				break;
			case IRModeChanUserLimit:				
			case IRModeChanChannelKey:
				[_interface setChannelFlag:flag channel:inChannel server:serverid ison:ison];
				hasParam = TRUE;
				break;
			case IRModeChanPrivateChannel:
			case IRModeChanSecretChannel:
			case IRModeChanInviteOnly:
			case IRModeChanNoMessagesFromOutside:
			case IRModeChanTopicSettable:
			case IRModeChanModerated:
				[_interface setChannelFlag:flag channel:inChannel server:serverid ison:ison];
				hasParam = FALSE;
				break;
			case IRModeChanBanMask:
				hasParam = TRUE;
				break;
			default:
				hasParam = FALSE;
				break;
		}
		if (hasParam && param){
			param = [inMessage paramAtIndex:paramIndex++];
		}
	}
}


//-- handlePing
// PINGコマンドに対する応答
// POING :<message>
- (void) handlePing:(IRCMessage*)inMessage
{
    // PONGを返す
    [self sendPONG:[inMessage paramAtIndex:1]];
}


//-- handleQuit
// QUITコマンドに対する応答
// QUIT :<message>
- (void) handleQuit:(IRCMessage*)inMessage
{
    // 自分がquitしたのかどうかのチェック
    if([self isMyself:[inMessage nickname]]){
        [_interface appendMessage:inMessage format:kQuitSelfFormat];
    }else{    
        [_interface appendMessage:inMessage format:kQuitFormat];
        [_interface removeNick:[inMessage nickname] server:_serverid];
    }
}


//-- handleError
// ERRORコマンドに対する応答
// ERROR :<message>
- (void) handleError:(IRCMessage*)inMessage
{
    [_interface appendMessage:inMessage format:kDefaultErrorFormat];
}


#pragma mark CTCP

//-- handleCtcpCommand
// ctcp commandに対する処理
// :nick!server PRIVMSG nick :\001ctcp_command params\001 (ctcp command)
- (void) handleCtcpCommand:(IRCMessage*) inMessage
{
    NSString* command = [inMessage paramAtIndex:2];
    NSString* recipient = [inMessage paramAtIndex:3];
    NSString* ctcpReply = @"";
    
    // CTCP ACTION
	if([command caseInsensitiveCompare:kCommandCtcpAction] == NSOrderedSame){
		[_interface appendMessage:inMessage format:kCTCPActionFormat];
	}else{
		// CTCPメッセージの到着を表示する
		if([[PreferenceModal prefForKey:kDisplayCTCP] boolValue] == YES){
			[_interface appendMessage:inMessage format:kCTCPRecivedFormat];
		}
			
		if([command caseInsensitiveCompare:kCommandCtcpVersion] == NSOrderedSame){
			ctcpReply = [NSString stringWithFormat:@"\1%@ %@\1",
				kCommandCtcpVersion,
				[NSString stringWithFormat:@"IRcat %@ (Mac OS X)",
					[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
		}else if([command caseInsensitiveCompare:kCommandCtcpPing] == NSOrderedSame){
			if(recipient){
				ctcpReply = [NSString stringWithFormat:@"\1%@ %@\1",
					kCommandCtcpPing,
					recipient];
			}else{
				ctcpReply = [NSString stringWithFormat:@"\1%@\1", kCommandCtcpPing];
			}
		}else if([command caseInsensitiveCompare:kCommandCtcpClientInfo] == NSOrderedSame){
			ctcpReply = [NSString stringWithFormat:@"\1%@ %@\1",
					kCommandCtcpClientInfo,
					@"ACTION CLIENTINFO USERINFO PING TIME VERSION"];
		}else if([command caseInsensitiveCompare:kCommandCtcpUserInfo] == NSOrderedSame){
			ctcpReply = [NSString stringWithFormat:@"\1%@ %@\1", 
				kCommandCtcpUserInfo,
				[PreferenceModal prefForKey:kUserInfo]];
		}else if([command caseInsensitiveCompare:kCommandCtcpTime] == NSOrderedSame){
			ctcpReply = [NSString stringWithFormat:@"\1%@ %@\1", 
				kCommandCtcpTime,
				[[NSCalendarDate calendarDate] description]];
		}else{
			return; // Unknown CTCP
		}
		[self sendNotice:ctcpReply to:[inMessage nickname]];
	}
}


//-- handleCtcpReply
// ctcp replyに対する処理
// :nick!server NOTICE nick :\001ctcp_command params\001 (ctcp command)
- (void) handleCtcpReply:(IRCMessage*) inMessage
{
    NSString* command = [inMessage paramAtIndex:2];
    NSString* recipient = [inMessage paramAtIndex:3];
    
    // CTCP ACTION
    if([command caseInsensitiveCompare:kCommandCtcpAction] == NSOrderedSame){
        [_interface appendMessage:inMessage format:kCTCPActionFormat];
    // CTCP PING
    }else if([command caseInsensitiveCompare:kCommandCtcpPing] == NSOrderedSame){
        int pingTick = [recipient intValue];
        if(pingTick > 0){
            int pingTime = ((int)([[NSDate date] timeIntervalSince1970]) - pingTick);
			[inMessage setExtendString:[NSString stringWithFormat:@"%d", pingTime]];
			[_interface appendMessage:inMessage format:kCTCPPingFormat];
		}else{
			[_interface appendMessage:inMessage format:kCTCPDefaultFormat];
		}
    // Default
    }else{
        [_interface appendMessage:inMessage format:kCTCPDefaultFormat];
    }
}


#pragma mark -
#pragma mark Reply Message
//-- handleNamesReply
// RPL_NAMREPLY <me> = <channel> :[[@|+]<nick> [[@|+]<nick> [...]]]
- (void) handleNamesReply:(IRCMessage*) inMessage
{
    NSArray* appendNick;
    
    appendNick = [[inMessage paramAtIndex:3] componentsSeparatedByString:@" "];
    [_interface appendNicks:appendNick toChannel:[inMessage channel] server:[inMessage serverid]];
}


//-- handleNamesEndReply
// RPL_NAMREPLY <me> = <channel> :[[@|+]<nick> [[@|+]<nick> [...]]]
- (void) handleNamesEndReply:(IRCMessage*) inMessage
{
    [_interface refleshNickList:[inMessage channel] server:[inMessage serverid]];
}


//-- handleNamesTopicReply
// RPL_NAMREPLY <me> = <channel> :[[@|+]<nick> [[@|+]<nick> [...]]]
- (void) handleNamesTopicReply:(IRCMessage*) inMessage
{
}


//-- handleChannelModeReply
// RPL_CHANNELMODEIS <me> <channel> <mode> :<mode params>
- (void) handleChannelModeReply:(IRCMessage*) inMessage
{
	[self handleChannelMode:inMessage at:2 for:[inMessage paramAtIndex:1]];
}


//-- handleNickInUseError
// RPL_NAMREPLY <me> = <channel> :[[@|+]<nick> [[@|+]<nick> [...]]]
- (void) handleNickInUseError:(IRCMessage*) inMessage
{
	if(![self isConnected]) {
		NSString* newNick = [_nickname stringByAppendingString:@"_"];
		[self setNickname:newNick];
		[self sendNICK:newNick];
	}
}


//-- handleNoSuchNickError
// 
- (void) handleNoSuchNickError:(IRCMessage*) inMessage
{
    // whowas commandを送信する
    [self sendWHOWAS:[inMessage paramAtIndex:1]];
}


//-- handleTopicReply
// RPL_TOPIC <me> <channel> :<topic>
- (void) handleTopicReply:(IRCMessage*) inMessage
{
    [_interface setTopic:[inMessage paramAtIndex:2] channel:[inMessage paramAtIndex:1] server:_serverid];
}


//-- handleBadChannelKey
// RPL_NAMREPLY <me> = <channel> :[[@|+]<nick> [[@|+]<nick> [...]]]
- (void) handleBadChannelKey:(IRCMessage*) inMessage
{
}


#pragma mark -
#pragma mark Internal Message
//-- handleInternalMessage
// 内部メッセージの処理
- (void) handleInternalMessage:(NSString*) inMessage
{
    NSString* string;
    IRCMessage* message;
    
    string = [NSString stringWithFormat:@"* %@ :%@", [_config objectForKey:kServerName], inMessage];
    message = [[[IRCMessage alloc] initWithMessage:string server:[self serverid]] autorelease];
    [_interface appendMessage:message format:kInternalMessageFormat];
}


//-- handleInternalError
// 内部メッセージの処理
- (void) handleInternalError:(NSString*) inMessage
{
    NSString* string;
    IRCMessage* message;
    
    string = [NSString stringWithFormat:@"* %@ :%@", [_config objectForKey:kServerName], inMessage];
    message = [[[IRCMessage alloc] initWithMessage:string server:[self serverid]] autorelease];
    [_interface appendMessage:message format:kInternalErrorFormat];
}


#pragma mark -

//-- isMyself
// 自分かどうかのチェック
- (BOOL) isMyself:(NSString*) inString
{
    return ([_nickname caseInsensitiveCompare:inString] == NSOrderedSame);
}
@end
