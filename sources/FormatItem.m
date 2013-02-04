//
//  $RCSfile: FormatItem.m,v $
//
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "FormatItem.h"


@implementation FormatItem

@synthesize format = _format;
@synthesize commonFormat = _commonFormat;
@synthesize appendFormat = _appendFormat;
@synthesize displayPlace = _displayPlace;
@synthesize channelPosition = _channelPosition;


//-- initWithParams:
// 初期化
- (id) initWithParams:(NSString*)format
                     :(NSString*)common
                     :(NSString*)append
                     :(InsertPlace)where
                     :(int)channel
{
	self = [super init];
	if(self){
        _format = [format copyWithZone:[self zone]];
        _commonFormat = [common copyWithZone:[self zone]];
        _appendFormat = [append copyWithZone:[self zone]];
        _displayPlace = where;
        _channelPosition = channel;
	}
    return self;}


//-- dealloc
// 破棄
- (void) dealloc
{
	[_format release];
	[_commonFormat release];
	[_appendFormat release];
	[super dealloc];
}


//-- formatWithFormat
// 初期化
+ (id) formatWithFormat:(NSDictionary*)format
{
	return [[[FormatItem alloc] initWithParams:[format objectForKey:@"format"]
											  :[format objectForKey:@"commonFormat"]
											  :[format objectForKey:@"appendFormat"]
											  :[[format objectForKey:@"displayPlace"] intValue]
											  :[[format objectForKey:@"channelPosition"] intValue]] autorelease];
}
@end
