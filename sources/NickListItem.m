//
//  $RCSfile: NickListItem.m,v $
//
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "NickListItem.h"
#import "PreferenceWindowController.h"

@implementation NickListItem

//-- initWithNick
// 初期化
- (id) initWithNick:(NSString*) inNickname
			  label:(NSString*) inLabel
               flag:(int) inFlag;
{
    self = [super init];
    if(self){
        [self setNick:inNickname];
        [self setLabel:inLabel];
        _flag = inFlag;
    }
    return self;
}


//-- dealloc
// 削除
- (void) dealloc
{
	[_nickname release];
	[_label release];
	[super dealloc];
}


#pragma mark -
//-- setNick
// nick name の設定
- (void) setNick:(NSString*)inString
{
    [_nickname release];
    _nickname = (inString ? [inString copyWithZone:[self zone]] : nil);
    
	_isFriend = ([PreferenceModal searchFriend:_nickname] != nil);
}


//-- nick
// nicknameを返す
- (NSString*) nick
{
    return _nickname;
}


//-- setFlag:ison
// flagの設定
- (void) setFlag:(int)inFlag
			ison:(BOOL)inIsOn
{
	_flag = inIsOn ? (_flag | inFlag) : (_flag & ~inFlag);
}

//-- flag
// flagを返す
- (int) flag
{
    return _flag;
}


//-- setLabel
// labelの設定
- (void) setLabel:(NSString*)inString
{
	[_label release];
    _label = (inString ? [inString copyWithZone:[self zone]] : nil);
}


//-- label
// ラベルを返す
- (NSString*) label
{
	return _label;
}


//-- isFriend
// friendかどうか
- (BOOL) isFriend
{
    return _isFriend;
}


#pragma mark -
//-- compareWithNickListItem
//
- (NSComparisonResult) compareWithNickListItem:(NickListItem *) inItem
{
    // friendかどうかが同じであった場合は, アルファベット順
    if([self isFriend] == [inItem isFriend]){
        return [[self nick] caseInsensitiveCompare:[inItem nick]];
    }else{
        // 異なる場合はFriend優先
        return ([self isFriend] ? NSOrderedAscending : NSOrderedDescending);
    }
}

@end
