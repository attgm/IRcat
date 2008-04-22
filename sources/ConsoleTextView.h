//
//  $RCSfile: ConsoleTextView.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <AppKit/AppKit.h>


@interface ConsoleTextView : NSTextView {
	id _observedControllerForUrlColor;
	NSString* _observedKeyPathForUrlColor;
	NSString* _urlColorTransformerName;

	id _observedControllerForFont;
	NSString* _observedKeyPathForFont;
	NSString* _fontTransformerName;
	
	NSAttributedString* _appendString;
	int _appendIndex;
	int _lines;
}


-(void) setObservedControllerForUrlColor:(id) controller;
-(void) setObservedKeyPathForUrlColor:(NSString*) keypath;
-(void) setUrlColorTransformerName:(NSString*) name;
-(void) syncUrlColorToController;


-(void) setObservedControllerForFont:(id) controller;
-(void) setObservedKeyPathForFont:(NSString*) keypath;
-(void) setFontTransformerName:(NSString*) name;
-(void) syncFontToController;

- (BOOL) appendString:(NSAttributedString*)inString
			   append:(NSAttributedString*)inAppend
				   at:(int)inAppendIndex
		   scrollLock:(BOOL) inScrollLock;

-(void) keyDown:(NSEvent*) event;
@end
