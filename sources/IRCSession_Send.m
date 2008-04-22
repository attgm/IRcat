//
//  $RCSfile: IRCSession_Send.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "IRCSession.h"
#import "IRCMessage.h"
#import "IRcatConstants.h"
#import "TextEncodings.h"

@implementation IRCSession(send)

#pragma mark ･･･ Connection regsitration (RFC 1459 - Sec. 4.1) ･･･
//-- sendPASS
// PASS <password>
- (void) sendPASS:(NSString*) inPassword
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@", kCommandPassword, inPassword]];
}


//-- sendNICK
// NICK <new nick>
- (void) sendNICK:(NSString*) inNickname
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@", kCommandNick, inNickname]];
}


//-- sendUSER
// USER <username> 0 * :<realname>
- (void)  sendUSER:(NSString*) inUsername
            server:(NSString*) inServername
          realname:(NSString*) inRealname
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@ 0 * :%@",
                        kCommandUser, inUsername, inRealname]];
}


//-- sendQUIT
// QUIT [:<quit message>]
- (void) sendQUIT:(NSString*) inQuitMessage
{
    if (inQuitMessage != nil && ![inQuitMessage isEqualToString:@""])
        [self sendCommand:[NSString stringWithFormat:@"%@ :%@", kCommandQuit, inQuitMessage]];
    else
		[self sendCommand:[NSString stringWithFormat:@"%@", kCommandQuit]];
}


//-- sendWHOWAS
// WHOIS <nickname>
- (void) sendWHOIS:(NSString*) inNick
{
    // WHOIS command w/ nickname only
    [self sendCommand:[NSString stringWithFormat:@"%@ %@", kCommandWhois, inNick]];
}


#pragma mark ･･･ Channel operations (RFC 1459 - Sec. 4.2) ･･･
//-- sendJOIN
// JOIN <channel> [<password>]
- (void) sendJOIN:(NSString*) inChannelName
         password:(NSString*) inPassword
{
    if (inPassword != nil && ![inPassword isEqualToString:@""])
        [self sendCommand:
            [NSString stringWithFormat:@"%@ %@ %@", kCommandJoin, inChannelName, inPassword]];
    else
		[self sendCommand:[NSString stringWithFormat:@"%@ %@", kCommandJoin, inChannelName]];
}


//-- sendPART:message:
// PART <channel> [:<message>]
- (void) sendPART:(NSString*) inChannelName
          message:(NSString*) inMessage
{
    if(inMessage != nil && ![inMessage isEqualToString:@""]){
        [self sendCommand:[NSString stringWithFormat:@"%@ %@ :%@", kCommandPart, inChannelName, inMessage]];
    }else{
        [self sendCommand:[NSString stringWithFormat:@"%@ %@", kCommandPart, inChannelName]];
    }
}


// -- sendMODE
// MODE <channel> <newmode>
- (void) sendMODE:(NSString*) inMode
			   to:(NSString*) inChannelOrNick
{
    [self sendCommand:[NSString 
        stringWithFormat:@"%@ %@ %@", kCommandMode, inChannelOrNick, inMode]];
}


//-- sendModeRequest
// MODE <channel>
- (void) sendModeRequest:(NSString*) inChannelOrNick
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@", kCommandMode, inChannelOrNick]];
}


//-- sendCtcpCommand
// CTCP <nick> :\1<command>\1
- (void) sendCtcpCommand:(NSString*) inCommand
					  to:(NSString*) inNickOrChannel
{
	[self sendCommand:[NSString stringWithFormat:@"%@ %@ :\1%@\1", kCommandPrivmsg, inNickOrChannel, inCommand]]; 
}



//-- sendTOPIC
// TOPIC <channel> :<new topic>
- (void) sendTOPIC:(NSString*) inTopic
                to:(NSString*) inChannel
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@ :%@", kCommandTopic, inChannel, inTopic]];
}


//-- sendNAMES
// NAMES <channel>
- (void) sendNAMES:(NSString*) inChannel
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@", kCommandNames, inChannel]];
}


//-- sendLIST
- (void) sendLIST:(NSString*) inChannel
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@", kCommandList, inChannel]];
}



//-- sendINVITE
- (void) sendINVITE:(NSString*) inNick
                 to:(NSString*) inChannel
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@ %@", kCommandInvite, inNick, inChannel]];
}


//-- sendKICK
- (void) sendKICK:(NSString*) inNick
             from:(NSString*) inChannel
          comment:(NSString*) inComment
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@ %@ :%@", kCommandKick, inChannel, inNick, inComment]];
}



//-- sendPONG
- (void) sendPONG:(NSString*) inFrom
{
    [self sendCommand:[NSString stringWithFormat:@"%@ :%@", kCommandPong, inFrom]];
}


//-- sendWHOWAS
// WHOWASコマンドの送信 (servernameとcountが存在する場合は省略)
- (void) sendWHOWAS:(NSString*) inNick
{
    // WHOWAS command w/ nickname only
    [self sendCommand:[NSString stringWithFormat:@"%@ %@", kCommandWhowas, inNick]];
}

 
#pragma mark ･･･ Sending messages ･･･
//-- sendPRIVMSG
// PRIVMSGの送信
- (void) sendPRIVMSG:(NSString*)inMessage to:(NSString*)inChannelName
{
    IRCMessage* message;
    
    if([inMessage length] > 0){
        [self sendCommand:[NSString stringWithFormat:@"%@ %@ :%@", kCommandPrivmsg,
                                                            inChannelName, inMessage]];
    
        // local loopback
        message = [[IRCMessage alloc] initWithMessage:[NSString stringWithFormat:@":%@ %@ %@ :%@",
                        _nickname, kCommandPrivmsg, inChannelName, inMessage] server:[self serverid]];
        [self handleIRCMessage:message];
        [message release];
    }
}


//-- sendNotice:to:
// NOTICE messageを送信する
- (void) sendNotice:(NSString*)inMessage to:(NSString*)inChannelName
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@ :%@", kCommandNotice,
                                                inChannelName, inMessage]];
}


//-- sendAction:to:
// action messageを送信する
- (void) sendAction:(NSString*)inMessage to:(NSString*)inChannelName
{
	[self sendCtcpCommand:[NSString stringWithFormat:@"ACTION %@", inMessage]
					   to:inChannelName]; 

	// local loopback
	IRCMessage* message = [[[IRCMessage alloc] initWithMessage:
		[NSString stringWithFormat:@":%@ %@ %@ :\1ACTION %@\1",
		_nickname, kCommandPrivmsg, inChannelName, inMessage] server:[self serverid]] autorelease];
	[self handleIRCMessage:message];
}




@end
