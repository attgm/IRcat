//
//  $RCSfile: EditCellController.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "EditCellController.h"


@implementation EditCellController

//-- addItem
- (IBAction) addItem:(id)sender {
	[self addObject:[_defaultValues mutableCopy]];
	int index = [[self arrangedObjects] count] - 1;
	[self setSelectionIndex:index];
	if(_primeTableView){
		[_primeTableView editColumn:[_primeTableView columnWithIdentifier:_primeColumn]
								row:index withEvent:nil select:YES];
	}
}

#pragma mark config

//-- setDefaultValues
-(void) setDefaultValues:(NSDictionary*) values
{
	if(_defaultValues){
		[_defaultValues release];
	}
	_defaultValues = [values retain];
}

//-- setPrimeColumn
-(void) setPrimeColumn:(NSString*) string
{
	if(_primeColumn){
		[_primeColumn release];
	}
	_primeColumn = [string copyWithZone:[self zone]];
}


@end
