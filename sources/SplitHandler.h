//
//  SplitHandler.h
//  ircat
//
//  Created by Atsushi on 2012/08/13.
//
//

#import <Cocoa/Cocoa.h>
#import "WindowFooter.h"

@interface SplitHandler : WindowFooter {
    IBOutlet NSSplitView* _splitView;
}

@property (retain, nonatomic) IBOutlet NSSplitView* splitView;

@end
