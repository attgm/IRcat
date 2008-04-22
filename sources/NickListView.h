//
//  $RCSfile: NickListView.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <AppKit/AppKit.h>
#import "ChannelModal.h"

@interface NickListView : NSTableView {
	ChannelModal* _channel;
	id _menuTarget;
}

- (NSMenu*) menuForEvent:(NSEvent*) inEvent;

- (void) performContextMenu: (id) sender;
- (void) setContextMenu:(ChannelModal*) inChannel
				 target:(id) inTarget;
- (void) setFont: (NSFont*) inFont;

@end
