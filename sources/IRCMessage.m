//
//  $RCSfile: IRCMessage.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "IRCMessage.h"
#import "FormatTable.h"
#import "PreferenceModal.h"
#import "PreferenceWindowController.h"
#import "IRcatUtilities.h"
//#import "AnalysisFilter.h"
#import "IRcatInterface.h" // for MessageAttribute

#define kIRCMsgCommandChar	'\1'

#define kServerMessagePrefix 	@"*** "
#define kErrorMessagePrefix 	@"*** "

static NSString* kProtocol[] = {@"http://", @"https://", @"ftp://", @"mailto:"};
const int kProtocolNum = 4;

//-- IncreaseRange
// レンジを1つ進める
#define IncreaseRange(range) {	\
    range.location++;		\
    range.length--;		\
}


//-- DevideString
NSRange DevideString(NSString* inString, NSString* inDevide, NSRange* ioContent)
{
    NSRange devider, prefix;
    
    //NSLog(@"devide... %@ %@", NSStringFromRange(*ioContent), [inString substringWithRange:*ioContent]);
    
    devider = [inString rangeOfString:inDevide options:NSLiteralSearch range:*ioContent];
    if(devider.location != NSNotFound){
        prefix = NSMakeRange(ioContent->location, (devider.location - (ioContent->location)));
        *ioContent = NSMakeRange(devider.location + devider.length,
                                    ioContent->length - (prefix.length + devider.length));
    }else{
        prefix = devider;
    }
    
    //NSLog(@"cut... %@ %@", NSStringFromRange(prefix), [inString substringWithRange:prefix]);
    return prefix;
} 


@implementation IRCMessage

//-- initWithMessage:server
- (id) initWithMessage:(NSString*) inMessage server:(int)inServerID
{
	[super init];
    _serverid = inServerID;
    _message = [inMessage copyWithZone:[self zone]];
    
    _channelname = nil;
    _hostname = nil;
    _nickname = nil;
    _trailing = nil;
    _extendString = nil;
	_hasKeyword = NO;
	_hasNotification = NO;	
    _paramList = [[NSMutableArray alloc] init];
    
    [self parsePrefix];
    [self parseParams];
    
    return self;
}


//-- dealloc
// release resources
- (void) dealloc
{
	[_commandNumber release];
    [_message release];
    [_nickname release];
    [_hostname release];
    [_channelname release];
    [_trailing release];
    [_paramList release];
	
    [_expandedMessage release];
    [_commonMessage release];
    [_additionalMessage release];
	[_extendString release];
	[super dealloc];
}


#pragma mark ･･･  paser ･･･
//-- ParsePrefix
// prefix部分 (nick!host command)の解析
- (void) parsePrefix
{
    // get prefix
    if([_message characterAtIndex:0] == ':'){
        NSRange prefix, pos;
        
    
        pos = NSMakeRange(0, [_message length]);
        prefix = DevideString(_message, @" ", &pos);
        
        pos = DevideString(_message, @"!", &prefix);
        
        if(pos.location != NSNotFound){
            _hostname = [[_message substringWithRange:prefix] copyWithZone:[self zone]];
            IncreaseRange(pos);  // skip ':'
            _nickname = [[_message substringWithRange:pos] copyWithZone:[self zone]];
        }else{
            _hostname = [[NSString alloc] initWithString:@""];
            IncreaseRange(prefix);  // skip ':'
            _nickname = [[_message substringWithRange:prefix] copyWithZone:[self zone]];
        }
    }else{
        _hostname = nil;
        _nickname = nil;
    }
}

//-- ParseParams
// paramの解析
- (void) parseParams
{
    NSRange content, param;
    
    _trailing = nil;
    
    content = NSMakeRange(0, [_message length]);
    if(_nickname != nil){
        param = DevideString(_message, @" ", &content);
    }
    
    // get command
    {
        int commandNumber;
        
        param = DevideString(_message, @" ", &content);
        
        _commandNumber = [[_message substringWithRange:param] copyWithZone:[self zone]];
        commandNumber = [_commandNumber intValue];
        if(commandNumber == 0){
            _messageType = IRC_CommandMessage;
            [_paramList addObject:_commandNumber];
        } else if(400 <= commandNumber && commandNumber < 600){
            _messageType = IRC_ErrorMessage; // 4xx 5xx is error message
        }else{
            _messageType = IRC_ReplyMessage;
        }
    }
    
    do {
        if([_message characterAtIndex:content.location] == ':'){
            IncreaseRange(content); // skip ':'
            _trailing = [[_message substringWithRange:content] copyWithZone:[self zone]];
            param.location = NSNotFound;
        }else{
            param = DevideString(_message, @" ", &content);
            if(param.location != NSNotFound){
                [_paramList addObject:[_message substringWithRange:param]];
            }
        }
    } while(param.location != NSNotFound && content.location < [_message length]);
    
    [_paramList addObject:[_message substringWithRange:content]];
}


