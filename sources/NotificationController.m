//
//  NotificationController.m
//  ircat
//
//

#import "NotificationController.h"
#import "PreferenceConstants.h"

@implementation NotificationController

//-- addItem
// 初期値に従ってCellを追加する
-(IBAction) addItem:(id)sender {
	[self addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                     IRNotificationTypeKeyword, IRNotificationType,
                     @"", IRNotificationKeyword,
                     nil]];
	NSUInteger index = [[self arrangedObjects] count] - 1;
	[self setSelectionIndex:index];
}


//-- removeSelectedItem
// 選択中のアイテムを削除する
-(IBAction) removeSelectedItem:(id)sender {
    if([self canRemove]){
        [self removeObjects:[self selectedObjects]];
    }
}


//-- canRemove
// 削除できるかどうか
- (BOOL) canRemove
{
    NSArray* selectedItems = [self selectedObjects];
    if ([selectedItems count] == 0) return NO;
    for(NSDictionary* item in selectedItems){
        if([[item objectForKey:IRNotificationType] isEqualToString:IRNotificationTypeKeyword] == NO){
            return NO;
        }
    }
    return YES;
}


@end
