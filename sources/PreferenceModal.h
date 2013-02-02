//
//  $RCSfile: PreferenceModal.h,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>
#import "PreferenceConstants.h"

@interface PreferenceModal : NSObject {
 	NSMutableDictionary* _preferences;
}

+(PreferenceModal*) sharedPreference;
+(id) prefForKey:(NSString*) key;
+(NSColor*) colorForKey:(NSString*) key;
+(NSColor*) transforColorNameToColor:(NSString*) value;
+(NSDictionary*) notificationForType:(NSString*) type;
+(NSDictionary*) searchFriend:(NSString*) nick;
+(NSArray*) soundArray;

-(void) setValue:(id) value forKey:(NSString*) key;
-(id) valueForKey:(NSString*) key;


- (void) preferencesFromDefaults;
- (void) savePreferencesToDefaults;

-(NSMutableArray*) mutableArrayFromArray:(NSArray*)array keys:(id)key;

+(void) setSecurityBookmark:(NSData*)bookmark forPath:(NSString*)path;
+(NSURL*) securityBookmarkForPath:(NSString*)path;

@end
