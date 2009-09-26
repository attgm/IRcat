//
//  NotificationCell.m
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "NotificationCell.h"
#import "PreferenceConstants.h"

const NSInteger IRNotificationIconSize = 16;

//-- iconList
// 表示するアイコンの一覧を返す
NSDictionary* iconList()
{
	static NSDictionary* iconlist = nil;
	if(!iconlist){
		iconlist = [[NSDictionary alloc] initWithObjectsAndKeys:
					@"icon_colored", IRNotificationUseColor,
					@"icon_alert", IRNotificationUseAlert,
					nil];
	}
	return iconlist;
}


@implementation NotificationCell

//-- drawInteriorWithFrame
// セルの中身を描画
-(void) drawInteriorWithFrame:(NSRect) cellFrame
					   inView:(NSView*) controlView
{
	id values = [self objectValue];
	NSRect frame = NSInsetRect(cellFrame, 4.0, 1.0);
	
	NSUInteger halfHeight = ceil(frame.size.height / 2);
	if([values isKindOfClass:[NSDictionary class]]){
		id title = [values objectForKey:IRNotificationTitle];
		if (title && [title isKindOfClass:[NSString class]]) {
			NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
			[style setLineBreakMode:NSLineBreakByTruncatingTail];
			NSDictionary* attributes = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
			NSRect titleRect = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, halfHeight);
			[title drawInRect:titleRect withAttributes:attributes];
			
			
			[style release];
		}
	}
	
	NSPoint iconPoint = NSMakePoint(frame.origin.x + frame.size.width - IRNotificationIconSize,
									frame.origin.y + frame.size.height);
	NSDictionary* icons = iconList();
	NSEnumerator* e = [icons keyEnumerator];
	NSString* key;
	while(key = [e nextObject]){
		if([[values objectForKey:key] boolValue]){
			NSImage* iconImage = [NSImage imageNamed:[icons objectForKey:key]];
			[iconImage setSize:NSMakeSize(IRNotificationIconSize,IRNotificationIconSize)];
			[iconImage compositeToPoint:iconPoint operation:NSCompositeSourceOver];
			iconPoint.x -= IRNotificationIconSize;
		}
	}
}

@end
