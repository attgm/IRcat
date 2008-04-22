//
//  BufferedFieldEditor.h
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>

@interface BufferedFieldEditor : NSTextView {
	NSEvent*		_firstKeyEvent;
	NSTextField*	_keyView;
}

-(void) setFirstKeyEvent:(NSEvent*) event;
-(void) performFirstKeyEvent:(id) sender;
-(void) keyDown:(NSEvent*) event;

-(id) keyView;
-(void) setKeyView:(id) keyView;

@end
