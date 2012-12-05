//
//  $RCSfile: ChannelWindowController.h,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//


#import <Cocoa/Cocoa.h>

@class IRcatInterface;
@class NickListView;
@class InputSheet;
@class PopSplitView;
@class ChannelModal;
@class BufferedFieldEditor;

@interface ChannelWindowController : NSObject
{
    IBOutlet NSClipView *_channelClipView;
	IBOutlet NSTextField *_inputField;
    IBOutlet NSImageView *_logImage;
    IBOutlet NSTextField *_modeTextView;
    IBOutlet NickListView *_nickListView;
    IBOutlet PopSplitView *_popSplitView;
    IBOutlet NSWindow *_window;
    NSWindow* _activeSheet;
	
	IRcatInterface* _interface;
	ChannelModal* _activeChannel;
	
	BufferedFieldEditor* _fieldEditor;
}

- (IBAction)applySheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;
- (IBAction)enterMessage:(id)sender;

- (id) initWithInterface:(IRcatInterface*) inInterface;
- (void) dealloc;


-(NSObjectController*) preferenceController;

-(void) createWindow;

- (NSInteger) selectedIndexOnNickList;
- (void) showSheet:(InputSheet*) inSheetl;


- (void) updatePreferences:(NSNotification*) notification;

- (void) refleshNickList;
- (void) refleshLogIcon;
- (void) focusTextField;
- (void) setTopic:(NSString*) inTopic;
- (void) setModeString:(NSString*)inModeString;

- (void) switchChannel:(ChannelModal*) inChannelModal;
- (void) setActiveChannel:(ChannelModal*) inChannelModal;
- (ChannelModal*) activeChannel;
- (void) setDocumentView:(NSScrollView*) inChannelView;


-(id) fieldEditor;
-(id) windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id) obj;

@end
