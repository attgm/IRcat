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
	
	id          _observedController;
	NSString*	_observedKeyPath;
	NSString*   _transformerName;
	NSString*   _identifier;
}


@property (retain) id observedController;
@property (retain) NSString* observedKeyPath;
@property (retain) NSString* transformerName;
@property (readonly) NSString* identifier;
@property (readonly) SEL selector;
@property (readonly) Class valueClass;

+(BindingItem*) bindingItemFromSelector : (SEL) selector
							 valueClass : (Class) valueClass
							  identifier: (NSString*) identifier;

-(id) init;
-(id) initWithSelector : (SEL) selector
			valueClass : (Class) valueClass
			 identifier: (NSString*) identifier;
-(void) dealloc;

-(NSDictionary*) infoForBinding;
-(void) unbind;


@end
