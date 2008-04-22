//
//  $RCSfile: ServersController.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ServersController.h"
#import "PreferenceHeader.h"
#import "ServerModal.h"

@implementation ServersController

//-- addItem
// 
- (IBAction) addItem:(id)sender
{
	int index = [self selectionIndex] + 1;
	
	ServerModal* newserver;
	if(index != NSNotFound){
		NSArray* selectedArray = [self selectedObjects];
		newserver = [ServerModal serverModalWithDictionary:[[selectedArray objectAtIndex:0] parameters]];
	}else{
		newserver = [ServerModal serverModal];
		index = 0;
	}
	// create new server from selected server
	[self insertObject:newserver atArrangedObjectIndex:index];
	[self setSelectionIndex:index];
	[_primeTableView editColumn:[_primeTableView columnWithIdentifier:@"server_name"]
							row:index withEvent:nil select:YES];
}


- (BOOL) canRemove
{
	return (([[self arrangedObjects] count] > [[self selectionIndexes] count])
			&& ([self selectionIndex] != NSNotFound));
}

@end
