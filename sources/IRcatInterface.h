//
//  $RCSfile: IRcatInterface.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>
#import "IRCMessage.h"

@class ChannelModal;
@class MainWindowController;
@class ChannelWindowController;
@class FormatTable;
@class ChannelModal;
@class IRCSession;
@class ServerModal;
@class BindingItem;

typedef enum {
	kPlainAttribute = 0,
	kTimeAttribute  = 1,
	kServerMessageAttribute = 2,
	kErrorMessageAttribute = 3
} MessageAttribute;
#define kMessageAttributeNum 4

@interface IRcatInterface : NSObject {
    MainWindowController* _mainWindowController;

    NSMutableArray* _channelList;
    NSMutableArray* _sessionList;
    NSMutableArray* _candidateChannel;    
    FormatTable* _formatTable;
    
    NSInteger _channelMenuOffset;
	ChannelWindowController* _keyWindowController;
	
	NSObjectController*	_preferenceController;
	
	NSMutableArray* _attributeList;
	NSDictionary*	_bindingItems;
}

-(NSObjectController*) sharedPreferenceController;

- (void) createNewSession;
- (void) createSession:(ServerModal*) inServer;
- (void) removeSessionByID : (NSInteger) inServerID;
- (void) disconnectSessionByID : (NSInteger) inServerID;
- (void) selectAndDisconnectSession;
-(void) sessionConditionChanged:(NSNotification*) sender;

- (void) selectAndCreateNewSession;
- (void) createNewChannel:(NSString*)inChannelName server:(NSInteger)inServerID;
- (void) createNewChannel:(NSString*)inChannelName server:(NSInteger)inServerID isActive:(BOOL)inActive;
- (void) removeAllChannelAt:(NSInteger)inServerID;
- (void) removeChannel:(NSString*)inChannelName server:(NSInteger)inServerID;
- (void) removeChannel:(ChannelModal*)inChannel;

- (ChannelModal*) findChannelWithName:(NSString*)inChannel server:(NSInteger)inServerID;
- (BOOL) switchChannelAtIndex:(NSInteger)inIndex;
- (ChannelModal*) channelAtIndex:(NSInteger)inIndex;
- (ChannelModal*) consoleChannelModal;
- (ChannelModal*) activeChannel;
- (IRCSession*) findSessionWithID:(NSInteger) inSessionID;
- (void) appendCandidateChannel:(NSString*) inChannelName;
- (ChannelModal*) reserveChannelModal:(NSString*) inChannelName server:(NSInteger) inServerID;
- (void) switchNextChannel;
- (void) switchPreviousChannel;

- (void) setFlag:(int)inFlag channel:(NSString*)inChannelName server:(NSInteger)inServerID nick:(NSString*)inNickname ison:(BOOL)inIsOn;
- (void) setChannelFlag:(unichar)inFlag channel:(NSString*)inChannelName server:(NSInteger)inServerID ison:(BOOL)inIsOn;

- (void) setTopic:(NSString*)inTopic channel:(NSString*)inChannel server:(NSInteger)inServerID; 

- (void) appendNick:(NSString*)inNick toChannel:(NSString*) inChannel server:(NSInteger) inServerID;
- (void) appendNicks:(NSArray*)inAppendNicks toChannel:(NSString*)inMessage server:(NSInteger)inServerID;
- (void) appendNick:(NSString*)inNick toChannelModal:(ChannelModal*)inChannelModal;
- (void) removeNick:(NSString*)inNick fromChannel:(NSString*) inChannel server:(NSInteger) inServerID;
- (void) removeNick:(NSString*)inNick server:(NSInteger) inServerID;
- (void) renameNick:(NSString*)inNick to:(NSString*)inNewNick server:(NSInteger)inServerID;
- (void) refleshNickList:(NSString*)inChannel server:(NSInteger)inServerID;

- (void) initChannelMenu;
- (void) channelMenuItemToSeparator:(NSInteger)inIndex;
- (void) addChannelMenuItem:(NSString*) inChannelName;
- (void) renameMenuItem:(NSString*)inString atIndex:(NSInteger) inIndex withID:(NSInteger)inChannelID;
- (void) removeLastChannelMenuItem;

- (void) refleshLogIcon;

//- (NSString*) targetChannelName;
- (NSInteger) activeServer;
- (void) enterMessageByString:(NSString*)inMessage to:(ChannelModal*)inChannel;
- (void) sendMessage:(NSString*)inMessage to:(ChannelModal*)inChannel;
- (NSMenu*) connectedServerMenu;


- (void) appendMessage:(IRCMessage*) inMessage format:(NSString*)inFormat;
- (void) appendMessageToConsole:(IRCMessage*) inMessage;
- (void) appendMessageToChannel:(IRCMessage*) inMessage;
- (void) appendMessageToJoinedChannel:(IRCMessage*) inMessage;

- (void) obeyJoin:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyPart:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyNick:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyQuit:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyWhois:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyTopic:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyMode:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyAction:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyNotice:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyInvite:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyCtcp:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyCommand:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;
- (void) obeyIRCCommand:(NSString*)inMessage;
- (void) obeyIRCCommand:(NSString*)inMessage to:(ChannelModal*)inChannelModal;
- (void) obeyDisconnect:(NSString*)inParams server:(NSInteger)inServerID channel:(ChannelModal*)inChannelModal;

- (void) performContextMenu:(NSString*)inCommand context:(NSArray*)inContext channel:(ChannelModal*)inChannel;
-(void) tearChannel:(ChannelModal*) inChannelModal;
-(BOOL) isActiveChannel:(ChannelModal*) inChannelModal;

-(void) setKeyWindowController:(ChannelWindowController*) inWindowController;


-(void) syncTextFont:(BindingItem*) item;
-(void) syncTextColor:(BindingItem*) item;


@end
