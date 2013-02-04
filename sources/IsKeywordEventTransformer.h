//
//  IsKeywordEventTransformation.h
//  ircat
//


#import <Foundation/Foundation.h>

@interface IsKeywordEventTransformer : NSValueTransformer

+(Class) transformedValueClass;
+(BOOL) allowsReverseTransformation;
-(id) transformedValue:(id)value;

@end
