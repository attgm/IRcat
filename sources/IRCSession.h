//
//  $RCSfile: IRCSession.h,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Foundation/Foundation.h>

#import "TCPConnection.h"
#import "IRCMessage.h"
#import "IRcatConstants.h"


@interface IRCSession : NSObject <Session> {
    TCPConnection *_connection;
    
    NSString* _nickname;

    NSDictionary* _config;
    NSInteger _serverid;
    id	_interface;
	
	SessionCondition _sessionCondition;
	Class _encodingFilter;
	
	NSTimeInterval	_pingInterval;
	NSDate*	_prevousPing;
	NSTimer* _sessionTimer;
	
	
}


-(id) initWithConfig:(NSDictionary*)inConfig interface:(id)inInterface identify:(NSInteger)inID;
       
-(void) connect;
-(NSInteger) serverid;
-(NSString*)nickname;
-(NSString*)name;
-(NSString*)label;
-(SessionCondition) sessionCondition;

-(void) handleIncommingData : (NSData*)inIncommingData;
-(void) handleConnected;
-(void) handleRegistered;
-(void) handleDisconnect;
-(void) handleConnectionError:(int) inErrorCode;

-(void) sendCommand:(NSString*)command immediately:(BOOL)immediate;
-(void) sendCommand:(NSString*)inCommand;

-(void) setNickname:(NSString*)inNewNick;

-(BOOL) isConnected;


@end


#pragma mark -
@interface IRCSession(send)
-(void) sendPASS:(NSString*)inPassword;
-(void) sendNICK:(NSString*)inNickname;
-(void) sendUSER:(NSString*)inUsername server:(NSString*)inServername realname:(NSString*)inRealname;

-(void) sendJOIN:(NSString*)inChannelName password:(NSString*)inPassword;
-(void) sendPART:(NSString*)inChannelName message:(NSString*)inMessage;
-(void) sendTOPIC:(NSString*)inTopic to:(NSString*)inChannel;
 
//-- sendPART:message:
-(void) sendPONG:(NSString*)inFrom;
-(void) sendPRIVMSG:(NSString*)inMessage to:(NSString*)inChannelName;
-(void) sendNotice:(NSString*)inMessage to:(NSString*)inChannelName;
-(void) sendQUIT:(NSString*)inMessage;
-(void) sendWHOIS:(NSString*)inNick;
-(void) sendWHOWAS:(NSString*)inNick;
-(void) sendModeRequest:(NSString*)inChannelName;
-(void) sendMODE:(NSString*)inMode to:(NSString*)inChannelName;
-(void) sendCtcpCommand:(NSString*)inCommand to:(NSString*)inNickOrChannel;
-(void) sendAction:(NSString*)inMessage to:(NSString*)inChannelName;
-(void) sendINVITE:(NSString*)inNick to:(NSString*)inChannel;

@end

#pragma mark -
@interface IRCSession(Handle)
-(void) handleIRCMessage:(IRCMessage*)inCommand;
-(void) handleCommandMessage:(IRCMessage*)inMessage;
-(void) handleReplyMessage:(IRCMessage*)inMessage;

-(void) handlePing:(IRCMessage*)inMessage;
-(void) handlePrivmsg:(IRCMessage*)inMessage;
-(void) handlePrivateMessage:(IRCMessage*)inMessage;
-(void) handleNotice:(IRCMessage*)inMessage;
-(void) handleCtcpCommand:(IRCMessage*)inMessage; 
-(void) handleCtcpReply:(IRCMessage*)inMessage; 
-(void) handleJoin:(IRCMessage*)inMessage;
-(void) handlePart:(IRCMessage*)inMessage;
-(void) handleTopic:(IRCMessage*)inMessage;
-(void) handleQuit:(IRCMessage*)inMessage;
-(void) handleInvite:(IRCMessage*)inMessage;
-(void) handleKick:(IRCMessage*)inMessage;
-(void) handleNick:(IRCMessage*)inMessage;
-(void) handleSQuit:(IRCMessage*)inMessage;
-(void) handleObject:(IRCMessage*)inMessage;
-(void) handleMode:(IRCMessage*)inMessage;
-(void) handleError:(IRCMessage*)inMessage;

-(void) handleNamesReply:(IRCMessage*)inMessage;
-(void) handleNamesEndReply:(IRCMessage*)inMessage;
-(void) handleNamesTopicReply:(IRCMessage*)inMessage;
-(void) handleTopicReply:(IRCMessage*)inMessage;
-(void) handleNoSuchNickError:(IRCMessage*)inMessage;
-(void) handleNickInUseError:(IRCMessage*)inMessage;
-(void) handleChannelModeReply:(IRCMessage*)inMessage;
-(void) handleBadChannelKey:(IRCMessage*)inMessage;

-(void) handleInternalMessage:(NSString*)inMessage;
-(void) handleInternalError:(NSString*)inMessage;
-(BOOL) isMyself:(NSString*)inString;
-(void) handleChannelMode:(IRCMessage*)inMessage at:(int)inStartParam for:(NSString*)inChannel;
@end
