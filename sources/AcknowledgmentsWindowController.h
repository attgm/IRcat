//
//  AcknowledgmentsWindowController.h
//  ircat
//
//  Created by Atsushi on 2012/08/16.
//
//

#import <Cocoa/Cocoa.h>

@interface AcknowledgmentsWindowController : NSObject<NSWindowDelegate>

@property (nonatomic, strong) IBOutlet NSWindow* window;
@property (nonatomic, assign) IBOutlet NSTextView* acknowledgmentText;


- (id)init;
- (void)dealloc;

- (void)showWindow;

@end
