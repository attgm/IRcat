//
//  SelectedValueToIndexTransformer.h
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>


@interface SelectedValueToIndexTransformer : NSObject {

}

+ (Class) transformedValueClass;
+ (BOOL) allowsReverseTransformation;
- (id) transformedValue:(id)value;
- (id) reverseTransformedValue:(id) value;


@end
