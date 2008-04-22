//
//  $RCSfile: ImageNameToImageTransformer.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ImageNameToImageTransformer.h"


@implementation ImageNameToImageTransformer

+ (Class) transformedValueClass
{
	return [NSImage class];
}


+ (BOOL) allowsReverseTransformation
{
	return NO;
}


- (id) transformedValue:(id)value
{
	if (value == nil) return nil;
	
	return [NSImage imageNamed:value];
}

@end
