//
//  AcknowledgmentsWindowController.m
//  ircat
//
//  Created by Atsushi on 2012/08/16.
//
//

#import "AcknowledgmentsWindowController.h"


@implementation AcknowledgmentsWindowController
@synthesize acknowledgmentText = _acknowledgmentText;
@synthesize acknowledgmentsWindow = _acknowledgmentsWindow;


//-- init
//
-(id) init
{
    self = [super init];
    if(self != nil){
        self.acknowledgmentsWindow = nil;
    }
    return self;
}


//-- dealloc
//
-(void) dealloc
{
    self.acknowledgmentsWindow = nil;
    [super dealloc];
}


//-- showWindow
// create window and show window
- (void)showWindow
{
    if (self.acknowledgmentsWindow == nil) {
		if(![NSBundle loadNibNamed:@"AcknowledgmentsWindow" owner:self]){
			NSLog(@"Failed to load AcknowledgmentsWindow.xib");
			return;
		}

        [_acknowledgmentText readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"Acknowledgments" ofType:@"rtf"]];
        
	}
    [self.acknowledgmentsWindow center];
	[self.acknowledgmentsWindow makeKeyAndOrderFront:nil];
}


#pragma mark Window Delegate
- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"close");
    self.acknowledgmentsWindow = nil;
}

@end
