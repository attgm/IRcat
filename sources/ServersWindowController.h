//
//  $RCSfile: ServersWindowController.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>
#import "ServersModal.h"
#import "EditCellController.h"
#import "ServersController.h"


@interface ServersWindowController : NSObject
{
	IBOutlet NSPopUpButton *_encordingPopUp;
    IBOutlet NSPopUpButton *_serverLabelPopUp;
    	
	IBOutlet NSWindow *_serverSetupWindow;
	
	IBOutlet ServersController*		_serversController;
	IBOutlet EditCellController*	_autoJoinChannelsController;

	NSMutableDictionary *_toolbarItems;
    ServersModal* _serversModal;
}


- (IBAction)pressOkey:(id)sender;

-(ServersModal*) serversModal;

- (id) init;
+ (id) sharedPreference;
- (void) showPanel;
- (void) saveDefaults;

- (void) createLabelPopUp;
- (void) createEncordingPopUp;

@end
