//
//  $RCSfile: ServersModal.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ServersModal.h"
#import "ServerModal.h"

#import "PreferenceConstants.h"



@implementation ServersModal

static int sServerIdentifier			= 1;
static ServersModal *sSharedInstance	= nil;

//-- init
// 初期化ルーチン
- (id) init
{
    [super init];
	if(self){
        [self preferencesFromDefaults];
	}
    return self;
}


//-- sharedServersModal
//
+ (ServersModal*) sharedServersModal
{
	if(!sSharedInstance){
		sSharedInstance = [[ServersModal alloc] init];
	}
	return sSharedInstance;
}


//-- bookIdentifier
// server idを取得する
+ (int) bookIdentifier
{
	return sServerIdentifier++;
}


//-- serverid 
// サーバIDを返す
- (ServerModal*) selectedServerModal
{
	unsigned int index = [_selectedIndexes firstIndex];
	return [_serverList objectAtIndex:index];
}




#pragma mark Interface
//-- serverList
// サーバ一覧を返す
- (NSArray*) serverList
{
    return _serverList;
}


//-- serverForID
// indexを元にサーバ設定を返す
- (ServerModal*) serverForID:(int) inIdentifier
{
	NSEnumerator* e = [[self serverList] objectEnumerator];
	
	id obj;
	while(obj = [e nextObject]){
		if(inIdentifier == [[obj valueForKey:kIdentifier] intValue]){
			return obj;
		}
	}
    return nil;
}


//-- removeServer
// 現在選択中のサーバ設定を削除する
- (void) removeServer
{
	unsigned int index = [_selectedIndexes firstIndex];
    [_serverList removeObjectsAtIndexes:_selectedIndexes];
	[_selectedIndexes release];
	_selectedIndexes = [[NSIndexSet alloc] initWithIndex:index];
}


#pragma mark User Defaults
//-- preferencesFromDefaults
// 初期設定ファイルから設定をCurrentValuesに読み込む
- (void) preferencesFromDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [_serverList release];
	_serverList = [[NSMutableArray alloc] init];
	// 初期設定ファイルから読み込む
    id obj = [defaults objectForKey:kServerDefaults];
    if (obj && [obj count] > 0) {
    	NSEnumerator* e = [obj objectEnumerator];
		id it;
		while(it = [e nextObject]){
			[_serverList addObject:[ServerModal serverModalWithDictionary:it]];
		}
	} else {
    	[_serverList addObject:[ServerModal serverModal]];
    }
	
	id serverNumber = [defaults objectForKey:kSelectedServerNumber];
	int index = serverNumber ? [serverNumber intValue] : 0;
	if(index < 0 || [_serverList count] <= index){
		index = 0;
	}
	[_selectedIndexes release];
	_selectedIndexes = [[NSIndexSet alloc] initWithIndex:index];
}


//-- savePreferencesToDefaults
// 初期設定ファイルに設定を書き込む
- (void) savePreferencesToDefaults 
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // サーバ設定を保存する
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:[_serverList count]];
	for(ServerModal* server in _serverList){
		[array addObject:[server parameters]];
	}
	[defaults setObject:array forKey:kServerDefaults];
	// 選択中のエントリを書き込む
    [defaults setObject:[NSNumber numberWithInt:[_selectedIndexes firstIndex]] forKey:kSelectedServerNumber];
    // ファイルに書き込む
    [defaults synchronize];
}

@end
