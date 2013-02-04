//
//  $RCSfile: BindingItem.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "BindingItem.h"

@implementation BindingItem

@synthesize observedController = _observedController;
@synthesize observedKeyPath = _observedKeyPath;
@synthesize transformerName = _transformerName;
@synthesize identifier = _identifier;
@synthesize selector = _selector;
@synthesize valueClass = _valueClass;

#pragma mark Initializing
//-- init
-(id) init
{
	self = [super init];
    if(self != nil){
        _observedController = _observedKeyPath = _transformerName = nil;
	}
    return self;
}


//-- initWithSelector:valueClass:
-(id) initWithSelector:(SEL) selector
			valueClass:(Class) valueClass
			identifier:(NSString*) identifier
{
	self = [super init];
    if(self != nil){
		_observedController = _observedKeyPath = _transformerName = nil;
		_selector = selector;
		_valueClass = valueClass;
		_identifier = identifier;
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
							   identifier: (NSString*) identifier
{
	return [[[BindingItem alloc] initWithSelector:selector
									   valueClass:valueClass
									   identifier:identifier] autorelease];
}


#pragma mark Interface
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
