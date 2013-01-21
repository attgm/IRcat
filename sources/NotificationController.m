//
//  NotificationController.m
//  ircat
//
//  Created by Atsushi on 2013/01/21.
//  Copyright (c) 2013年 atsushi. All rights reserved.
//

#import "NotificationController.h"
#import "PreferenceConstants.h"

@implementation NotificationController

//-- addItem
// 初期値に従ってCellを追加する
-(IBAction) addKeywordItem:(id)sender {
	[self addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                     IRNotificationTypeKeyword, IRNotificationType,
                     @"", IRNotificationTitle,
                     nil]];
	NSUInteger index = [[self arrangedObjects] count] - 1;
	[self setSelectionIndex:index];
}


//-- numberOfRowsInTableView
//
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self arrangedObjects] count];
}


//-- tableView:viewForTableColumn:row
//
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary* item = [[self arrangedObjects] objectAtIndex:row];
    NSTableCellView *view;
    if ([item objectForKey:IRNotificationType]) {
        view = [tableView makeViewWithIdentifier:@"NotificationRow" owner:self];
        view.textField.stringValue = [item objectForKey:IRNotificationTitle];
    }
    return view;
}

@end
