//
//  NotificationController.h
//  ircat
//
//

#import <Cocoa/Cocoa.h>

@interface NotificationController : NSArrayController {
    
}

-(IBAction) addItem:(id)sender;
-(IBAction) removeSelectedItem:(id)sender;

- (BOOL) canRemove;
@end
