//
//  $RCSfile: ServersController.h,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>


@interface ServersController : NSArrayController {
	IBOutlet NSTableView* _primeTableView;
}

- (IBAction) addItem:(id)sender;

@end