//-- isCtcpCommand
// commandかどうかの確認
- (BOOL) isCtcpCommand
{
    BOOL command = NO;
    
    // command messageなのかどうかのチェック
    // tailingが \a で囲まれているかどうかで確認
    if(_trailing){
        if([_trailing characterAtIndex:0] == kIRCMsgCommandChar
            && [_trailing characterAtIndex:([_trailing length] - 1)] == kIRCMsgCommandChar){
            // param listの修正
			// 両端の\aを削除
			NSString* trailing = [_trailing substringWithRange:NSMakeRange(1, [_trailing length] - 2)];
			// param listの修正
			NSArray* array = [trailing componentsSeparatedByString:@" "];
			// 最後の要素(trailing)を消して分割したtrailingを追加
			[_paramList removeLastObject];
			// 最後の要素(trailing)を消して分割したtrailingを追加
			[_paramList addObjectsFromArray:array];
			/*NSRange range = NSMakeRange(1, [_trailing length] - 2); // 両端の\aを削除
			NSString* param = PrefixString(_trailing, @" ", &range);
			[_paramList addObject:param];
			if(range.length > 0){
				if([_trailing characterAtIndex:range.location] == ':'){
					IncreaseRange(range);
				}
				[_paramList addObject:[_trailing substringWithRange:range]];
			}*/
			
            command = YES;
        }
    }
    return command;
}


//-- devideTrailingBy
// Trailingを分割してparamに挿入する
- (void) devideTrailingBy:(NSString*) inDevider
{
    if(_trailing){
        NSArray* array;
        
        array = [_trailing componentsSeparatedByString:inDevider];
        // 最後の要素(trailing)を消して分割したtrailingを追加
        [_paramList removeLastObject];
        [_paramList addObjectsFromArray:array];
    }
}


//-- applyFormat
// formatを適用する
- (NSString*) applyFormat : (FormatItem*) inFormat
			   attributes : (NSArray*) inAttributes
{
    if (inFormat == nil) return nil;

    // channel名の取得
    if([inFormat channelPosition] != '\0'){
        _channelname = ([inFormat channelPosition] == 'n') ? [[self nickname] copyWithZone:[self zone]] 
			: [[self paramAtIndex:[inFormat channelPosition]] copyWithZone:[self zone]];
    }
    
    _commonAdditionalPosition = _additionalPosition = _additionalIndex = 0;
    
    if([inFormat format]){
        _expandedMessage = 
		[[self expandFormat:[inFormat format] attributes:inAttributes appendEnter:YES] copyWithZone:[self zone]];
		_additionalPosition = _additionalIndex;
	}
    if([inFormat commonFormat]){
        _commonMessage =
		[[self expandFormat:[inFormat commonFormat] attributes:inAttributes appendEnter:YES] copyWithZone:[self zone]];
    	_commonAdditionalPosition = _additionalIndex;
	}else{
		_commonAdditionalPosition = _additionalPosition;
	}
    if([inFormat appendFormat]){
        _additionalMessage =
		[[self expandFormat:[inFormat appendFormat] attributes:inAttributes appendEnter:NO] copyWithZone:[self zone]];
    }
    
    return nil;
}


