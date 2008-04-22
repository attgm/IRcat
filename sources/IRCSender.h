//
//  $RCSfile: IRCSender.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Foundation/Foundation.h>


@interface IRCSender : NSObject {

}

-(void) sendPASS:(NSString*) inPassword;
-(void) sendNICK:(NSString*) inNickname;
-(void)  sendUSER:(NSString*) inUsername
		   server:(NSString*) inServername
		 realname:(NSString*) inRealname;

-(void) sendJOIN:(NSString*) inChannelName
		password:(NSString*) inPassword;
-(void) sendPART:(NSString*)inChannelName message:(NSString*)inMessage;
-(void) sendTOPIC:(NSString*) inTopic to:(NSString*) inChannel;

	 //-- sendPART:message:
-(void) sendPONG:(NSString*) inFrom;
-(void) sendPRIVMSG:(NSString*)inMessage to:(NSString*)inChannelName;
-(void) sendNotice:(NSString*) inMessage to:(NSString*) inChannelName;
-(void) sendQUIT:(NSString*) inMessage;
-(void) sendWHOIS:(NSString*) inNick;
-(void) sendWHOWAS:(NSString*)inNick;
-(void) sendModeRequest:(NSString*)inChannelName;
-(void) sendMODE:(NSString*) inMode to:(NSString*) inChannelName;
-(void) sendCtcpCommand:(NSString*) inCommand to:(NSString*) inNickOrChannel;
-(void) sendAction:(NSString*)inMessage to:(NSString*)inChannelName;
-(void) sendINVITE:(NSString*)inNick to:(NSString*) inChannel;

-(void) sendCommand:(NSString*) inCommand;

@end
