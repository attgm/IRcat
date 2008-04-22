//
//  $RCSfile: FormatItem.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "FormatItem.h"


@implementation FormatItem

//-- initWithParams:
// 初期化
- (id) initWithParams:(NSString*)format
							  :(NSString*)common
							  :(NSString*)append
							  :(int)where
							  :(int)channel
{
	[super init];
	
	_format = [format copyWithZone:[self zone]];
	_commonFormat = [common copyWithZone:[self zone]];
	_appendFormat = [append copyWithZone:[self zone]];
	_displayPlace = where;
	_channelPosition = channel;
	return self;
}


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

#pragma mark -

//-- format
// メインフォーマット
- (NSString*) format
{
	return _format;
}

//-- commonFormat
// 共通viewに表示させるformat
- (NSString*) commonFormat
{
	return _commonFormat;
}


//-- appendFormat
// 追加文字列用フォーマット
- (NSString*) appendFormat
{
	return _appendFormat;
}


//-- displayPlace
// 表示場所
- (int) displayPlace
{
	return _displayPlace;
}


//-- channelPosition
// チャンネルがある場所
- (int) channelPosition
{
	return _channelPosition;
}

@end
