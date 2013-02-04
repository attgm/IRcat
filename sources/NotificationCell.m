//
//  NotificationCell.m
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "NotificationCell.h"
#import "PreferenceConstants.h"
#import "PreferenceModal.h"

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
    frame.origin.x += 8.0;
	
    if([[values objectForKey:IRNotificationUseColor] boolValue] == YES){
        NSRect colorRect = cellFrame;
        colorRect.size.width = 8.0;
    
        NSColor* color = [PreferenceModal transforColorNameToColor:[values objectForKey:IRNotificationColor]];
        [color set];
        NSRectFill(colorRect);
    }
    
    NSUInteger halfHeight = ceil(frame.size.height / 2 - 1);
	if([values isKindOfClass:[NSDictionary class]]){
		NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        
        
        NSString* notificationType = [values objectForKey:IRNotificationType];
        NSString* title;
        if([notificationType isEqualToString:IRNotificationTypeKeyword]){
            title = [NSString stringWithFormat:@"\"%@\"", [values objectForKey:IRNotificationKeyword]];
        }else{
            title = NSLocalizedString(notificationType, notificationType);
        }
        if(title != nil){
            NSDictionary* attributes = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
            NSRect titleRect = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, halfHeight);
			[title drawInRect:titleRect withAttributes:attributes];
		}
        
        if([[values objectForKey:IRSendUserNotificationCenter] boolValue] == YES){
            NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        style, NSParagraphStyleAttributeName,
                                        [NSColor grayColor], NSForegroundColorAttributeName,
                                        nil];
            NSString* subText = NSLocalizedString(@"Send Notification Center", @"Send Notification Center");
            NSRect subTextRect = NSMakeRect(frame.origin.x, frame.origin.y + halfHeight + 1, frame.size.width, halfHeight);
			[subText drawInRect:subTextRect withAttributes:attributes];
        }
        
        [style release];
	}
	
    /*
	NSPoint iconPoint = NSMakePoint(frame.origin.x + frame.size.width - IRNotificationIconSize ,
									frame.origin.y + frame.size.height -IRNotificationIconSize);
	NSDictionary* icons = iconList();
	NSEnumerator* e = [icons keyEnumerator];
	NSString* key;
	while(key = [e nextObject]){
		if([[values objectForKey:key] boolValue]){
			NSImage* iconImage = [NSImage imageNamed:[icons objectForKey:key]];
			[iconImage setSize:NSMakeSize(IRNotificationIconSize,IRNotificationIconSize)];
			//[iconImage compositeToPoint:iconPoint operation:NSCompositeSourceOver];
            [iconImage drawInRect:NSMakeRect(iconPoint.x, iconPoint.y, IRNotificationIconSize, IRNotificationIconSize)
                         fromRect:NSZeroRect
                        operation:NSCompositeSourceOver
                         fraction:1.0f
                   respectFlipped:YES
                            hints:nil];
			iconPoint.x -= IRNotificationIconSize;
		}
	}
*/
}

@end
