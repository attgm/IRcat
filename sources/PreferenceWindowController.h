//
//  $RCSfile: PreferenceWindowController.h,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>
#import "PreferenceConstants.h"
#import "PreferenceModal.h"
#import "EditCellController.h"


@interface PreferenceWindowController : NSObject <NSToolbarDelegate>
{
    IBOutlet NSPopUpButton *_beepMenu;
    IBOutlet EditCellController *_friendsController;
    IBOutlet EditCellController *_keywordsController;
    IBOutlet EditCellController *_logChannelsController;
    IBOutlet NSView *_panelBase;
    IBOutlet NSView *_panelEtc;
    IBOutlet NSView *_panelFont;
    IBOutlet NSView *_panelFriends;
    IBOutlet NSView *_panelLog;
    IBOutlet NSView *_panelNotification;
    IBOutlet NSView *_panelUserInfo;
    IBOutlet NSView *_panelView;
    IBOutlet NSObjectController *_preferenceController;
    IBOutlet NSWindow *_preferenceWindow;
	
	PreferenceModal* _preferenceModal;
	NSDictionary*	_panelViews;
	NSView*			_displayedPanel;
	
	NSMutableDictionary* _toolbarItems;
}

- (IBAction) playSelectedSound:(id)sender;
- (IBAction) selectLogFolder:(id)sender;
- (IBAction) switchPrefPanel:(id) sender;

- (id) init;

- (NSString*) realChannelName:(NSString*)inString;
- (NSString*) aliasChannelName:(NSString*)inString safe:(BOOL)inSafeChannel;

- (BOOL) isLoggingChannel:(NSString*) inChannelName;

+ (id) sharedPreference;
+ (id) preferenceForKey : (NSString*) inKey;

- (void) saveDefaults;
- (void) showPanel;
- (void) createSoundMenu;
- (void) createToolbar;
- (void) switchPrefPanelById:(NSString*) identifier
					 animate:(BOOL) animate;

@end