//-- expandFormat
// Formatを展開する
- (NSAttributedString*) expandFormat : (NSString*) inFormat
						  attributes : (NSArray*) inAttributes
                         appendEnter : (BOOL) inNeedEnter
{
    NSRange format = NSMakeRange(0, [inFormat length]);
    NSRange context = NSMakeRange(0,0);
    NSMutableAttributedString* outputString = [[[NSMutableAttributedString alloc] init] autorelease];
    unichar	c;

    NSDictionary* currentColor = [inAttributes objectAtIndex:kPlainAttribute];
    unsigned int keywordPos = -1;
	
    if (format.length == 0) return outputString;
        
    while(format.length > 0){
        c = [inFormat characterAtIndex:format.location];
        IncreaseRange(format);
        if ((c == '%' || c == '*' || c == '+') && context.length > 0) {
            // 文字列部分の展開
            [outputString appendString:[inFormat substringWithRange:context] attributes:currentColor];
        }
        
        if(c == '%'){
            // 変数部分の処理
            c = [inFormat characterAtIndex:format.location];
            IncreaseRange(format);
            context = NSMakeRange(format.location, 0);
            // 数字であった場合, paramを処理する
            if('0' < c && c <= '9') {
                int index = (int)(c - '0');
                [outputString appendString:[self paramAtIndex:index] attributes:currentColor];
            }else{
                switch (c){
                    case 't': // %t : time
                        if([[PreferenceModal prefForKey:kDisplayTime] boolValue] == YES){
                            [outputString appendString:[self timeString]
                                          attributes:([[PreferenceModal prefForKey:kColoredTime] boolValue] ? 
                                                        [inAttributes objectAtIndex:kTimeAttribute] : currentColor)];
                        }
                        break;
					case 'T': // %T : time (command message)
						if([[PreferenceModal prefForKey:kDisplayTime] boolValue] == YES
						   && [[PreferenceModal prefForKey:kDisplayCommandTime] boolValue] == YES){
                            [outputString appendString:[self timeString]
											attributes:([[PreferenceModal prefForKey:kColoredTime] boolValue] ? 
                                                        [inAttributes objectAtIndex:kTimeAttribute] : currentColor)];
                        }
                        break;
                    case 'n': // %n : Nick
                    case 'N': // %N : colored nick
                        [outputString appendString:[self nickname] attributes:currentColor];
                        break;
                    case 'c': // %c : ChannelName
                        [outputString appendString:[[PreferenceWindowController sharedPreference] aliasChannelName:_channelname
																										safe:YES]
										attributes:currentColor];
                        break;
                    case 'C': // %C : Command Number
                        [outputString appendString:[self commandNumber] attributes:currentColor];
                        break;
                    case 'M': // %M : MessageColor
                        currentColor = [inAttributes objectAtIndex:kPlainAttribute];
                        //[outputString appendString:kMessageColorPrefix attributes:currentColor];
                        break;
                    case 'U': // %U : Filtered Tailing
                        //currentColor = serverMessageColor;
                        [outputString appendString:_trailing attributes:currentColor];
                        //[outputString appendAttributedString:[self filterMessage:mTailing]];
                        break;
                    case 'S': // %S : Server Message
						if([[PreferenceModal prefForKey:kColoredCommand] boolValue] == YES){
							currentColor = [inAttributes objectAtIndex:kServerMessageAttribute];
						}
                        [outputString appendString:kServerMessagePrefix attributes:currentColor];
                        break;
                    case 's': // %s : Server Message Color
                        if([[PreferenceModal prefForKey:kColoredCommand] boolValue] == YES){
							currentColor = [inAttributes objectAtIndex:kServerMessageAttribute];
						}
                        break;
                    case 'E': // %E : Error Message
                        if([[PreferenceModal prefForKey:kColoredError] boolValue] == YES){
							currentColor = [inAttributes objectAtIndex:kErrorMessageAttribute];
						}
                        [outputString appendString:kErrorMessagePrefix attributes:currentColor];
                        break;
                    case 'e': // %e : Error Message Color
                        if([[PreferenceModal prefForKey:kColoredError] boolValue] == YES){
							currentColor = [inAttributes objectAtIndex:kErrorMessageAttribute];;
						}
                        break;
                    case 'x': // %x : Extend Message
						if(_extendString){
							[outputString appendString:_extendString attributes:currentColor];
                        }
						break;
                    case '[': // %[ : Keyword bracket キーワード開始
					case '{': // %{ : Keyword/Notification bracket
                        keywordPos = [outputString length];
						break;
					case ']': // %] : keyword bracket キーワード終了
						if(keywordPos >= 0){
							[self filterMessage:outputString
										  range:NSMakeRange(keywordPos, [outputString length] - keywordPos)];
						}
						break;
                    case '}': // %} : notification bracket キーワード終了
						if(keywordPos >= 0){
							[self notifyMessage:outputString
										  range:NSMakeRange(keywordPos, [outputString length] - keywordPos)];
						}
						break;
					case 'A': // %A : Additional Message
                        _additionalIndex = [outputString length];
                        break;
                    default:
                        context.location--;
                        context.length++;
                        break;
                    }
                }
            }else if(c == '+' || c == '*'){ // *n or +n
                unichar d = [inFormat characterAtIndex:format.location];
                IncreaseRange(format);
                context = NSMakeRange(format.location, 0);
                if('0' < d && d <= '9') {
					int index = (int)(d - '0');
					if(c == '*'){ // *d : d以降のparamを連結して表示
						[outputString appendString:
							[[_paramList subarrayWithRange:NSMakeRange(index, [_paramList count] - index)]
								componentsJoinedByString:@" "]
										attributes:currentColor];
					}else{ // +d dを時間フォーマット処理して表示
						unsigned time = [[self paramAtIndex:index] intValue];
						NSDate* date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)(time)];
						if(date){
							[outputString appendString:[date description] attributes:currentColor];
						}else{
							[outputString appendString:[self paramAtIndex:index] attributes:currentColor];
						}
					}
				}else{
					context.location--;
					context.length++;
                }
            }else{
                context.length++;
            }
        }
        
	if(context.length > 0){
            [outputString appendString:[inFormat substringWithRange:context] attributes:currentColor];
	}
	if(inNeedEnter == YES){
		[outputString appendString:@"\r" attributes:currentColor];
	}
	return outputString;
};


