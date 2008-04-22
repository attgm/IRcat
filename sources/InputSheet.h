//
//  $RCSfile: InputSheet.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <AppKit/AppKit.h>

@interface InputSheet : NSObject {
	IBOutlet NSWindow *_inputSheet;
}

- (NSWindow*) sheet;

- (IBAction)applySheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;

@end


@interface OneInputSheet : InputSheet {
	IBOutlet NSTextField *_captionField;
    IBOutlet NSTextField *_textField;
    IBOutlet NSPopUpButton *_serverPopUp;
    IBOutlet NSTextField *_titleField;
	IBOutlet NSTextField *_serverTitleField;
	
	NSString* _format;
	SEL _selector;
	id _actionTarget;
}

+ (OneInputSheet*) sharedOneInputSheet;
- (id) init;

- (void) setCaption:(NSString*) inCaption;
- (void) setTitle:(NSString*) inTitle value:(NSString*) inValue;
- (void) setServerMenu:(NSMenu*) inMenu value:(int) inServerID;
- (void) setFormat:(NSString*) inString;
- (void) resetFirstResponder;

- (void) setAction:(SEL)inSelector target:(id)inTarget;
- (void) performAction;
@end


@interface TwoInputsSheet : InputSheet {
	IBOutlet NSTextField *_captionField;
    IBOutlet NSTextField *_textField1;
    IBOutlet NSTextField *_textField2;
    IBOutlet NSPopUpButton *_serverPopUp;
    IBOutlet NSTextField *_titleField1;
    IBOutlet NSTextField *_titleField2;
	IBOutlet NSTextField *_serverTitleField;

	NSString* _format;
	BOOL mReverse;
	
	SEL _selector;
	id _actionTarget;
}

+ (TwoInputsSheet*) sharedTwoInputsSheet;
- (id) init;

- (void) setCaption:(NSString*) inCaption;
- (void) setFirstTitle:(NSString*) inTitle value:(NSString*) inValue;
- (void) setSecondTitle:(NSString*) inTitle value:(NSString*) inValue;
- (void) setServerMenu:(NSMenu*) inMenu value:(int) inServerID;
- (void) setFormat:(NSString*)inString reverse:(BOOL)inReverse;
- (void) resetFirstResponder;

- (void) setAction:(SEL)inSelector target:(id)inTarget;
- (void) performAction;
@end



@interface JoinInputsSheet : InputSheet {
	IBOutlet NSTextField *_captionField;
    IBOutlet NSComboBox *_comboBox1;
    IBOutlet NSSecureTextField *_textField2;
    IBOutlet NSPopUpButton *_serverPopUp;
    IBOutlet NSTextField *_titleField1;
    IBOutlet NSTextField *_titleField2;
	IBOutlet NSTextField *_serverTitleField;
	
	NSString* _format;
	BOOL mReverse;
	
	SEL _selector;
	id _actionTarget;
}

+ (JoinInputsSheet*) sharedJoinInputsSheet;
- (id) init;

- (void) setCaption:(NSString*) inCaption;
- (void) setFirstTitle:(NSString*) inTitle value:(NSString*) inValue;
- (void) setCandidateChannels:(NSArray*) inChannels;
- (void) setSecondTitle:(NSString*) inTitle value:(NSString*) inValue;
- (void) setServerMenu:(NSMenu*) inMenu value:(int) inServerID;
- (void) setFormat:(NSString*)inString reverse:(BOOL)inReverse;
- (void) resetFirstResponder;

- (void) setAction:(SEL)inSelector target:(id)inTarget;
- (void) performAction;
@end
