//
//  $RCSfile: TextEncodings.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//


#import "TextEncodings.h"

@implementation TextEncodings
//-- encodingList
// encodingのリストを返す
+(NSArray*) encodingList
{
	return [NSArray arrayWithObjects:@"ISO-2022-JP", @"JIS-X0208-X0201", @"UTF-8", nil];
}

//-- filterFromEncoding
// encoding から変換クラスを返す
+(Class) filterFromEncoding:(NSString*) inEncoding
{
	if([inEncoding isEqualToString:@"JIS-X0208-X0201"]){
		return [TextEncodingJISX0201X0208 class];
	}else if([inEncoding isEqualToString:@"UTF-8"]){
		return [TextEncodingUTF8 class];
	}
	return [TextEncodingISO2022JP class];
}
@end


@implementation TextEncodingISO2022JP
//-- stringFromIncommingData
// サーバからのメッセージをISO 2022 JPとして処理する
+(NSString*) stringFromIncommingData:(NSData*) inData
{
	return [[[NSString alloc] initWithData:inData encoding:NSISO2022JPStringEncoding] autorelease];
}


//-- outgoingDataFromString
//
+(NSData*) outgoingDataFromString:(NSString*) inString
{
	return [inString dataUsingEncoding:NSISO2022JPStringEncoding allowLossyConversion:YES];
}
@end


@implementation TextEncodingJISX0201X0208
//-- stringFromIncommingData
// サーバからのメッセージをShiftJISに一度変換しその後unicodeに変換する
+(NSString*) stringFromIncommingData:(NSData*) inData
{
	NSMutableData* sjisData = [NSMutableData dataWithCapacity:[inData length]];
	
	const unsigned char* bytes = [inData bytes];
	unsigned char c[2];
	unsigned int location = 0;
	typedef enum {
		kJISX0201Encoding,
		kJISX0208Encoding,
		kJISX0201ShiftEncoding
	} JISX0208Encoding;
	JISX0208Encoding encoding = kJISX0201Encoding;
	unsigned int end = [inData length];
	
	while(location < end){
		c[0] = bytes[location];
		if(c[0] == 27){
			if(location < (end - 2)){
				c[0] = bytes[location + 1];
				c[1] = bytes[location + 2];
				if(c[0] == '$'){ // ESC $ @ は…どうする？
					encoding = kJISX0208Encoding;
				}else if(c[0] == '(' && c[1] =='I'){
					encoding = kJISX0201ShiftEncoding;
				}else{ // if(c[0] == '(')
					encoding = kJISX0201Encoding;
				}
				location += 3;
			}else{
				location = end;
			}
		}else if(c[0] == 0x0e && encoding == kJISX0201Encoding){
			encoding = kJISX0201ShiftEncoding;
		}else if(c[0] == 0x0f && encoding == kJISX0201ShiftEncoding){
			encoding = kJISX0201Encoding;
		}else{
			switch(encoding){
				case kJISX0208Encoding:
					if(location < (end - 1)){
						c[1] = bytes[location + 1];
						c[1] = c[1] + ((c[0] % 2) ? ((c[1] > 95) ? 32 : 31) : 126);
						c[0] = ((c[0] + 1) >> 1) + ((c[0] < 95) ? 112 : 176);
						[sjisData appendBytes:c length:2];
					}
					location += 2;
					break;
				case kJISX0201ShiftEncoding:
					c[0] = c[0] | 0x80;
					// ここに breakがないのはわざと
				case kJISX0201Encoding:
					[sjisData appendBytes:c length:1];
					location += 1;
					break;
			}
		}
	}
	return [[[NSString alloc] initWithData:sjisData encoding:NSShiftJISStringEncoding] autorelease];
}


//-- outgoingDataFromString
// サーバへのメッセージをISO-2022-JPとして処理する
+(NSData*) outgoingDataFromString:(NSString*) inString
{
	return [inString dataUsingEncoding:NSISO2022JPStringEncoding];
}
@end


@implementation TextEncodingUTF8
//-- stringFromIncommingData
// サーバからのメッセージをISO 2022 JPとして処理する
+(NSString*) stringFromIncommingData:(NSData*) inData
{
	return [[[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding] autorelease];
}


//-- outgoingDataFromString
// サーバへのメッセージをISO-2022-JPとして処理する
+(NSData*) outgoingDataFromString:(NSString*) inString
{
	return [inString dataUsingEncoding:NSUTF8StringEncoding];
}
@end