//
//  GradientButton.h
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>


@interface GradientButton : NSButton {

}

+(Class) cellClass;
@end


@interface GradientButtonCell : NSButtonCell {
}

-(void) drawBezelWithFrame:(NSRect)frame inView:(NSView*)view;

@end;
