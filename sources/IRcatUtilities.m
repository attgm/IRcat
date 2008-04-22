//
//  $RCSfile: IRcatUtilities.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//


#import "IRcatUtilities.h"

//-- PrefixString
// inDevide���łĂ���܂ł̕������Ԃ�.
// inDevide��������Ȃ������ꍇ�� inContent�̕������Ԃ� ioContent��(NotFound, 0)
// ioContent��length��0�ł������ꍇ, nil��Ԃ�
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
// �����W�����łĂ���܂ł����Ƃ΂�
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
// channel�����ǂ����̊m�F
BOOL IsChannel(NSString* inString)
{
    unichar c = [inString characterAtIndex:0];
    return ((c == '#') || (c == '+') || (c == '&') || (c == '!'));
}


//-- IsNick
// nick name���ǂ����̊m�F
BOOL IsNick(NSString* inString)
{
    return !IsChannel(inString);
}


//-- IsMode
// ���[�h�����񂩂ǂ����̔���
BOOL IsMode(NSString* inString)
{
	NSRange range = NSMakeRange(0, [inString length]);
	NSString* modeString = PrefixString(inString, @" ", &range);
	
	NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"+-iswopsitnmlbvk"];
	NSScanner* scanner = [NSScanner scannerWithString:modeString];
	[scanner setCaseSensitive:NO];
	[scanner scanCharactersFromSet:charSet intoString:nil];
    
	return [scanner isAtEnd]; //�Ō�܂ł��������ǂ���
}


