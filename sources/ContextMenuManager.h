//
//  $RCSfile: ContextMenuManager.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>

@class ChannelModal;

@interface ContextMenuManager : NSObject {
	NSDictionary* _menus;
}

- (id) init;
+ (ContextMenuManager*) sharedManager;
- (NSMenu*) createMenuForID:(NSString*) inKey
					  state:(BOOL) inMulti
					 action:(SEL) inSelector
					 target:(id) inTarget;
+ (NSString*) expandFormat : (NSString*) inFormat
					 param : (NSArray*) inParam
					context: (ChannelModal*)inChannel;
@end
