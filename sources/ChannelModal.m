//
//  $RCSfile: ChannelModal.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ChannelModal.h"
#import "NickListItem.h"
#import "ChannelViewController.h"
#import "PreferenceWindowController.h"
#import "ChannelWindowController.h"
#import "IRcatUtilities.h"
#import "IRCMessage.h"
#import "IRcatInterface.h"

@implementation ChannelModal

#pragma mark Init

//-- init
// 空チャンネルの生成
- (id) init
{
    self = [super init];
    if(self != nil){
        _channelID = -1;
        _channelName = nil;
        _nickList = nil;
        _viewController = nil;
        _isEmptyChannel = NO;
        _isLogging = NO;
        _logFile = nil;
        _topic = nil;
        _iconName = nil;
	}
    return self;
}

    
//-- initWithName:identify:server
// 初期化
- (id) initWithName:(NSString*) inChannelName
           identify:(NSInteger) inChannelID
             server:(NSInteger) inServerID
{
    self = [super init];
    if(self != nil){
        [self setChannelName:inChannelName];
        _serverID = inServerID;
        _channelID = inChannelID;
        _nickList = [[NSMutableArray alloc] init];
        _viewController = nil;
        _isEmptyChannel = NO;
        _isLogging = NO;
        _iconName = nil;
	
        _channelMode = [[NSMutableArray alloc] init];
        _logFile = nil;
	}
    return self;
}



//-- replaceChannel:server:
// チャンネルの初期化
- (void) clearChannel:(NSString*)inChannelName
				 server:(NSInteger)inServerID
{
	_isEmptyChannel = NO;
	_isLogging = NO;
	
	if(_nickList){
		[_nickList removeAllObjects];
	}else{
		_nickList = [[NSMutableArray alloc] init];
	}
	
	if(_viewController){
		if(![self compareForName:inChannelName server:inServerID]){
			[_viewController removeAllString];
		}
	}
    
	if(_channelMode){
		[_channelMode removeAllObjects];
	}else{
		_channelMode = [[NSMutableArray alloc] init];
	}
	
	if(_topic){
		[_topic release];
		_topic = nil;
	}
	
	_logFile = nil;
	_serverID = inServerID;
	[self setChannelName:inChannelName];	
}


//-- dealloc
// あとかたづけ
- (void) dealloc
{
    [_channelName release];
	[_aliasName release];
    [_nickList release];
    [_channelMode release];
	[_logFile release];
    [_viewController release];
	[_windowController release];
	[_topic release];
	[_iconName release];
    [super dealloc];
}



#pragma mark -

#pragma mark Compare

//-- compareForName:server:
// チャンネルの比較 チャンネル名とサーバIDでチャンネルを比較する
- (BOOL) compareForName:(NSString*)inChannelName
                 server:(NSInteger)inServerID
{
	if ([self isEmptyChannel]) return NO;
	
    if(_channelName && _aliasName){
        return ((_serverID == inServerID) &&
				([_channelName caseInsensitiveCompare:inChannelName] == NSOrderedSame 
				 || [_aliasName caseInsensitiveCompare:inChannelName] == NSOrderedSame));
    }
    return NO;
}


#pragma mark NickList

//-- findNick
// nick nameの検索
- (NickListItem*) findNick:(NSString*) inNick
{
	NSEnumerator* e = [_nickList objectEnumerator];
    NickListItem* it = nil;
    
    while(it = [e nextObject]){
        if([[it nick] caseInsensitiveCompare:inNick] == NSOrderedSame){
			return it;
        }
    }
    return nil;
}


//-- appendNick:flag
// nick nameの追加
- (void) appendNick:(NSString*)inNick flag:(int)inFlag
{
	[self appendNick:inNick label:nil flag:inFlag]; 
}


//-- appendNick:label:flag
// nick nameの追加
- (void) appendNick:(NSString*)inNick label:(NSString*)inLabel flag:(int)inFlag
{
	// 名無しは何もしない
    if (inNick == nil || [inNick isEqualToString:@""]) return;
    // 新規ユーザニックの生成
    NickListItem* item = [[[NickListItem alloc] initWithNick:inNick label:inLabel flag:inFlag] autorelease];
    NSEnumerator* e = [_nickList objectEnumerator];
    // 名前順に挿入していく
    id obj;
	while(obj = [e nextObject]){
        NSComparisonResult result = [obj compareWithNickListItem:item];
        if(result == NSOrderedSame){ // 同じ名前があれば何もしない
            return;
        }else if(result == NSOrderedDescending){
            [_nickList insertObject:item atIndex:[_nickList indexOfObject:obj]];
            return;
		}
    }
    [_nickList addObject:item];
}