//-- channel
// 表示させるチャンネル名を返す
- (NSString*) channel
{
    return _channelname;
}


//-- expandedMessage
// 展開済みのメッセージの表示
- (NSAttributedString*) expandedMessage
{
    return _expandedMessage;
}


//-- additionalMessage
// 追加メッセージの取得
- (NSAttributedString*) additionalMessage
{
    return _additionalMessage;
}


//-- additionalPosition
// 挿入ポイントの取得
- (int) additionalPosition
{
    return _additionalPosition;
}


//-- commonAdditionalPosition
// 挿入ポイントの取得
- (int) commonAdditionalPosition
{
    return _commonAdditionalPosition;
}


//-- commonMessage
// 共有エリア用メッセージの取得
- (NSAttributedString*) commonMessage
{
    return (_commonMessage) ? _commonMessage : _expandedMessage;
}

#pragma mark ･･･ params ･･･
//-- getParam
// paramを返す
- (NSString*) paramAtIndex:(int) inIndex
{
    if(0 <= inIndex && inIndex < [_paramList count]){
        return [_paramList objectAtIndex:inIndex];
    }else{
        return nil;
    }
}


//-- serverid
// server idを返す
- (int) serverid
{
    return _serverid;
}


//-- nickname
// nickを返す
- (NSString*) nickname
{
    return _nickname;
}


//-- commandNumber
// コマンド番号を返す
- (NSString*) commandNumber
{
    return _commandNumber;
}


//-- messageType
// message typeを返す
- (IRCMessageType) messageType
{
    return _messageType;
}


