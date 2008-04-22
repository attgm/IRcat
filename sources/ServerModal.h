//
//  $RCSfile: ServerModal.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>


@interface ServerModal : NSObject {
	NSMutableDictionary* _parameters;
}

-(id) init;
-(id) initWithDictionary:(NSDictionary*) dic;
+(ServerModal*) serverModal;
+(ServerModal*) serverModalWithDictionary:(NSDictionary*) dic;
-(void) dealloc;

+(int) bookIdentifier;
-(void) initializeDictionary:(NSDictionary*) dic;
-(NSMutableArray*) mutableArrayFromArray:(NSArray*) array;

-(NSDictionary*) parameters;
-(void) setValue:(id) value forKey:(NSString*) key;
-(id) valueForKey:(NSString*) key;

-(BOOL) isValidParameter;


@end
