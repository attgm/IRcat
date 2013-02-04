//
//  $RCSfile: FormatItem.h,v $
//
//  $Revision: 89 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import <Foundation/Foundation.h>

enum InsertPlace {
//typedef NS_ENUM(NSUInteger, InsertPlace) {
    IRInsertChannel			= 1,
    IRInsertConsole			= 2,
    IRInsertJoinedChannel	= 3,
    IRInsertNothing			= 0
};
typedef NSUInteger InsertPlace;


@interface FormatItem : NSObject {
    NSString* _format;			// format
    NSString* _commonFormat; 	// format for common view
    NSString* _appendFormat; 	// append charactor
    InsertPlace _displayPlace;			// message を表示する場所
    int	_channelPosition;		// channelの位置
}

@property (readonly) NSString* format;
@property (readonly) NSString* commonFormat;
@property (readonly) NSString* appendFormat;
@property (readonly) InsertPlace displayPlace;
@property (readonly) int channelPosition;

- (id) initWithParams:(NSString*)format :(NSString*)commaon  :(NSString*)append :(InsertPlace)where :(int)channel;
+ (id) formatWithFormat:(NSDictionary*)inFormat;


@end