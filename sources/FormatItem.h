//
//  $RCSfile: FormatItem.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import <Foundation/Foundation.h>

enum {
    insert_Channel = 1,
    insert_Console = 2,
    insert_JoinedChannel = 3,
    insert_Nothing = 0
};


@interface FormatItem : NSObject {
    NSString* _format;			// format
    NSString* _commonFormat; 	// format for common view
    NSString* _appendFormat; 	// append charactor
    int _displayPlace;			// message Çï\é¶Ç∑ÇÈèÍèä
    int	_channelPosition;		// channelÇÃà íu
}


- (id) initWithParams:(NSString*)format :(NSString*)commaon  :(NSString*)append :(int)where :(int)channel;
+ (id) formatWithFormat:(NSDictionary*)inFormat;

- (NSString*) format;
- (NSString*) commonFormat;
- (NSString*) appendFormat;
- (int) displayPlace;
- (int) channelPosition;

@end