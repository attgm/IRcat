//
//  $RCSfile: TextFieldHistories.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import "PreferenceModal.h"
#import "TextFieldHistories.h"


@implementation TextFieldHistories 
//-- init
// 初期化
-(id) init
{
	self = [super init];
    if(self != nil){
        _histories = [[NSMutableArray alloc] init];
        [_histories addObject:@" "];
        _historyIndex = 0;
	}
	return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[_histories release];
	[super dealloc];
}


//-- addHistory
// ヒストリの追加
-(void) addHistory:(NSString*) inMessage
{
	[_histories addObject:inMessage];
	if([_histories count] > [[PreferenceModal prefForKey:kHistoryNum] intValue]){
		[_histories removeObjectAtIndex:0];
	}
}


//-- displayPrivHistory
// 1つ前の履歴の表示
-(void) displayPrivHistory:(NSControl*) textField
{
	if(_historyIndex == ([_histories count] - 1)){
		[_histories removeLastObject];
		[self addHistory:[NSString stringWithString:[textField stringValue]]];
	}
	if(_historyIndex > 0){
		_historyIndex--;
		[textField setStringValue:[_histories objectAtIndex:_historyIndex]];
	}
}


//-- displayNextHistory
// 1つ新しい履歴の表示
-(void) displayNextHistory:(NSControl*) textField
{
	_historyIndex++;
	if(_historyIndex < [_histories count] && _historyIndex > 0){
		[textField setStringValue:[_histories objectAtIndex:_historyIndex]];
	}else{
		_historyIndex--;
	}
}


//-- enterHistory:
// historyに追加する
- (void) enterHistory:(NSControl*) textField
{
	[_histories removeLastObject];
	[self addHistory:[NSString stringWithString:[textField stringValue]]];
	[_histories addObject:@" "];
	_historyIndex = [_histories count] - 1;
}


//-- control:textView:doCommandBySelector:
// PageUp/Down enterが押されたときの処理
-(BOOL)			control:(NSControl *)control
			   textView:(NSTextView *)textView
	doCommandBySelector:(SEL)command
{
	if(command == @selector(scrollPageDown:)){
		[self displayNextHistory:control];
		return YES;
	}else if(command == @selector(scrollPageUp:)){
		[self displayPrivHistory:control];
		return YES;
	}else if(command == @selector(insertNewline:)){
		[self enterHistory:control];
		return NO;
	}
	return NO;
}

@end

