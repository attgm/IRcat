//
//  BufferedFieldEditor.m
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "BufferedFieldEditor.h"


@implementation BufferedFieldEditor

//-- setFirstKeyEvent
// 最初のキーイベントを設定する
-(void) setFirstKeyEvent:(NSEvent*) event
{
	[_firstKeyEvent autorelease];
	_firstKeyEvent = [event retain];
}


//-- performFirstKeyEvent
// 最初のキーイベントを実行
-(void) performFirstKeyEvent:(id) sender
{
	if(_firstKeyEvent){
		[self interpretKeyEvents:[NSArray arrayWithObject:_firstKeyEvent]];
		[self setFirstKeyEvent:nil];
	}
}


//-- keyDown
// キーを押した時の処理
-(void) keyDown:(NSEvent*) event
{
	[self performFirstKeyEvent:self];
	[super keyDown:event];
}


//-- keyView
// キーとなる入力ビューを返す
-(id) keyView
{
	return _keyView;
}


//-- setKeyView
// 
-(void) setKeyView:(id) keyView
{
	[_keyView release];
	_keyView = [keyView retain];
}


@end
