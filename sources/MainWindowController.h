//
//  $RCSfile: MainWindowController.h,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>
#import "IRCMessage.h"
#import "ChannelWindowController.h"

@class IRcatInterface;
@class NickListView;
@class InputSheet;
@class PopSplitView;
@class ChannelModal;
@class ConsoleTextView;
@class BufferedFieldEditor;
@class TextFieldHistories;

@interface MainWindowController : ChannelWindowController <NSToolbarDelegate>
{
    IBOutlet ConsoleTextView*	_commonTextView;
	IBOutlet PopSplitView*		_paneSplitView;
 	IBOutlet NSSplitView*       _channelSplitView;
    
    IBOutlet NSTextField*		_menuCaption;
    IBOutlet NSPopUpButton*		_menuPopUp;
	IBOutlet NSTextField*		_menuTitle;
	IBOutlet NSWindow*			_menuSheet;
	
    IBOutlet NSView*            _contentsView;
    
	NSMenu*		_channelMenu;
	NSString*	_topicString;
    
    TextFieldHistories* _textFieldHistories;
    NSPopUpButton*      _channelPopup;
    NSTextField*        _topicTextField;
}


-(IBAction) switchChannelbyChannelPopup:(id)sender;
-(IBAction) collapseChannelSplitView:(id)sender;

-(id) initWithInterface:(IRcatInterface*) inInterface;
-(void) createWindow;
-(void) setTopic:(NSString*)inString;

-(void) addMenuItem:(NSString*)inChannelName;
-(void) menuItemToSeparator : (NSInteger) inIndex;
-(void) renameMenuItem:(NSString*)inString atIndex:(NSInteger)inIndex;
-(void) removeLastMenuItem;
-(void) setMenuImage:(NSImage*)inImage atIndex:(NSInteger)inIndex;
-(void) setEnableMenuItem:(BOOL) inEnable atIndex:(NSInteger) inIndex;

-(void) switchChannel:(ChannelModal*) inNewChannel;

-(ChannelModal*) activeChannel;
-(void) setHasSession:(BOOL)inHasSession;
-(void) setDocumentView:(NSScrollView*) inChannelView;

-(void) askFromMenu:(NSMenu*) inMenu
			 withTag:(NSInteger) inDefaultTag
			 caption:(NSString*) inCaption
			format:(NSString*) inFormat;
-(void) sheetMenuDidEnd : (NSSavePanel *) inSheet
			  returnCode : (int) inReturnCode
			 contextInfo : (id) inContextInfo;
-(BOOL) appendStringToCommon:(NSAttributedString*)inString
                       append:(NSAttributedString*)inAppend
                           at:(NSInteger)inIndex;
-(void)focusTextField;

-(void) addMenuItemByChannelModal : (ChannelModal*) inChannelName;
-(ChannelModal*) selectedChannel;


-(NSToolbarItem*) toolbarItemByIdentifier:(NSString*) inIdentifier;
-(IBAction) actionToolbar: (id) sender;

-(NSToolbarItem*) toolbarTopicItem:(BOOL) flag;
-(NSToolbarItem*) toolbarChannelItem:(BOOL) flag;

@end
