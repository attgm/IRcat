//
//  $RCSfile: ServerModal.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ServerModal.h"


static NSDictionary *defaultValues()
{
    static NSDictionary *defaults = nil;
    
    if(!defaults){
        defaults = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSNumber numberWithBool:NO], @"invisibleMode",
			@"blue", @"serverLabel",
            @"", @"password",
            @"6667", @"port",
            @"", @"address",
            @"", @"mailAddress",
            @"", @"realName",
            @"", @"nick",
            [NSMutableArray arrayWithCapacity:8], @"autoJoinChannels",
            @"default", @"name",
			@"ISO-2022-JP", @"encoding",
			[NSNumber numberWithBool:NO], @"connectAtStartup",
            nil];
    }
    return defaults;
};



static NSDictionary *defaultKeys()
{
    static NSDictionary *defaults = nil;
    
    if(!defaults){
        defaults = [[NSDictionary alloc] initWithObjectsAndKeys:
					[NSArray arrayWithObjects:@"name", @"password", nil], @"autoJoinChannels",
					nil];
    }
    return defaults;
};


static NSDictionary *preferenceConverter()
{
	static NSDictionary *preferenceConverter = nil;
    
    if(!preferenceConverter){
        preferenceConverter = [[NSDictionary alloc] initWithObjectsAndKeys:
			@"InvisibleMode", @"invisibleMode",
			@"Label", @"serverLabel",
            @"Password", @"password",
			@"Port", @"port",
            @"Address", @"address",
            @"MailAddress", @"mailAddress",
            @"RealName", @"realName",
			@"Nick", @"nick",
            @"AutoJoinChannels", @"autoJoinChannels",
			@"Name", @"name",
			@"Encoding", @"encoding",
            nil];
    }
    return preferenceConverter;
}


@implementation ServerModal


#pragma mark allocator

//-- init
//
-(id) init
{
	self = [super init];
	if(self != nil){
		_parameters = [[NSMutableDictionary alloc] init];
		[self initializeDictionary:nil];
	}
	return self;
}


//-- initWithDictionary
//
-(id) initWithDictionary:(NSDictionary*) dic
{
	self = [super init];
	if(self != nil){
		_parameters = [[NSMutableDictionary alloc] init];
		[self initializeDictionary:dic];
	}
	return self;
}


//-- dealloc
//
-(void) dealloc
{
	[_parameters release];
	[super dealloc];
}


//-- serverModal
+(ServerModal*) serverModal
{
	return [[[ServerModal alloc] init] autorelease];
}

//-- initWithDictionary
//
+(ServerModal*) serverModalWithDictionary:(NSDictionary*) dic
{
	return [[[ServerModal alloc] initWithDictionary:dic] autorelease];
}


//-- initializeDictionary
//
-(void) initializeDictionary:(NSDictionary*) dic
{
	NSDictionary* defaluts = defaultValues();
	NSDictionary* converter = preferenceConverter();
	NSDictionary* keys = defaultKeys();
	
	NSEnumerator* e = [defaluts keyEnumerator];
	id key;
	while(key = [e nextObject]){
		id value = [dic objectForKey:key];
		if(!value){
			id oldKey = [converter objectForKey:key];
			value = [dic objectForKey:oldKey];
			if(!value){
				value = [defaluts objectForKey:key];
			}
		}
		
		if([value isKindOfClass:[NSArray class]]){
			[_parameters setObject:[self mutableArrayFromArray:value keys:[keys objectForKey:key]] forKey:key];
		}else{
			[_parameters setObject:value forKey:key];
		}
	}
	[_parameters setObject:[NSNumber numberWithInt:[ServerModal bookIdentifier]] forKey:@"id"];	
}


//-- mutableArrayFromArray
//
-(NSMutableArray*) mutableArrayFromArray:(NSArray*) array keys:(id)key
{
	NSEnumerator* e = [array objectEnumerator];
	NSMutableArray* copy = [NSMutableArray arrayWithCapacity:[array count]];
	id it;
	while(it = [e nextObject]){
		id item;
		if([it isKindOfClass:[NSDictionary class]]){
			item = [[it mutableCopy] autorelease];
		}else{
			item = [NSMutableDictionary dictionaryWithObject:[[it copyWithZone:[self zone]] autorelease] forKey:@"name"];
		}
		if(key && [key isKindOfClass:[NSArray class]]){
			NSEnumerator* e = [key objectEnumerator];
			id paramator;
			while(paramator = [e nextObject]){
				if([item objectForKey:paramator] == nil){
					[item setObject:@"" forKey:paramator];
				}
			}
		}
		[copy addObject:item];
	}
	return copy;
}


//-- isValidParameter
-(BOOL) isValidParameter
{
	static NSArray* examParam = nil;
	if(!examParam){
		examParam = 
			[[NSArray alloc] initWithObjects:@"port", @"address", @"mailAddress", @"realName", @"nick", nil];
	}
	NSEnumerator* e = [examParam objectEnumerator];
	BOOL valid = YES;
	id key;
	while((key = [e nextObject])){
		id value = [_parameters objectForKey:key];
		if(value == nil || ([value isKindOfClass:[NSString class]] && [value length] == 0)){
			valid = NO;
		}
	}
	return valid;
}

#pragma mark -

//-- bookIdentifier
// book server id
+ (int) bookIdentifier
{
	static int sServerIdentifier = 1;
	return sServerIdentifier++;
}



#pragma mark Bindings Interface

//-- setValue:forKey
//
-(void) setValue:(id) value
		  forKey:(NSString*) key
{
	BOOL valid = [self isValidParameter];
	id newValue = value ? value : @"";
	[self willChangeValueForKey:key];
	[_parameters setObject:newValue forKey:key];
    [self didChangeValueForKey:key];
	
	if(valid != [self isValidParameter]){
		[self willChangeValueForKey:@"serverIconLabel"];
		[self didChangeValueForKey:@"serverIconLabel"];
	}
}


//-- valueForKey
// bindで利用するパラメタを返す
-(id) valueForKey:(NSString*) key
{
	if([key isEqualToString:@"serverIconLabel"]){
		return ([self isValidParameter]) ?
			[NSString stringWithFormat:@"server_%@", [_parameters objectForKey:@"serverLabel"]]
		: @"icon_warning.tiff"; 
	}else{
		return [_parameters objectForKey:key];
	}
}


#pragma mark Interface
//-- parameters
//
-(NSDictionary*) parameters
{
	return _parameters;
}


@end
