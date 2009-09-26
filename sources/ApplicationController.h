//
//  $RCSfile: ApplicationController.h,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>

// menu tag
enum {
	IRMenuTagConnect		= 100,
	IRMenuTagConnectTo		= 101,
	IRMenuTagDisconnect		= 102,
	IRMenuTagPreferences	= 200,
	IRMenuTagLogging		= 150
};

@class IRcatInterface;

@interface ApplicationController : NSObject
{
    IBOutlet IRcatInterface *_interface;
}


- (IBAction)nextChannel:(id)sender;
- (IBAction)obeyCommand:(id)sender;
- (IBAction)obeyConnect:(id)sender;
- (IBAction)obeyConnectTo:(id)sender;
- (IBAction)obeyDisconnect : (id) sender;
- (IBAction)previousChannel:(id)sender;
- (IBAction)showPreferenceDialog:(id)sender;
- (IBAction)showServerSetupDialog:(id)sender;
- (IBAction)startLogging:(id)sender;
- (IBAction)testAction:(id)sender;

- (void) applicationDidFinishLaunching : (NSNotification *) aNotification;
- (void) applicationWillTerminate : (NSNotification *) aNotification;

@end
