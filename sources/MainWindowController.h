//
//  $RCSfile: MainWindowController.h,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>
#import <IRCMessage.h>
#import "ChannelWindowController.h"

@class IRcatInterface;
@class NickListView;
@class InputSheet;
@class PopSplitView;
@class ChannelModal;
@class ConsoleTextView;
@class BufferedFieldEditor;

@interface MainWindowController : ChannelWindowController
{
    IBOutlet ConsoleTextView*	_commonTextView;
	IBOutlet PopSplitView*		_paneSplitView;
 	
    IBOutlet NSTextField*		_menuCaption;
    IBOutlet NSPopUpButton*		_menuPopUp;
	IBOutlet NSTextField*		_menuTitle;
	IBOutlet NSWindow*			_menuSheet;
	
	NSMenu*		_channelMenu;
	NSString*	_topicString;
}


- (IBAction)switchChannelbyChannelPopup:(id)sender;

- (id) initWithInterface:(IRcatInterface*) inInterface;
- (void) createWindow;
- (void) setTopic:(NSString*)inString;

- (void) addMenuItem:(NSString*)inChannelName;
- (void) menuItemToSeparator : (int) inIndex;
- (void) renameMenuItem:(NSString*)inString atIndex:(int)inIndex;
- (void) removeLastMenuItem;
- (void) setMenuImage:(NSImage*)inImage atIndex:(int)inIndex;
- (void) setEnableMenuItem:(BOOL) inEnable atIndex:(int) inIndex;

- (void) switchChannel:(ChannelModal*) inNewChannel;

- (ChannelModal*) activeChannel;
- (void) setHasSession:(BOOL)inHasSession;
- (void) setDocumentView:(NSScrollView*) inChannelView;

- (void) askFromMenu:(NSMenu*) inMenu
			 withTag:(int) inDefaultTag
			 caption:(NSString*) inCaption
			format:(NSString*) inFormat;
- (void) sheetMenuDidEnd : (NSSavePanel *) inSheet
			  returnCode : (int) inReturnCode
			 contextInfo : (id) inContextInfo;
- (BOOL) appendStringToCommon:(NSAttributedString*)inString
                       append:(NSAttributedString*)inAppend
                           at:(int)inIndex;
- (void)focusTextField;

-(void) addMenuItemByChannelModal : (ChannelModal*) inChannelName;
-(ChannelModal*) selectedChannel;


- (NSToolbarItem*) toolbarItemByIdentifier:(NSString*) inIdentifier;
- (IBAction) actionToolbar: (id) sender;

- (NSToolbarItem*) toolbarTopicItem:(BOOL) flag;
- (NSToolbarItem*) toolbarChannelItem:(BOOL) flag;


@end
