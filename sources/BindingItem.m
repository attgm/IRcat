//
//  $RCSfile: BindingItem.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "BindingItem.h"





@implementation BindingItem

#pragma mark Initializing
//-- init
-(id) init
{
	[super init];
	_observedController = _observedKeyPath = _transformerName = nil;
	return self;
}


//-- initWithSelector:valueClass:
-(id) initWithSelector:(SEL) selector
			valueClass:(Class) valueClass
			identifier:(const void*) identifier
{
	[super init];
	if(self){
		_observedController = _observedKeyPath = _transformerName = nil;
		_selector = selector;
		_valueClass = valueClass;
		_identifier = (void*) identifier;
	}
	return self;
}


//-- dealloc
-(void) dealloc
{
	[_observedController release];
	[_observedKeyPath release];
	[_transformerName release];
	[super dealloc];
}


//-- bingindItemFromSelector:valueClass:identifier:
//
+ (BindingItem*) bindingItemFromSelector : (SEL) selector
							  valueClass : (Class) valueClass
							   identifier: (const void*) identifier
{
	return [[[BindingItem alloc] initWithSelector:selector
									   valueClass:valueClass
									   identifier:identifier] autorelease];
}


#pragma mark Interface
//-- selector
//
-(SEL) selector
{
	return _selector;
}

//-- valueClass
//
-(Class) valueClass
{
	return _valueClass;
}


//-- identifier
//
-(void*) identifier
{
	return _identifier;
}


//-- observedController
//
-(id) observedController
{
	return _observedController;
}


//-- setObservedController
//
-(void) setObservedController:(id) controller
{
	[_observedController release];
	_observedController = [controller retain];
}


//-- observedKeyPath
//
-(NSString*) observedKeyPath
{
	return _observedKeyPath;
}



//-- observedKeyPath
//
-(void) setObservedKeyPath:(NSString*) keyPath
{
	[_observedKeyPath release];
	_observedKeyPath = [keyPath copyWithZone:[self zone]];
}


//-- transformerName
//
-(NSString*) transformerName
{
	return _transformerName;
}


//-- setTransformerName
//
-(void) setTransformerName:(NSString*) transformerName
{
	[_transformerName release];
	_transformerName = [transformerName copyWithZone:[self zone]];
}


//-- infoForBinding
//
-(NSDictionary*) infoForBinding
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
		_observedController,	NSObservedObjectKey,
		_observedKeyPath,	NSObservedKeyPathKey, 
		[NSDictionary dictionaryWithObject:_transformerName forKey:@"NSValueTransformerName"], NSOptionsKey,
		nil];
}

//-- unbind
// 
- (void) unbind
{
	[self setObservedController:nil];
	[self setObservedKeyPath:nil];
	[self setTransformerName:nil];
}

@end
