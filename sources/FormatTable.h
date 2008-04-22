//
//  $RCSfile: FormatTable.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import <Foundation/Foundation.h>
#import "FormatItem.h"

@interface FormatTable : NSObject {
    NSMutableDictionary* _hashTable;
}

-(id) init;
-(void) dealloc;

-(void) initFormatTable;
-(FormatItem*) dataForKey:(NSString*)inKey;
@end
