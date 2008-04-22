//
//  $RCSfile: ServersModal.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Foundation/Foundation.h>
@class ServerModal;

@interface ServersModal : NSObject {
	NSMutableArray* _serverList;
	NSIndexSet*	_selectedIndexes;
}

- (id) init;
+ (ServersModal*) sharedServersModal;

+ (int) bookIdentifier;
- (ServerModal*) serverForID:(int) inIdentifier;
- (ServerModal*) selectedServerModal;

- (NSArray*) serverList;
- (void) removeServer;
- (void) preferencesFromDefaults;
- (void) savePreferencesToDefaults;

@end
