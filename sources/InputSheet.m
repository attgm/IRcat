//
//  $RCSfile: InputSheet.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "InputSheet.h"

OneInputSheet* sOneInputSheet = nil;
TwoInputsSheet* sTwoInputsSheet = nil;
JoinInputsSheet* sJoinInputsSheet = nil;

@implementation InputSheet

//-- sheet
// sheetを返す
- (NSWindow*) sheet
{
	return _inputSheet;
}


//-- applySheet
- (IBAction)applySheet:(id)sender
{
    [[NSApplication sharedApplication] endSheet:_inputSheet returnCode:NSOKButton];
}


//-- cancelSheet
- (IBAction)cancelSheet:(id)sender
{
    [[NSApplication sharedApplication] endSheet:_inputSheet returnCode:NSCancelButton];
}

@end

#pragma mark -

@implementation OneInputSheet
//-- sharedInputSheet
+ (OneInputSheet*) sharedOneInputSheet
{
	if(!sOneInputSheet){
		sOneInputSheet = [[OneInputSheet alloc] init];
	}
	return sOneInputSheet;
}


//-- init
// 初期化
- (id) init
{
	self = [super init];
    if(self != nil){
        if (![NSBundle loadNibNamed:@"OneInputSheet" owner:self]) {
            NSLog(@"Failed to load OneInputSheet.nib");
            NSBeep();
            [self release];
            return nil;
        }
        
        [_serverTitleField setStringValue:NSLocalizedString(@"Server :", @"Server :")];
    }
	return self;
}

#pragma mark -
//-- setCaption
// captionの設定
- (void) setCaption:(NSString*) inCaption
{
	[_captionField setStringValue:inCaption];
}


//-- setTitle:default
// タイトルとデフォルトの指定
- (void) setTitle:(NSString*) inTitle
			value:(NSString*) inValue
{
	[_titleField setStringValue:inTitle];
	[_textField setStringValue:inValue];
}


//-- setServerMenu
// サーバメニューの設定
- (void) setServerMenu:(NSMenu*) inMenu
				 value:(NSInteger) inServerID
{
	[_serverPopUp setMenu:inMenu];
	NSMenuItem* item = [inMenu itemWithTag:inServerID];
	if (item) {
		[_serverPopUp selectItem:item];
	}
}

//-- setFormat
// formatの設定
- (void) setFormat:(NSString*)inString
{
	if (_format) [_format release];
	_format = [inString copyWithZone:[self zone]];
}


//-- resetFirstResponder
// firstResponderの設定
- (void) resetFirstResponder
{
	[_inputSheet makeFirstResponder:_textField];
}

#pragma mark -
//-- setAction:target:reverse
// actionの設定
- (void) setAction:(SEL) inSelector
			target:(id) inTarget
{
	_selector = inSelector;
	_actionTarget = inTarget;
}


//-- performAction
// actionの実行
- (void) performAction
{
	[_actionTarget performSelector:_selector
				  withObject:[NSString stringWithFormat:_format, [[_serverPopUp selectedItem] tag], [_textField stringValue]]];
}



/*
[[NSApplication sharedApplication] beginSheet:mTwoInputSheet
							   modalForWindow:mWindow
								modalDelegate:self
							   didEndSelector:@selector(sheetTwoDidEnd:returnCode:contextInfo:)
								  contextInfo:[inFormat copyWithZone:[self zone]]];
*/

@end


#pragma mark -

@implementation TwoInputsSheet
//-- sharedInputsSheet
+ (TwoInputsSheet*) sharedTwoInputsSheet
{
	if(!sTwoInputsSheet){
		sTwoInputsSheet = [[TwoInputsSheet alloc] init];
	}
	return sTwoInputsSheet;
}


//-- init
// 初期化
- (id) init
{
	self = [super init];
    if(self == nil) return nil;
    
	if (![NSBundle loadNibNamed:@"TwoInputsSheet" owner:self]) {
		NSLog(@"Failed to load TwoInputsSheet.nib");
		NSBeep();
		[self release];
		return nil;
	}
	[_serverTitleField setStringValue:NSLocalizedString(@"Server :", @"Server :")];
	return self;
}


#pragma mark -
//-- setCaption
// captionの設定
- (void) setCaption:(NSString*) inCaption
{
	[_captionField setStringValue:inCaption];
}


//-- setTitle1:default
// タイトルとデフォルトの指定
- (void) setFirstTitle:(NSString*) inTitle
				 value:(NSString*) inValue
{
	[_titleField1 setStringValue:inTitle];
	[_textField1 setStringValue:inValue];
}


//-- setTitle2:value:password
// タイトルとデフォルトの指定
- (void) setSecondTitle:(NSString*) inTitle
				  value:(NSString*) inValue
{
	[_titleField2 setStringValue:inTitle];
	[_textField2 setStringValue:inValue];
}


