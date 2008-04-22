//
//  $RCSfile: ChannelModal.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>

@class ChannelViewController;
@class NickListItem;

typedef enum {
    flag_Nothing		= 0,
    flag_Operator		= 1 << 0,
    flag_SpeakAbility 	= 1 << 1,
    flag_Connecting		= 1 << 3,
    flag_Connected		= 1 << 4 
} UserFlag;

@class ChannelWindowController;

@interface ChannelModal : NSObject {
    NSString* _channelName;
    NSString* _aliasName;
	
    int	_serverID;
    int _channelID;
    
    NSString* _topic;
    NSString* _iconName;
	NSMutableArray* _nickList;
    NSMutableArray* _channelMode;
	
    BOOL _isTearOff;
    BOOL _isEmptyChannel; 
    BOOL _isLogging;
	
    NSFileHandle* _logFile;
	NSString*	_logFileDate;
	
    ChannelViewController* _viewController;
	ChannelWindowController* _windowController;
}

- (id) init;
- (id) initWithName:(NSString*) inChannelName
           identify:(int) inChannelID
             server:(int) inServerID;
- (void) dealloc;

- (BOOL) compareForName:(NSString*)inChannelName server:(int)inServerID;

- (BOOL) isJoined:(NSString*)inNick;
- (NickListItem*) findNick:(NSString*) inNick;
- (void) appendNick:(NSString*)inNick flag:(int)inFlag;
- (void) appendNick:(NSString*)inNick label:(NSString*)inString flag:(int)inFlag;
- (BOOL) renameNick:(NSString*)inNick to:(NSString*)inNewNick;
- (BOOL) removeNick:(NSString*)inNick;
- (BOOL) setFlag:(UserFlag)inFlag nick:(NSString*)inNick ison:(BOOL)inIsOn;
- (void) setChannelFlag:(unichar)inFlag ison:(BOOL)inIsOn;
- (NSString*) channelFlagString;

- (void) setChannelName:(NSString*)inChannelName;
- (void) setTopic:(NSString*) inChannelTopic;
- (void) setEmptyChannel:(BOOL) inEmpty;
- (void) setLoggingChannel:(BOOL) inLogging;
- (void) clearChannel:(NSString*)inChannelName server:(int)inServerID;

- (BOOL) loggingChannel;
- (NSString*) name;
- (NSString*) aliasName;
- (void) setAliasName:(NSString*)inChannelName;
- (NSString*) topic;
- (int) serverid;
- (int) channelid;
- (id) channelView;
- (BOOL) isEmptyChannel;
- (BOOL) isActiveChannel;
- (BOOL) isConsole;
- (BOOL) windowType;

- (NSString*) iconName;
- (void) setIconName:(NSString*)name;

- (BOOL) appendString:(NSAttributedString*)inString;
- (BOOL) appendString:(NSAttributedString*)inString
               append:(NSAttributedString*)inAppend
                   at:(int)inAppendIndex;
- (void) loggingMessage:(NSString*) inMessage;
- (NSString*) logDateString;
- (BOOL) createLogFile;

- (NSArray*) arraySelected:(NSIndexSet*) inSet;
- (NSString*) stringSelected:(int) inIndex;


-(ChannelWindowController*) channelWindowController;
-(void) setChannelWindowController:(ChannelWindowController*) inController;
-(ChannelViewController*) channelViewController;
-(void) setChannelViewController:(ChannelViewController*) inViewController;


//-(void) setValue:(id)value forKey:(NSString*)key;
//-(id) valueForKey:(NSString*)key;

@end
