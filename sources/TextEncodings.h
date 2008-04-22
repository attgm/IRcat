//
//  $RCSfile: TextEncodings.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//


#import <Cocoa/Cocoa.h>

@interface TextEncodings :  NSObject {
}
+(NSArray*) encodingList;
+(Class) filterFromEncoding:(NSString*) inEncoding;
@end

@protocol EncodingFilter
+(NSString*) stringFromIncommingData:(NSData*) inData;
+(NSData*) outgoingDataFromString:(NSString*) inString;
@end


@interface TextEncodingISO2022JP : NSObject <EncodingFilter> {
}
+(NSString*) stringFromIncommingData:(NSData*) inData;
+(NSData*) outgoingDataFromString:(NSString*) inString;
@end


@interface TextEncodingJISX0201X0208 : NSObject <EncodingFilter> {
}
+(NSString*) stringFromIncommingData:(NSData*) inData;
+(NSData*) outgoingDataFromString:(NSString*) inString;
@end


@interface TextEncodingUTF8 : NSObject <EncodingFilter> {
}
+(NSString*) stringFromIncommingData:(NSData*) inData;
+(NSData*) outgoingDataFromString:(NSString*) inString;
@end