//-- setServerMenu
// サーバメニューの設定
- (void) setServerMenu:(NSMenu*) inMenu
				 value:(NSInteger) inServerID
{
	[_serverPopUp setMenu:inMenu];
	NSMenuItem* item = [inMenu itemWithTag:inServerID];
	if (item) {
		[_serverPopUp selectItem:item];
	}
}


//-- setFormat
// formatの設定
- (void) setFormat:(NSString*)inString
		   reverse:(BOOL)inReverse
{
	if (_format) [_format release];
	_format = [inString copyWithZone:[self zone]];
	mReverse = inReverse;
}


//-- resetFirstResponder
// firstResponderの設定
- (void) resetFirstResponder
{
	[_inputSheet makeFirstResponder:_textField1];
}


#pragma mark -
//-- setAction:target:reverse
// actionの設定
- (void) setAction:(SEL) inSelector
			target:(id) inTarget
{
	_selector = inSelector;
	_actionTarget = inTarget;
}


//-- performAction
// actionの実行
- (void) performAction
{
	NSString* string = [_textField2 stringValue];
	NSString* command = mReverse ?
		[NSString stringWithFormat:_format, [[_serverPopUp selectedItem] tag], string, [_textField1 stringValue]] :
		[NSString stringWithFormat:_format, [[_serverPopUp selectedItem] tag], [_textField1 stringValue], string];
	[_actionTarget performSelector:_selector withObject:command];
}

@end



#pragma mark -

@implementation JoinInputsSheet
//-- sharedJoinInputsSheet
+ (JoinInputsSheet*) sharedJoinInputsSheet
{
	if(!sJoinInputsSheet){
		sJoinInputsSheet = [[JoinInputsSheet alloc] init];
	}
	return sJoinInputsSheet;
}


//-- init
// 初期化
- (id) init
{
	self = [super init];
    if(self == nil) return nil;
    
	if (![NSBundle loadNibNamed:@"JoinInputsSheet" owner:self]) {
		NSLog(@"Failed to load JoinInputsSheet.nib");
		NSBeep();
		[self release];
		return nil;
	}
	[_serverTitleField setStringValue:NSLocalizedString(@"Server :", @"Server :")];
	return self;
}


#pragma mark -
//-- setCaption
// captionの設定
- (void) setCaption:(NSString*) inCaption
{
	[_captionField setStringValue:inCaption];
}


//-- setTitle1:default
// タイトルとデフォルトの指定
- (void) setFirstTitle:(NSString*) inTitle
				 value:(NSString*) inValue
{
	[_titleField1 setStringValue:inTitle];
	[_comboBox1 setStringValue:inValue];
}


//-- setCandidateChannels
// チャンネル候補の設定
- (void) setCandidateChannels:(NSArray*) inChannels
{
	[_comboBox1 removeAllItems];
	[_comboBox1 addItemsWithObjectValues:inChannels];
}



//-- setTitle2:value:password
// タイトルとデフォルトの指定
- (void) setSecondTitle:(NSString*) inTitle
				  value:(NSString*) inValue
{
	[_titleField2 setStringValue:inTitle];
	[_textField2 setStringValue:inValue];
}



//-- setServerMenu
// サーバメニューの設定
- (void) setServerMenu:(NSMenu*) inMenu
				 value:(NSInteger) inServerID
{
	[_serverPopUp setMenu:inMenu];
	NSMenuItem* item = [inMenu itemWithTag:inServerID];
	if (item) {
		[_serverPopUp selectItem:item];
	}
}


//-- setFormat
// formatの設定
- (void) setFormat:(NSString*)inString
		   reverse:(BOOL)inReverse
{
	if (_format) [_format release];
	_format = [inString copyWithZone:[self zone]];
	mReverse = inReverse;
}


//-- resetFirstResponder
// firstResponderの設定
- (void) resetFirstResponder
{
	[_inputSheet makeFirstResponder:_comboBox1];
}


#pragma mark -
//-- setAction:target:reverse
// actionの設定
- (void) setAction:(SEL) inSelector
			target:(id) inTarget
{
	_selector = inSelector;
	_actionTarget = inTarget;
}


//-- performAction
// actionの実行
- (void) performAction
{
	NSString* string = [_textField2 stringValue];
	NSString* command = mReverse ?
		[NSString stringWithFormat:_format, [[_serverPopUp selectedItem] tag], string, [_comboBox1 stringValue]] :
		[NSString stringWithFormat:_format, [[_serverPopUp selectedItem] tag], [_comboBox1 stringValue], string];
	[_actionTarget performSelector:_selector withObject:command];
}

@end