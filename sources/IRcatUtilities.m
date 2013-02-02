//
//  $RCSfile: IRcatUtilities.m,v $
//
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//


#import "IRcatUtilities.h"

//-- PrefixString
// inDevideがでてくるまでの文字列を返す.
// inDevideが見つからなかった場合は inContentの文字列を返す ioContentは(NotFound, 0)
// ioContentのlengthが0であった場合, nilを返す
NSString* PrefixString(NSString* inString, NSString* inDevide, NSRange* ioContent)
{
    NSRange devider, prefix;
    
    if(ioContent->length == 0)
        return nil;
    
    if(inDevide != nil){
        devider = [inString rangeOfString:inDevide options:NSLiteralSearch range:*ioContent];
        if(devider.location != NSNotFound){
            prefix = NSMakeRange(ioContent->location, (devider.location - (ioContent->location)));
            *ioContent = NSMakeRange(devider.location + devider.length,
                                     ioContent->length - (prefix.length + devider.length));
            
            return [inString substringWithRange:prefix];
        }else{
			prefix = *ioContent;
            *ioContent = devider;
			return (prefix.location == 0 && prefix.length == [inString length]) ? inString
            : [inString substringWithRange:prefix];
        }
    }
    
    return inString;
}


//-- PrefixCharacterSet
// 文字集合がでてくるまですっとばす
NSString* PrefixCharacterSet(NSString* inString, NSCharacterSet* inDevide, NSRange* ioContent)
{
    NSRange devider, prefix;
    
    if(ioContent->length == 0)
        return nil;
    
    if(inDevide != nil){
        devider = [inString rangeOfCharacterFromSet:inDevide options:NSLiteralSearch range:*ioContent];
        if(devider.location != NSNotFound){
            prefix = NSMakeRange(ioContent->location, (devider.location - (ioContent->location)));
            *ioContent = NSMakeRange(devider.location + devider.length,
									 ioContent->length - (prefix.length + devider.length));
			
            return [inString substringWithRange:prefix];
        }else{
            *ioContent = devider;
        }
    }
    
    return inString;
}



//-- IsChannel
// channel名かどうかの確認
BOOL IsChannel(NSString* inString)
{
    unichar c = [inString characterAtIndex:0];
    return ((c == '#') || (c == '+') || (c == '&') || (c == '!'));
}


//-- IsNick
// nick nameかどうかの確認
BOOL IsNick(NSString* inString)
{
    return !IsChannel(inString);
}


//-- IsMode
// モード文字列かどうかの判定
BOOL IsMode(NSString* inString)
{
	NSRange range = NSMakeRange(0, [inString length]);
	NSString* modeString = PrefixString(inString, @" ", &range);
	
	NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"+-iswopsitnmlbvk"];
	NSScanner* scanner = [NSScanner scannerWithString:modeString];
	[scanner setCaseSensitive:NO];
	[scanner scanCharactersFromSet:charSet intoString:nil];
    
	return [scanner isAtEnd]; //最後までいったかどうか
}


//-- IsAppSandboxed
// sandbox を使っているかどうか
BOOL IsAppSandboxed()
{
	NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    return  ([environment objectForKey:@"APP_SANDBOX_CONTAINER_ID"] != nil);
}