//-- timeString
// 現在時刻を返す
- (NSString*) timeString
{
    NSCalendarDate* date = [NSCalendarDate calendarDate];
    
    if([[PreferenceModal prefForKey:kUseInternetTime] boolValue] == YES){
        int internetTime;
    
        // Internet timeの場合
        [date setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        internetTime = ((([date hourOfDay] + 1) * 3600) + ([date minuteOfHour] * 60)) * 1000 / 86400;
        internetTime = (internetTime > 1000) ? (internetTime - 1000) :
                                                (internetTime < 0) ? (internetTime + 1000) : internetTime;
    
        return [NSString stringWithFormat:@"@%03d ", internetTime];
    }else{
        // 通常の時刻表示
        return [NSString stringWithFormat:@"%02d:%02d ", [date hourOfDay], [date minuteOfHour]];
    }
}


//-- setExtendString
// 追加文字列の設定
- (void) setExtendString:(NSString*) inString
{
	if(_extendString){
		[_extendString release];
	}
	_extendString = [inString copyWithZone:[self zone]];
}

#pragma mark ･･･ notify message ･･･

//-- notifyMessage
// notificationがある場合設定する
- (void) notifyMessage:(NSMutableAttributedString*) inMessage
				 range:(NSRange) inRange
{
	//if([[PreferenceWindowController preferenceForKey:kColoredNotification] boolValue]){
	if([[PreferenceModal prefForKey:kColoredKeyword] boolValue]){
		if(_hasNotification){
			[inMessage addAttribute:NSForegroundColorAttributeName
							  value:[PreferenceModal prefForKey:kKeywordColor]
							  range:inRange];
		}else{
			[self parseKeyword:inMessage range:inRange];		
		}
	}
}


//-- setNotification
// キーワードがあるかどうか
- (void) setNotification:(BOOL) inNotification
{
	_hasNotification = inNotification;
}



//-- hasNotification
// キーワードがあるかどうか
- (BOOL) hasNotification
{
	return _hasNotification;
}


#pragma mark Filtering Message

//-- filterMessage
// messageをフィルタリングする (URLおよびキーワード)
- (void) filterMessage:(NSMutableAttributedString*) inMessage
				 range:(NSRange) inRange
{
	if([[PreferenceModal prefForKey:kColoredKeyword] boolValue]){
		[self parseKeyword:inMessage range:inRange];
	}
	[self parseURL:inMessage range:inRange];
}


//-- parseKeyword
// keywordの抽出
- (void) parseKeyword:(NSMutableAttributedString*) inMessage
				range:(NSRange) inRange
{
	/*if([[PreferenceModal prefForKey:kUseAnalysis] boolValue] == YES){
		_hasKeyword = [self searchKeywordByMorpheme:inMessage range:inRange];
	}else{*/
		_hasKeyword = [self searchKeyword:inMessage range:inRange];
	//}	
	
	if(_hasKeyword){
		[inMessage addAttribute:NSForegroundColorAttributeName
							  value:[PreferenceModal colorForKey:kKeywordColor]
							  range:inRange];
	}
}


//-- searchKeyword
// keywordの抽出
- (BOOL) searchKeyword:(NSMutableAttributedString*) inMessage
				 range:(NSRange) inRange
{
	NSEnumerator* e = [[PreferenceModal prefForKey:kKeywords] objectEnumerator];
	id it;
	
	while(it = [e nextObject]){
		NSRange range = NSMakeRange(NSNotFound, NSNotFound); 
		id keyword = [it objectForKey:@"name"];
		if(keyword && [keyword length] > 0){
			range = [[inMessage string] rangeOfString:keyword options:0 range:inRange];
		}
		if(range.location != NSNotFound){
			return YES;
		}
	}
	return NO;
}


//-- searchKeywordByMorpheme
// keywordの抽出
- (BOOL) searchKeywordByMorpheme:(NSMutableAttributedString*) inMessage
						   range:(NSRange) inRange
{
	/*
	NSEnumerator* e = [[PreferenceModal prefForKey:kKeywords] objectEnumerator];
	id key;
	
	NSArray* morphemes = [AnalysisFilter morphemesFromString:[[inMessage string] substringWithRange:inRange]];
	
	while(key = [e nextObject]){
		NSString* keyword = [key objectForKey:@"keyword"];
		NSEnumerator* it = [morphemes objectEnumerator];
		NSString* morpheme;
		while(morpheme = [it nextObject]){
			if([morpheme isEqualToString:keyword] == YES){
				return YES;
			}
		}
	}
	return NO;
	 */
	return NO;
}

//-- parseURL
// URL文字列を抽出する
- (void) parseURL:(NSMutableAttributedString*) inMessage
			range:(NSRange) inRange 
{
	NSScanner* scanner = [NSScanner scannerWithString:[[inMessage string] substringWithRange:inRange]];
	NSCharacterSet* urlSet = [self urlCharacterSet];
	[scanner setCaseSensitive:YES];
	[scanner setCharactersToBeSkipped:nil];
	
	unsigned int location;
	unsigned int origin = [scanner scanLocation];
	unsigned int offset = inRange.location;
	
	int i;
	for(i=0; i<kProtocolNum; i++){
		[scanner setScanLocation:origin];
		while(![scanner isAtEnd]){
			// protocol prefixのマッチング
			if(![scanner scanUpToString:kProtocol[i] intoString:nil]){
				location = [scanner scanLocation];
				[scanner scanString:kProtocol[i] intoString:nil];
				// URL文字列のマッチング
				if([scanner scanCharactersFromSet:urlSet intoString:nil]){
					NSRange range = NSMakeRange(location+offset, [scanner scanLocation] - location);
					[inMessage addAttribute:NSLinkAttributeName
									  value:[NSURL URLWithString:[[inMessage string] substringWithRange:range]]
									  range:range];
				}
			}
		}
	}
}


//-- urlCharacterSet
// URL文字列
-(NSCharacterSet*) urlCharacterSet
{
	static NSCharacterSet* urlCharSet = nil;
	if(!urlCharSet){
		urlCharSet =
			[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~/%?&_#+-@$.,:;="];
		[urlCharSet retain];
	}
	return urlCharSet;
}

//-- hasKeyword
// キーワードがあるかどうか
- (BOOL) hasKeyword
{
	return _hasKeyword;
}


@end



@implementation NSMutableAttributedString (IRcat_Addition)
//-- appendString:attribute:
// attribute付きで文字列を追加する
- (void) appendString:(NSString*)inString attributes:(NSDictionary*)inAttribute
{
    NSAttributedString* string;
    
    if (inString == nil) return;
    
    string = [[NSAttributedString alloc] initWithString:inString attributes:inAttribute];
    [self appendAttributedString:string];
    [string release];
}

@end
