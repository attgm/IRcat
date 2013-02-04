//
//  $RCSfile: IRCMessage.h,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>

#import "FormatItem.h"


typedef enum {
    IRC_CommandMessage,
    IRC_ReplyMessage,
    IRC_ErrorMessage
} IRCMessageType;

@interface IRCMessage : NSObject {
    NSInteger _serverid;
    
    NSString*	_commandNumber;
    IRCMessageType _messageType;
    //int _commandNumber;
    
    NSString*		_message;
    NSString*		_nickname;
    NSString*		_hostname;
    NSString*		_channelname;
    NSString*		_trailing;
    NSMutableArray* _paramList;

    NSAttributedString* _expandedMessage;
    NSAttributedString* _commonMessage;
    NSAttributedString* _additionalMessage;
	NSString* _extendString;
	NSUInteger _additionalIndex;
    NSUInteger _commonAdditionalPosition;
    NSUInteger _additionalPosition;
	
    NSColor*    _notificationColor;
    BOOL _useNotification;
}



- (id) initWithMessage:(NSString*)inMessage server:(NSInteger)inServerID;

- (void) parsePrefix;
- (void) parseParams;
- (void) devideTrailingBy:(NSString*) inDevider;

- (BOOL) isCtcpCommand;

- (NSString*) applyFormat : (FormatItem*) inFormat
			   attributes : (NSArray*) inAttributes;
- (NSAttributedString*) expandedMessage;
- (NSAttributedString*) additionalMessage;
- (NSAttributedString*) commonMessage;
- (NSUInteger) commonAdditionalPosition;
- (NSUInteger) additionalPosition;
- (NSString*) channel;

- (NSAttributedString*) expandFormat:(NSString*)inFormat
						attributes : (NSArray*) inAttributes
						 appendEnter:(BOOL)inNeedEnter;

- (NSInteger) serverid;
- (NSString*) paramAtIndex:(int) inIndex;
- (NSString*) nickname;
- (NSString*) timeString;
- (NSString*) commandNumber;
- (void) setExtendString:(NSString*) inString;
- (void) setNotificationColor:(NSColor*) inNotifyColor;
- (void) setUseNotification:(BOOL) inUseNotification;
- (BOOL) useNotification;
- (IRCMessageType) messageType;

- (void) filterMessage:(NSMutableAttributedString*) inMessage range:(NSRange)inRange;
- (void) notifyMessage:(NSMutableAttributedString*) inMessage range:(NSRange)inRange;
- (void) parseKeyword:(NSMutableAttributedString*) inMessage range:(NSRange) inRange;
- (void) parseURL:(NSMutableAttributedString*) inMessage range:(NSRange)inRange;
-(NSCharacterSet*) urlCharacterSet;

@end

@interface NSMutableAttributedString (IRcat_Addition)
- (void) appendString:(NSString*)inString attributes:(NSDictionary*)inAttribute;
@end