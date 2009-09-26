//
//  $RCSfile: IsEmptyStringTransformer.m,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "IsEmptyStringTransformer.h"

@implementation IsEmptyStringTransformer

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
	if (value == nil) return [NSNumber numberWithBool:NO];
	if ([value isKindOfClass:[NSString class]]){
		return [NSNumber numberWithBool:([value length] == 0 ? NO : YES)];
	}else{
		return [NSNumber numberWithBool:YES];
	}
}

@end
