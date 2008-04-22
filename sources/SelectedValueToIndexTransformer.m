//
//  SelectedValueToIndexTransformer.m
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "SelectedValueToIndexTransformer.h"
#import "PreferenceModal.h"

@implementation SelectedValueToIndexTransformer

//-- transformedValueClass
//
+ (Class) transformedValueClass
{
	return [NSNumber class];
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
	
	NSString* title = nil;
	if([value respondsToSelector:@selector(stringValue)]) {
		title = [value stringValue];
	}else if([value isKindOfClass:[NSString class]]){
		title = value;
	}else if([value isKindOfClass:[NSNumber class]]){
		return value;
	}else{
		[NSException raise: NSInternalInconsistencyException
                    format: @"Value (%@) does not respond to -stringValue.", [value className]];
	}
	
	NSArray* array = [PreferenceModal soundArray];
	int i;
	for(i=0; i<[array count]; i++){
		if([title isEqualToString:[array objectAtIndex:i]]){
			return [NSNumber numberWithInt:i];
		}
	}
	return [NSNumber numberWithInt:0];
}



//-- reverseTransformedValue
// reverse-transfer NSColor to font
- (id) reverseTransformedValue:(id) value
{
	if (value == nil || ![value respondsToSelector:@selector(intValue)]) return nil;
	
	NSArray* array = [PreferenceModal soundArray];
	int index = [value intValue];
	if(index >= 0 && index < [array count]){
		return	[array objectAtIndex:index];
	}else{
		return [array objectAtIndex:0];
	}
}

@end
