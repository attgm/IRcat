//
//  $RCSfile: EditCellController.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "EditCellController.h"


@implementation EditCellController

//-- addItem
// 初期値に従ってCellを追加する
-(IBAction) addItem:(id)sender {
	[self addObject:[[_defaultValues mutableCopy] autorelease]];
	int index = [[self arrangedObjects] count] - 1;
	[self setSelectionIndex:index];
	if(_primeTableView){
		[_primeTableView editColumn:[_primeTableView columnWithIdentifier:_primeColumn]
								row:index withEvent:nil select:YES];
	}
}

#pragma mark config

//-- setDefaultValues
// 初期値の設定
-(void) setDefaultValues:(NSDictionary*) values
{
	if(_defaultValues){
		[_defaultValues release];
	}
	_defaultValues = [values retain];
}

//-- setPrimeColumn
// 最初に編集状態になるカラムの設定
-(void) setPrimeColumn:(NSString*) string
{
	if(_primeColumn){
		[_primeColumn release];
	}
	_primeColumn = [string copyWithZone:[self zone]];
}


#pragma mark action
//-- changeSelectedCell
//
-(IBAction) changeSelectedCell:(id) sender
{
	[_primeTableView reloadData];
}




@end
