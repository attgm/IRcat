//
//  $RCSfile: NickListView.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "NickListView.h"
#import "IRcatInterface.h"
#import "ContextMenuManager.h"

@implementation NickListView


//-- menuForEvent
// menu eventの設定
- (NSMenu*) menuForEvent:(NSEvent*) inEvent
{
	if([self numberOfSelectedRows] > 0){
		NSString* menuid = ([_channel serverid] < 0) ? @"ServerMenu" : @"NickList";
		NSMenu *menu = [[ContextMenuManager sharedManager] createMenuForID:menuid
																	 state:([self numberOfSelectedRows] > 1)
																	action:@selector(performContextMenu:)
																	target:self];
		return menu;
	}
	return nil;
}


//-- performContextMenu
// context menuの実行
- (void) performContextMenu: (id) sender
{
	NSString* command = [sender representedObject];
	
	NSIndexSet* indexes = [self selectedRowIndexes]; // selectedRowEnumerator
	[_menuTarget performContextMenu:command context:[_channel arraySelected:indexes] channel:_channel];
}


//-- setContextMenu:target
// context menuの設定
- (void) setContextMenu:(ChannelModal*) inChannel
				 target:(id) inTarget
{
	if(_channel)
		[_channel release];
	
	_channel = [inChannel retain];
	_menuTarget = inTarget;
}



//-- mouseDown
// 長押しでcontect menuを表示させる
- (void) mouseDown:(NSEvent*) inEvent
{
	if ([inEvent type] == NSLeftMouseDown && [inEvent clickCount] == 1 ) {
		// Wait next event a moment
		NSEvent*	waitingEvent = [NSApp nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask) 
													  untilDate:[NSDate dateWithTimeIntervalSinceNow:0.5] 
														 inMode:NSDefaultRunLoopMode 
														dequeue:NO];
		if (!waitingEvent) {
			NSEvent *rightMouseEvent = [NSEvent mouseEventWithType:NSRightMouseDown 
														  location:[inEvent locationInWindow] 
													 modifierFlags:[inEvent modifierFlags] 
														 timestamp:[inEvent timestamp] 
													  windowNumber:[inEvent windowNumber] 
														   context:[inEvent context] 
													   eventNumber:[inEvent eventNumber] 
														clickCount:[inEvent clickCount] 
														  pressure:[inEvent pressure]];
			// context menuの表示
			[self rightMouseDown:rightMouseEvent];
			return;
		}
	}
    [super mouseDown:inEvent];
}


#pragma mark -
//-- setFont
// fontを変更する
- (void) setFont: (NSFont*) inFont
{
	NSLayoutManager* lm = [[[NSLayoutManager alloc] init] autorelease];
	[self setRowHeight:([lm defaultLineHeightForFont:inFont] + 2)];
	[[[self tableColumnWithIdentifier:@"nick"] dataCell] setFont:inFont];
	[self reloadData];
}
@end
