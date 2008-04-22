//
//  $RCSfile: EditCellController.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>


@interface EditCellController : NSArrayController {
	IBOutlet NSTableView* _primeTableView;
	
	NSDictionary* _defaultValues;
	NSString*	_primeColumn;
}

- (IBAction) addItem:(id)sender;

-(void) setDefaultValues:(NSDictionary*) values;
-(void) setPrimeColumn:(NSString*) string;

@end
