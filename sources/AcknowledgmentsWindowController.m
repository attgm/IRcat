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


//-- init
//
-(id) init
{
    self = [super init];
    if(self != nil){
        self.window = nil;
    }
    NSLog(@"hoge");
    return self;
}


//-- dealloc
//
-(void) dealloc
{
    self.window = nil;
    [super dealloc];
}


//-- showWindow
// create window and show window
- (void)showWindow
{
    if (self.window == nil) {
        NSLog(@"create window");
		if(![NSBundle loadNibNamed:@"AcknowledgmentsWindow" owner:self]){
			NSLog(@"Failed to load AcknowledgmentsWindow.xib");
			return;
		}

        [_acknowledgmentText readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"Acknowledgments" ofType:@"rtf"]];
        
	}
    [self.window center];
	[self.window makeKeyAndOrderFront:nil];
}


#pragma mark Window Delegate
- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"close");
    self.window = nil;
}

@end