//-- setFlag:nick:ison
// フラグの設定
- (BOOL) setFlag:(UserModeFlag) inFlag
			nick:(NSString*) inNick
			ison:(BOOL) inIsOn
{
    NickListItem* it;
	
	if((it = [self findNick:inNick]) != nil){
		[it setFlag:inFlag ison:inIsOn];	
		return YES;
	}
    return NO;
}


//-- renameNick:to:
// nick nameの変更
- (BOOL) renameNick:(NSString*)inNick to:(NSString*)inNewNick
{
    NickListItem* it;
    
    if((it = [self findNick:inNick]) != nil){
		[it setNick:inNewNick];
		return YES;
    }
    return NO;
}


//-- removeNick
// nickname の削除
- (BOOL) removeNick:(NSString*)inNick
{
    NickListItem* it;
    if(!IsChannel(_channelName)){
		return NO;
	}
	
	if((it = [self findNick:inNick]) != nil){
		[_nickList removeObject:it];
		return YES;
    }
    return NO;
}


//-- isJoined
// nickの人が参加しているかどうかのチェック
- (BOOL) isJoined:(NSString*)inNick
{
	return ([self findNick:inNick] != nil) ? YES : NO;
}


#pragma mark NSTableView (data source) 
//-- numberOfRowsInTableView
// テーブルの行数を返す
- (NSInteger) numberOfRowsInTableView : (NSTableView*) aTableView
{
    return [_nickList count];
}


