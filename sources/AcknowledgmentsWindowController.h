//
//  AcknowledgmentsWindowController.h
//  ircat
//
//  Created by Atsushi on 2012/08/16.
//
//

#import <Cocoa/Cocoa.h>

@interface AcknowledgmentsWindowController : NSObject<NSWindowDelegate>
{
    NSTextView* _acknowledgmentText;
    NSWindow* _acknowledgmentsWindow;
}

@property (nonatomic, strong) IBOutlet NSWindow* acknowledgmentsWindow;
@property (nonatomic, assign) IBOutlet NSTextView* acknowledgmentText;


- (id)init;
- (void)dealloc;

- (void)showWindow;

@end
