//
//  $RCSfile: FormatTable.m,v $
//
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "FormatTable.h"
#import "FormatItem.h"

@implementation FormatTable

//-- init
// format tableの初期化
- (id) init
{
    self = [super init];
    if(self){
    	[self initFormatTable];
    }
    return self;
}


//-- dealloc
//
- (void) dealloc
{
	[_hashTable release];
	[super dealloc];
}


//-- initFormatTable
// format tableの作成
- (void) initFormatTable
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"xml"];
	NSDictionary* formats = [[NSDictionary alloc] initWithContentsOfFile:path];
	NSEnumerator* e = [formats keyEnumerator];
	
	id key;
	_hashTable = [[NSMutableDictionary alloc] initWithCapacity:[formats count]];
    
	// format tableの生成
	while (key = [e nextObject]){
		[_hashTable setObject:[FormatItem formatWithFormat:[formats objectForKey:key]]
					   forKey:key];
    }
	[formats release];
}


//-- dataForKey
// keyのitemを検索する 見つからなかった場合はnilを返す
- (FormatItem*) dataForKey:(NSString*)inKey
{
    return [_hashTable objectForKey:inKey];
}

@end
