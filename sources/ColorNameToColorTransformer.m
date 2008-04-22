//
//  $RCSfile: ColorNameToColorTransformer.m,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ColorNameToColorTransformer.h"
#import "PreferenceModal.h"

@implementation ColorNameToColorTransformer

//-- transformedValueClass
//
+ (Class) transformedValueClass
{
	return [NSColor class];
}


//-- allowsReverseTransformation
//
+ (BOOL) allowsReverseTransformation
{
	return YES;
}


//-- transformedValue
// transfer fontname to NSColor
- (id) transformedValue:(id)value
{
	if (value == nil) return nil;
	
	NSString* colorName = nil;
	if([value respondsToSelector:@selector(stringValue)]) {
		colorName = [value stringValue];
	}else if([value isKindOfClass:[NSString class]]){
		colorName = value;
	}else{
		[NSException raise: NSInternalInconsistencyException
                    format: @"Value (%@) does not respond to -stringValue.", [value className]];
	}	
	return [PreferenceModal transforColorNameToColor:colorName];
}



//-- reverseTransformedValue
// reverse-transfer NSColor to font
- (id) reverseTransformedValue:(id) value
{
	if (value == nil || ![value isKindOfClass:[NSColor class]]) return nil;
	
	float red, green, blue, alpha;
	[value getRed:&red green:&green blue:&blue alpha:&alpha];
    
	return [NSString stringWithFormat:@"%f %f %f 1.0", red, green, blue];
}

@end
