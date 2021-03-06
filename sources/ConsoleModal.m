//
//  $RCSfile: ConsoleModal.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ConsoleModal.h"
#import "IRcatConstants.h"
#import "NickListItem.h"
#import "IRCSession.h"

@implementation ConsoleModal

//-- initWithName:identify:server
// いろいろ設定
- (id) initWithName:(NSString*) inChannelName
           identify:(NSInteger) inChannelID
             server:(NSInteger) inServerID
{
	self = [super initWithName:inChannelName identify:inChannelID server:inServerID];
	return self;
}


//-- dealloc
// 後片付け
- (void) dealloc
{
	[_sessionList release];
	[super dealloc];
}


//-- setSessionList
// session listを設定
-(void) setSessionList:(NSMutableArray*) inArray
{
	_sessionList = [inArray retain];
}


#pragma mark NSTableView (data source)
//-- numberOfRowsInTableView
// テーブルの行数を返す
- (NSInteger) numberOfRowsInTableView : (NSTableView*) aTableView
{
    return [_sessionList count];
}


//-- tableView:objectValueForTableColumn:row
// テーブルの内容を返す
-(id)				tableView : (NSTableView*) aTableView
    objectValueForTableColumn : (NSTableColumn*) aTableColumn
						  row : (NSInteger) rowIndex
{
	id identifier = [aTableColumn identifier];
	IRCSession* session = [_sessionList objectAtIndex:rowIndex];
	
    if([identifier isEqualToString:@"nick"]) {
		return [NSString stringWithFormat:@"%ld:%@", (long)[session serverid], [session name]];
    }else if([identifier isEqualToString:@"op"]) {
		return [NSImage imageNamed:[NSString stringWithFormat:@"server_%@", [session label]]];
    }else if([identifier isEqualToString:@"icon"]) {
		switch([session sessionCondition]){
			case IRSessionConditionConnecting:
				return [NSImage imageNamed:@"condition_connecting"];
				break;
			case IRSessionConditionRegistering:
				return [NSImage imageNamed:@"condition_registering"];
				break;
			case IRSessionConditionEstablished:
				return [NSImage imageNamed:@"condition_connected"];
				break;
			case IRSessionConditionDisconnected:
				return [NSImage imageNamed:@"condition_disconnected"];
				break;
		}
    }

	return @"-";
}


//-- arraySelected
// 選択済みのnickを返す
- (NSArray*) arraySelected:(NSIndexSet*) inSelected
{
	NSUInteger bufSize = [inSelected count];
	NSUInteger buf[bufSize];
	NSRange range = NSMakeRange([inSelected firstIndex], [inSelected lastIndex] - [inSelected firstIndex] + 1);
	
	NSUInteger num = [inSelected getIndexes:buf maxCount:bufSize inIndexRange:&range];
	NSMutableArray* nicks = [[[NSMutableArray alloc] initWithCapacity:num] autorelease];
	int i;
	for(i=0; i<num; i++){
		[nicks addObject:[NSString stringWithFormat:@"%ld", (long)[[_sessionList objectAtIndex:buf[i]] serverid]]];
	}
	return nicks;
}


//-- stringSelected
// 選択されたnickを返す
- (NSString*) stringSelected:(NSInteger) inIndex
{
	return [NSString stringWithFormat:@"%ld", (long)[[_sessionList objectAtIndex:inIndex] serverid]];
}

@end
