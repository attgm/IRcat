//
//  $RCSfile: ConsoleModal.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//


#import <Cocoa/Cocoa.h>
#import "ChannelModal.h"

@interface ConsoleModal : ChannelModal {
	NSMutableArray* _sessionList;
}

- (id) initWithName:(NSString*) inChannelName
           identify:(int) inChannelID
             server:(int) inServerID;
- (void) dealloc;


-(void) setSessionList:(NSMutableArray*) inArray;

@end