//-- tableView:objectValueForTableColumn:row
// テーブルの内容を返す
-(id)				tableView : (NSTableView*) aTableView
    objectValueForTableColumn : (NSTableColumn*) aTableColumn
						  row : (NSInteger) rowIndex
{
	id identifier = [aTableColumn identifier];
    if([identifier isEqualToString:@"nick"]) {
		return [[_nickList objectAtIndex:rowIndex] nick];
    }else if([identifier isEqualToString:@"op"]) {
		if(_serverID < 0){
			return [NSImage imageNamed:[[_nickList objectAtIndex:rowIndex] label]];
		}else{
			int flag = [[_nickList objectAtIndex:rowIndex] flag];
			if((flag & IRFlagOperator) != 0){
				return [NSImage imageNamed:@"op"];
			}else if((flag & IRFlagSpeakAbility) != 0){
				return [NSImage imageNamed:@"voice"];
			}else{
				return nil;
			}
		}
    }else if([identifier isEqualToString:@"icon"]) {
		if([[_nickList objectAtIndex:rowIndex] isFriend]){
			return [NSImage imageNamed:@"friend_cat"];
		}else{
			return nil;
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
		[nicks addObject:[[_nickList objectAtIndex:buf[i]] nick]];
	}
	return nicks;
}


//-- stringSelected
// 選択されたnickを返す
- (NSString*) stringSelected:(NSInteger) inIndex
{
	return [[_nickList objectAtIndex:inIndex] nick];
}


#pragma mark -
#pragma mark Interface

//-- aliasName
// チャンネル名を返す
-(NSString*) aliasName
{
	return _aliasName;
}


//-- setAliasName
// チャンネル名の別名を変更
-(void) setAliasName:(NSString*) inChannelName
{
	[_aliasName release];
	_aliasName = [[[PreferenceWindowController sharedPreference] aliasChannelName:inChannelName safe:YES]
				copyWithZone:[self zone]];
}



//-- channelView
// channelの基本となるviewを返す
- (id) channelView
{
    return [_viewController channelView];
}


//-- setChannelName:
// チャンネル名の変更
- (void) setChannelName:(NSString*)inChannelName
{
    [_channelName release];
    _channelName = [inChannelName copyWithZone:[self zone]];
    
	[self setAliasName:inChannelName];
}


//-- setTopic:
// topicの変更
- (void) setTopic:(NSString*) inChannelTopic
{
	[_topic release];
    _topic = [inChannelTopic copyWithZone:[self zone]];
}


//-- setEmptyChannel
// empty channelのon/off
- (void) setEmptyChannel:(BOOL) inEmpty
{
    _isEmptyChannel = inEmpty;
	if(_isEmptyChannel == YES && _isLogging == YES){
		[self setLoggingChannel:NO];
	}
}

//-- iconName
// icon nameを返す
- (NSString*) iconName
{
	return _iconName;
}


//-- setIconName
// icon nameの変更
- (void) setIconName:(NSString*)name
{
	[_iconName release];
	_iconName = [name copyWithZone:[self zone]];
}


//-- setLoggingChannel
// logをとるかどうかのon/off
- (void) setLoggingChannel:(BOOL) inLogging
{
	if(inLogging == NO && _isLogging == YES){
		if(_logFile){
			[_logFile closeFile];
			[_logFile release];
			_logFile = nil;
		}
	}
    _isLogging = inLogging;
}


//-- loggingChannel
// logをとるかどうかのon/off
- (BOOL) loggingChannel
{
    return _isLogging;
}


//-- name
// チャンネル名を返す
- (NSString*) name
{
    return _channelName;
}


//-- channelType
// チャンネルタイプを返す
//- (ChannelType) channelType
//{
//	return mChannelType;
//}


//-- topic
// topicを返す
- (NSString*) topic
{
    return _topic ? _topic : @"";
}


//-- serverid
// server id を返す
- (NSInteger) serverid
{
    return _serverID;
}


//-- channelid
// channel idを返す
- (NSInteger) channelid
{
    return _channelID;
}


//-- isConsole
// consoleかどうか
- (BOOL) isConsole
{
    return _serverID == -1;
}


//-- isEmptyChannel
// 空チャンネルかどうか
- (BOOL) isEmptyChannel
{
	return _isEmptyChannel;
}


//-- isActiveChannel
// 前面にでているチャンネルかどうか
- (BOOL) isActiveChannel
{
    return ([_windowController activeChannel] == self);
}


//-- isLogging
// ログをとるかどうか
- (BOOL) isLogging
{
    return _isLogging;
}


//-- windowType
// ウィンドウの形式を返す
- (BOOL) windowType
{
    return _isTearOff;
}


//-- setChannelFlag
// チャンネルフラグの設定
- (void) setChannelFlag:(unichar)inFlag
				   ison:(BOOL)inIsOn
{
	NSString* mode = [NSString stringWithFormat:@"%c", inFlag];
	NSUInteger index = [_channelMode indexOfObject:mode];
	if(inIsOn){
		if(index == NSNotFound){
			[_channelMode addObject:mode];
			[_channelMode sortUsingSelector:@selector(caseInsensitiveCompare:)];
		}
	}else{
		if(index != NSNotFound){
			[_channelMode removeObjectAtIndex:index];
		}
	}
}


//-- channelFlagString
// チャンネルフラグの文字列
- (NSString*) channelFlagString
{
	return [_channelMode componentsJoinedByString:@""];
}


//-- enableChannel
// チャンネルが選択可能かどうかの判断
- (NSNumber*) enableChannel
{
	return [NSNumber numberWithBool:(_isEmptyChannel ? NO : YES)];
}


#pragma mark Append String
//-- appendString:
// 文字列を追加する
- (BOOL) appendString:(NSAttributedString*)inString
{
    return [self appendString:inString append:NULL at:0];
}


//-- appendString:append:at:
// 文字列の追加を行う
- (BOOL) appendString:(NSAttributedString*)inString
               append:(NSAttributedString*)inAppend
                   at:(NSInteger)inAppendIndex;
{
	if(_isLogging){
		NSString* message;
		if(inAppend){
			NSMutableString* temp = [NSMutableString stringWithString:[inString string]];
			[temp insertString:[inAppend string] atIndex:inAppendIndex];
			message = temp;
		}else{
			message = [inString string];
		}
		[self loggingMessage:message];
	}
    return [_viewController appendString:inString append:inAppend at:inAppendIndex];
}


//-- loggingMessage
// ログを保存する
- (void) loggingMessage:(NSString*) inMessage
{
	if(!_logFile){
		if(![self createLogFile]){
			return;
		}
	}else{
		if(![_logFileDate isEqualToString:[self logDateString]]){
			[_logFileDate release];
			[_logFile release];
			[self createLogFile];
		}
	}
	[_logFile seekToEndOfFile];
	NSData* data = [inMessage dataUsingEncoding:NSUnicodeStringEncoding];
	unichar* bom = (unichar*)[data bytes];
	NSRange range = NSMakeRange(0, [data length]);
	if(*bom == 0xfeff){
		range.location = 2;
		range.length -= 2;
	}
	[_logFile writeData:[data subdataWithRange:range]];
}



#pragma mark Logging
//-- logDateString
// ログファイルの日付フォーマットを返す
- (NSString*) logDateString
{
	return [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d" timeZone:nil locale:nil];
}


//-- createLogFile
// ログファイルの作成
- (BOOL) createLogFile
{
	_logFileDate = [[self logDateString] copyWithZone:[self zone]];
    NSString* logFloder = [PreferenceModal prefForKey:kLogFolder];
	NSString* dic = [NSString stringWithFormat:@"%@/%@", logFloder, [self aliasName]];
	BOOL isDirectory;
	NSFileManager* fm = [NSFileManager defaultManager];
    
    NSURL* bookmark = nil;
    if([fm fileExistsAtPath:logFloder] == YES && [fm isWritableFileAtPath:logFloder] == NO){
        bookmark = [PreferenceModal securityBookmarkForPath:logFloder];
        if (bookmark == nil){
            NSString* string = [NSString stringWithFormat:@"* %@ :%@", [self aliasName],
                                NSLocalizedString(@"DontAllowAccess", @"DontAllowAccess")];
            IRCMessage* message = [[[IRCMessage alloc] initWithMessage:string server:[self serverid]] autorelease];
            [[_windowController interface] appendMessage:message format:kInternalErrorFormat];
            return NO;
        }
    }
    
    BOOL success = YES;
    if (bookmark) [bookmark startAccessingSecurityScopedResource];
    @try {
        BOOL isExists = [fm fileExistsAtPath:dic isDirectory:&isDirectory];
        if(!isExists){
            NSError* error;
            if(![fm createDirectoryAtURL:[NSURL fileURLWithPath:dic] withIntermediateDirectories:YES attributes:nil error:&error]){
                [[NSException exceptionWithName:@"createDirectoryAtURL:withIntermediateDirectories:attributes:error:"
                                         reason:[error localizedDescription]
                                       userInfo:nil] raise];

            }
        }else if(!isDirectory){
            [[NSException exceptionWithName:@"fileExistsAtPath:isDirectory:"
                                     reason:@"It is directory"
                                   userInfo:nil] raise];
        }
        
        NSString* path = [NSString stringWithFormat:@"%@/%@.txt", dic, _logFileDate];
        isExists = [fm fileExistsAtPath:path isDirectory:&isDirectory];
        if(!isExists){
            if(![fm createFileAtPath:path contents:nil attributes:nil]){
                [[NSException exceptionWithName:@"createFileAtPath:contents:attributes"
                                         reason:@""
                                       userInfo:nil] raise];
            }
        }else if(isDirectory){
            [[NSException exceptionWithName:@"fileExistsAtPath:isDirectory:"
                                     reason:@"It is directory"
                                   userInfo:nil] raise];
        }
        _logFile = [[NSFileHandle fileHandleForWritingAtPath:path] retain];
        [_logFile seekToEndOfFile];
        if(!isExists){
            unichar bom = 0xfeff;
            [_logFile writeData:[NSData dataWithBytes:(char*)(&bom) length:2]];
        }
    }
    @catch(NSException *exception) {
        success = NO;
        NSLog(@"%@ : %@",[exception name], [exception reason]);
    }
    @finally {
        if (bookmark) [bookmark stopAccessingSecurityScopedResource];
    }

	return success;
}


#pragma mark Interface
//-- windowController
// window controllerを返す
- (ChannelWindowController*) channelWindowController
{
	return _windowController;
}


//-- setWindowController
// window controllerのセット
-(void) setChannelWindowController:(ChannelWindowController*) inController
{
	[_windowController release];
	_windowController = [inController retain];
}


//-- viewController
// viewControllerを返す
-(ChannelViewController*) channelViewController
{
	return _viewController;
}

//-- setChannelViewController
// viewControllerのセット
-(void) setChannelViewController:(ChannelViewController*) inViewController;
{
	[_viewController release];
	_viewController = [inViewController retain];
}

@end