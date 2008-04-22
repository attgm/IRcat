//
//  $RCSfile: FontNameToFontTransformer.m,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "FontNameToFontTransformer.h"


@implementation FontNameToFontTransformer


//-- transformedValueClass
//
+ (Class) transformedValueClass
{
	return [NSFont class];
}


//-- allowsReverseTransformation
//
+ (BOOL) allowsReverseTransformation
{
	return YES;
}


//-- transformedValue
// transfer fontname to NSFont
- (id) transformedValue:(id)value
{
	if (value == nil) return nil;
	
	NSString* valueString = nil;
	if ([value respondsToSelector:@selector(stringValue)]) {
		valueString = [value stringValue];
	}else if([value isKindOfClass:[NSString class]]){
		valueString = value;
	}else{
		return [NSFont systemFontOfSize:0.0];
		
		//[NSException raise: NSInternalInconsistencyException
        //            format: @"Value (%@) does not respond to -stringValue.", [value className]];
	}
	
	NSArray* fontTable = [valueString componentsSeparatedByString:@" "];
	if([fontTable count] == 2){
		return [NSFont fontWithName:[fontTable objectAtIndex:0]
							   size:[[fontTable objectAtIndex:1] floatValue]];
	}else{
		return [NSFont systemFontOfSize:0.0];
	}
}


//-- reverseTransformedValue
// reverse-transfer NSFont to font
- (id) reverseTransformedValue:(id) value
{
	if (value == nil) return nil;
	return [NSString stringWithFormat:@"%@ %.0f", [value fontName], [value pointSize]];
}

@end
