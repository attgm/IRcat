//
//  $RCSfile: ChannelViewController.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>
#import "ScrollView.h"

@class IRcatInterface;
@class ChannelModal;
@class ConsoleTextView;
@class InputField;

@interface ChannelViewController : NSObject
{
    IBOutlet ConsoleTextView*	_channelView;
    IBOutlet NSButton*		_latchButton;
    IBOutlet ScrollView*	_scrollView;
    IBOutlet NSButton*		_tearButton;
    
    NSCellStateValue	_lockedScroll;
	
	ChannelModal* _channelModal;
	IRcatInterface* _interface;
}


-(IBAction) setTearSwitch:(id) sender;

-(id) initWithInterface:(IRcatInterface*) inInterface;
-(void) dealloc;

-(void) setInterface:(IRcatInterface*) inInterface;
-(void) setChannelModal:(ChannelModal*) inChannelModal;

- (void) createChannelView;
- (void) didScroll : (NSNotification*) inNote;
- (id) channelView;
-(void) moveToEndOfDocument;

- (BOOL) appendString:(NSAttributedString*)inString
               append:(NSAttributedString*)inAppend
                   at:(int)inAppendIndex;
- (void) removeAllString;

-(void) setLockedScroll:(NSCellStateValue) value;
-(NSCellStateValue) lockedScroll;


@end

