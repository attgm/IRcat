//
//  $RCSfile: ColorNameToColorTransformer.h,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>


@interface ColorNameToColorTransformer : NSValueTransformer {

}

+(Class) transformedValueClass;
+(BOOL) allowsReverseTransformation;
-(id) transformedValue:(id)value;
-(id) reverseTransformedValue:(id)value;


@end
