//
//  $RCSfile: ServerWindowController.h,v $
//  
//  $Revision: 48 $
//  $Date: 2008-04-15 11:21:38 +0900 (Tue, 15 Apr 2008) $
//

#import <Cocoa/Cocoa.h>
#import "ServersModal.h"
#import "EditCellController.h"
#import "ServersController.h"


@interface ServerSetupController : NSObject
{
	IBOutlet NSPopUpButton *_encordingPopup;
    IBOutlet NSPopUpButton *_serverLabelPopup;
    
	
	IBOutlet NSWindow *_serverSetupWindow;
	IBOutlet NSDrawer *_serverListDrawer;
	
	IBOutlet ServersController*		_serversController;
	IBOutlet EditCellController*	_autoJoinChannelsController;
    NSMutableDictionary *mToolbarItems;
    
    ServersModal* _serversModal;
}


- (IBAction)openDrawer:(id)sender;
- (IBAction)pressOkey:(id)sender;

-(ServersModal*) serversModal;

- (id) init;
+ (id) sharedPreference;
- (void) showPanel;
- (void) saveDefaults;

- (void) createToolbar;
- (void) createLabelPopup;
- (void) createEncordingPopup;

- (void) updateUI;

- (ServersModal*) serversModal;
- (NSDictionary*) serverForID:(int) inIdentifier;

@end
