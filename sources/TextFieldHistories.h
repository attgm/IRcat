//
//  $RCSfile: TextFieldHistories.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>


@interface TextFieldHistories : NSObject {
	NSMutableArray* _histories;
	int _historyIndex;
}


-(id) init;
-(void) dealloc;

-(void) addHistory:(NSString*) inMessage;
-(void) displayPrivHistory:(NSControl*) textField;
-(void) displayNextHistory:(NSControl*) textField;
-(void) enterHistory:(NSControl*) textField;
-(BOOL)	control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command;

@end
