//
//  $RCSfile: BindingItem.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>


@interface BindingItem : NSObject {
	SEL		_selector;
	Class	_valueClass;
	
	id	_observedController;
	NSString*	_observedKeyPath;
	NSString*	_transformerName;
	void*	_identifier;
}

+(BindingItem*) bindingItemFromSelector : (SEL) selector
							 valueClass : (Class) valueClass
							  identifier: (const void*) identifier;

-(id) init;
-(id) initWithSelector : (SEL) selector
			valueClass : (Class) valueClass
			 identifier: (const void*) identifier;
-(void) dealloc;

-(Class) valueClass;
-(SEL) selector;

-(void*) identifier;
-(id) observedController;
-(void) setObservedController:(id) controller;
-(NSString*) observedKeyPath;
-(void) setObservedKeyPath:(NSString*) keyPath;
-(NSString*) transformerName;
-(void) setTransformerName:(NSString*) transformerName;
-(NSDictionary*) infoForBinding;
-(void) unbind;

@end
