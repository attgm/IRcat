//
//  $RCSfile: IRCSender.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "IRCSender.h"


@implementation IRCSender

#pragma mark ･･･  ･･･
//-- sendPRIVMSG
// PRIVMSGの送信
- (void) sendPRIVMSG:(NSString*)inMessage to:(NSString*)inChannelName
{
    IRCMessage* message;
    
    if([inMessage length] > 0){
        [self sendCommand:[NSString stringWithFormat:@"%@ %@ :%@", kCommandPrivmsg,
			inChannelName, inMessage]];
		
        // local loopback
        message = [[[IRCMessage alloc] initWithMessage:[NSString stringWithFormat:@":%@ %@ %@ :%@",
			mNickname, kCommandPrivmsg, inChannelName, inMessage] server:[self serverid]] autorelease];
        [self handleIRCMessage:message];
    }
}


//-- sendNotice:to:
// NOTICE messageを送信する
- (void) sendNotice:(NSString*)inMessage to:(NSString*)inChannelName
{
    [self sendCommand:[NSString stringWithFormat:@"%@ %@ :%@", kCommandNotice,
		inChannelName, inMessage]];
}


//-- sendCommand
// command messageを送信する
- (void) sendCommand:(NSString*)inCommand
{
    NSData* data;
    
    // JISへ漢字コードを変換する．
    if([PreferenceModal prefForKey:kUseJISCode] == ){
#ifdef IRCAT_DEBUG
		NSLog(@"...%@", inCommand);
#endif
    //data = [NSData dataWithBytes:[inCommand cString] length:[inCommand cStringLength]];
    data = [inCommand dataUsingEncoding:NSISO2022JPStringEncoding];
    
    //}else{
    //    UString::Copy(jisString,inString);
    //}
	
	//+2 is overhead for CRLF
	//	other routines have probably check this already, but it couldn't hurt
    if(![mConnection sendData:data]){
        NSLog(@"Connection is closed. can't send message:%@", inCommand);
    }
}

@end
