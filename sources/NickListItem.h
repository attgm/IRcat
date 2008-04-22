//
//  $RCSfile: NickListItem.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>

@interface NickListItem : NSObject {
    NSString* 	_nickname;
	NSString*   _label;
    int			_flag;
    BOOL		_isFriend;
}

- (id) initWithNick:(NSString*) inNickname label:(NSString*)inLabel flag:(int)inFlag;
- (void) dealloc;

- (NSComparisonResult) compareWithNickListItem:(NickListItem *) inItem;

- (NSString*) nick;
- (NSString*) label;
- (int) flag;

- (void) setFlag:(int)inFlag ison:(BOOL)inIsOn;
- (BOOL) isFriend;
- (void) setLabel:(NSString*)inLabel;

- (void) setNick:(NSString*)inString;


@end
