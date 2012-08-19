//
//  FontWell.h
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import <Cocoa/Cocoa.h>

@interface FontWell : NSButton <NSWindowDelegate>
{
	NSFont* _fontwellValue;
	
	id _observedControllerForValue;
	NSString* _observedKeyPathForValue;
	NSString* _valueTransformerName;
}

-(void) activate;
-(void) deactivate;
-(void) updateFontValue:(NSFont*)font;


-(void) syncValueToController;

-(void) setObservedControllerForValue:(id)controller;
-(void) setObservedKeyPathForValue:(NSString*)keypath;
-(void) setValueTransformerName:(NSString*)name;

@end
