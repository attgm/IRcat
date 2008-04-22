//
//  $RCSfile: FormatItem.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "FormatItem.h"


@implementation FormatItem

//-- initWithParams:
// ������
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
// �j��
- (void) dealloc
{
	[_format release];
	[_commonFormat release];
	[_appendFormat release];
	[super dealloc];
}


//-- formatWithFormat
// ������
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
// ���C���t�H�[�}�b�g
- (NSString*) format
{
	return _format;
}

//-- commonFormat
// ����view�ɕ\��������format
- (NSString*) commonFormat
{
	return _commonFormat;
}


//-- appendFormat
// �ǉ�������p�t�H�[�}�b�g
- (NSString*) appendFormat
{
	return _appendFormat;
}


//-- displayPlace
// �\���ꏊ
- (int) displayPlace
{
	return _displayPlace;
}


//-- channelPosition
// �`�����l��������ꏊ
- (int) channelPosition
{
	return _channelPosition;
}

@end
