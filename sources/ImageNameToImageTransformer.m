//
//  $RCSfile: ImageNameToImageTransformer.m,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ImageNameToImageTransformer.h"


@implementation ImageNameToImageTransformer

//-- transformedValueClass
// 
+(Class) transformedValueClass
{
	return [NSImage class];
}


//-- allowsReverseTransformation
//
+(BOOL) allowsReverseTransformation
{
	return NO;
}


//-- transformedValue
//
-(id) transformedValue:(id)value
{
	if (value == nil) return nil;
	
	return [NSImage imageNamed:value];
}

@end
