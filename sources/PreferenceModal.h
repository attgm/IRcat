//
//  $RCSfile: PreferenceModal.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>
#import "PreferenceHeader.h"

@interface PreferenceModal : NSObject {
 	NSMutableDictionary* _preferences;
}

+(PreferenceModal*) sharedPreference;
+(id) prefForKey:(NSString*) key;
+(NSColor*) colorForKey:(NSString*) key;
+(NSColor*) transforColorNameToColor:(NSString*) value;
+(NSArray*) soundArray;
+(NSDictionary*) searchFriend:(NSString*) nick;

-(void) setValue:(id) value forKey:(NSString*) key;
-(id) valueForKey:(NSString*) key;


- (void) preferencesFromDefaults;
- (void) savePreferencesToDefaults;

-(NSMutableArray*) mutableArrayFromArray:(NSArray*) array;

@end
