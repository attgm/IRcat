//
//  IsKeywordEventTransformation.m
//  ircat
//

#import "IsKeywordEventTransformer.h"
#import "PreferenceConstants.h"

@implementation IsKeywordEventTransformer

+(Class) transformedValueClass
{
	return [NSNumber class];
}


+(BOOL) allowsReverseTransformation
{
	return NO;
}


-(id) transformedValue:(id)value
{
    
	if (value == nil) return [NSNumber numberWithBool:YES];
    
    if ([value isKindOfClass:[NSString class]]){
		return [NSNumber numberWithBool:([value isEqualToString:IRNotificationTypeKeyword] ? NO : YES)];
    }else{
		return [NSNumber numberWithBool:YES];
	}
}


@end
