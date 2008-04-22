//
//  $RCSfile: ApplicationController.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>

// menu tag
enum {
	mt_connect		= 100,
	mt_connect_to	= 101,
	mt_disconnect   = 102,
	mt_preferences  = 200,
	mt_logging		= 150
};

@class IRcatInterface;

@interface ApplicationController : NSObject
{
    IBOutlet IRcatInterface *_interface;

#ifdef NOG_PATCH
	NSMutableArray* mList;
#endif
}
- (IBAction)nextChannel:(id)sender;
- (IBAction)obeyCommand:(id)sender;
- (IBAction)obeyConnect:(id)sender;
- (IBAction)obeyConnectTo:(id)sender;
- (IBAction) obeyDisconnect : (id) sender;
- (IBAction)previousChannel:(id)sender;
- (IBAction)showPreferenceDialog:(id)sender;
- (IBAction)showServerSetupDialog:(id)sender;
- (IBAction)startLogging:(id)sender;
- (IBAction)testAction:(id)sender;

- (void) applicationDidFinishLaunching : (NSNotification *) aNotification;
- (void) applicationWillTerminate : (NSNotification *) aNotification;

#ifdef NOG_PATCH
- (IRcatInterface*) getActiveInterface;
#endif
@end
