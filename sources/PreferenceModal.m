//
//  $RCSfile: PreferenceModal.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "PreferenceModal.h"
#import "PreferenceHeader.h"
#import "ColorNameToColorTransformer.h"

struct PreferenceModal* sSharedPreferenceModal = nil;

static NSDictionary *defaultValues()
{
    static NSDictionary *defaults = nil;
    
    if(!defaults){
        defaults = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSNumber numberWithBool:NO], kAutoJoin,
			[NSString stringWithString:@"1.0 1.0 1.0 1.0"], kBackgroundColor,
			[NSNumber numberWithBool:YES], kBeepKeyword,
			[NSNumber numberWithInt:100], kChannelBufferSize,
			[NSNumber numberWithBool:YES], kColoredCommand,
			[NSNumber numberWithBool:YES], kColoredError,
			[NSNumber numberWithBool:YES], kColoredFriends,
			[NSNumber numberWithBool:YES], kColoredKeyword,
			[NSNumber numberWithBool:YES], kColoredTime,
			[NSNumber numberWithBool:YES], kColoredURL,
			[NSString stringWithString:@"0.0 0.5 0.0 1.0"], kCommandColor,
			[NSNumber numberWithBool:YES], kDisplayCTCP,
			[NSNumber numberWithBool:YES], kDisplayTime,
			[NSString stringWithString:@"0.5 0.0 0.0 1.0"], kErrorColor,
			[NSString stringWithString:@"0.5 0.0 0.0 1.0"], kFriendsColor,
			[NSString stringWithString:@"0.5 0.0 0.0 1.0"], kKeywordColor,
			[NSString stringWithString:@"IRcat"], kQuitMessage,
			[NSString stringWithString:@"0.0 0.0 0.0 1.0"], kTextColor,
			[NSString stringWithString:@"0.0 0.0 1.0 1.0"], kTimeColor,
			[NSString stringWithString:@"0.0 0.0 1.0 1.0"], kURLColor,
			[NSNumber numberWithBool:YES], kColoredNotification,
			[NSNumber numberWithBool:YES], kUseAnalysis,
			[NSNumber numberWithBool:NO], kUseCommand,
			[NSNumber numberWithBool:NO], kUseInternetTime,
			[NSNumber numberWithBool:NO], kAllowMultiLineMessage,
			[NSNumber numberWithBool:NO], kNotifyOfNewPrivChannel,
			[NSNumber numberWithBool:NO], kNotifyOfInvitedChannel,
			[NSString stringWithString:@"I'm IRcat user"], kUserInfo,
			[NSString stringWithString:@"Funk"], kBeepFile,
			[NSString stringWithFormat:@"%@/Desktop", NSHomeDirectory()], kLogFolder,
			[NSNumber numberWithInt:10], kHistoryNum ,
			[NSNumber numberWithBool:NO], kLogPrivChannel,
			[NSString stringWithFormat:@"%@ %.0f",
				[[NSFont userFontOfSize:0.0] fontName],
				[[NSFont userFontOfSize:0.0] pointSize]], kTextFont,
			[NSNumber numberWithBool:NO], kDisplayCommandTime,
			[NSArray array], kFriends,
			[NSArray array], kKeywords,
			[NSArray array], kLogChannels,
	    nil];
    }
    return defaults;
};


/*
static NSDictionary *oldDefaultValues()
{
    static NSDictionary *defaults = nil;
    
    if(!defaults){
        defaults = [[NSDictionary alloc] initWithObjectsAndKeys:
			// misc changed
			[NSNumber numberWithBool:NO], kAutoJoin,
			[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0], kBackgroundColor,
			[NSNumber numberWithBool:YES], kBeepKeyword,
			[NSNumber numberWithInt:100], kChannelBufferSize,
			[NSNumber numberWithBool:YES], kColoredCommand,
			[NSNumber numberWithBool:YES], kColoredError,
			[NSNumber numberWithBool:YES], kColoredFriends,
			[NSNumber numberWithBool:YES], kColoredKeyword,
			[NSNumber numberWithBool:YES], kColoredTime,
			[NSNumber numberWithBool:YES], kColoredURL,
			[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0], kCommandColor,
			[NSNumber numberWithBool:YES], kDisplayCTCP,
			[NSNumber numberWithBool:YES], kDisplayTime,
			[NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.0 alpha:1.0], kErrorColor,
			[NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.0 alpha:1.0], kFriendsColor,
			[NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.0 alpha:1.0], kKeywordColor,
			[NSString stringWithString:@"IRcat"], kQuitMessage,
			[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0], kTextColor,
			[NSColor blueColor], kTimeColor,
			[NSColor blueColor], kURLColor,
			[NSNumber numberWithBool:YES], kUseAnalysis,
			[NSNumber numberWithBool:NO], kUseCommand,
			[NSNumber numberWithBool:NO], kUseInternetTime,
			[NSNumber numberWithBool:NO], kAllowMultiLineMessage,
			[NSNumber numberWithBool:NO], kNotifyOfNewPrivChannel,
			[NSNumber numberWithBool:NO], kNotifyOfInvitedChannel,
			[NSString stringWithString:@"I'm IRcat user"], kUserInfo,
			[NSString stringWithString:@"Funk"], kBeepFile,
			[NSString stringWithFormat:@"%@/Desktop", NSHomeDirectory()], kLogFolder,
			[NSNumber numberWithInt:10], kHistoryNum ,
			[NSNumber numberWithBool:NO], kLogPrivChannel,
			// etc...
			[NSFont userFontOfSize:0.0], kTextFont,
			[NSNumber numberWithBool:NO], kDisplayCommandTime,
			nil];
    }
    return defaults;
};
*/


@implementation PreferenceModal

#pragma mark Shared Instance
//-- sharedPreferenceModal
//
+(PreferenceModal*) sharedPreference
{
	if(!sSharedPreferenceModal){
		[[PreferenceModal alloc] init];
	}
	return sSharedPreferenceModal;
}

//-- prefForKey
//
+(id) prefForKey:(NSString*) key
{
	return [[PreferenceModal sharedPreference] valueForKey:key];
}


//-- colorForKey
//
+(NSColor*) colorForKey:(NSString*) key
{
	return [PreferenceModal transforColorNameToColor:[PreferenceModal prefForKey:key]];
}

//-- transforColorNameToColor
+ (NSColor*) transforColorNameToColor:(NSString*) value
{
	if (value == nil) return nil;
	
	NSArray* colorTable = [value componentsSeparatedByString:@" "];
    if([colorTable count] > 2){
		return	[NSColor colorWithCalibratedRed:[[colorTable objectAtIndex:0] floatValue]
										  green:[[colorTable objectAtIndex:1] floatValue]
										   blue:[[colorTable objectAtIndex:2] floatValue]
										  alpha:1.0];
    }
	return nil;
}


//-- soundArray
// サウンドの一覧を返す
+(NSArray*) soundArray
{
	static NSArray* soundArray = nil;
	if(soundArray == nil){
		NSArray	*fileType = [NSSound soundUnfilteredFileTypes];
		NSMutableArray* sounds = [[NSMutableArray alloc] initWithCapacity:1];
		NSEnumerator* dirs = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES) objectEnumerator];
		
		id dir;
		while(dir = [dirs nextObject]){
			NSEnumerator* paths = [[[NSFileManager defaultManager]
									directoryContentsAtPath:[dir stringByAppendingPathComponent:@"Sounds"]]
								   objectEnumerator];
			id filename;
			while(filename = [paths nextObject]){
				if([fileType containsObject:[filename pathExtension]]){
					NSString* soundName = [filename stringByDeletingPathExtension];
					if(![sounds containsObject:soundName]){
						[sounds addObject:soundName];
					}
				}
			}
		}
		soundArray = [[NSArray arrayWithArray:sounds] retain];
		[sounds release];
	}
	return soundArray;
}


//-- searchFriend
// friendかどうかの判定
+(NSDictionary*) searchFriend:(NSString*) inString
{

	NSEnumerator* e = [[[self class] prefForKey:kFriends] objectEnumerator];
	 
	 id obj;
	 while(obj = [e nextObject]){
		 if([inString isEqualToString:[obj objectForKey:@"name"]]){
			 return obj;
		 }
	 }
	return nil;
}




#pragma mark Initializing
//-- init
// 初期化
- (id) init
{
	[super init];
	if(sSharedPreferenceModal){
		[self release];
		return sSharedPreferenceModal;
	}
	sSharedPreferenceModal = self;
	[self preferencesFromDefaults];
	return self;
}


//-- dealloc
// 削除
- (void) dealloc
{
	[super dealloc];
	sSharedPreferenceModal = nil;
}

#pragma mark Bindings Interface
//-- setValue:forKey
//
-(void) setValue:(id) value
		  forKey:(NSString*) key
{
	id newValue = value ? value : [NSNull null];
	[self willChangeValueForKey:key];
	[_preferences setObject:newValue forKey:key];
    [self didChangeValueForKey:key];
}


//-- valueForKey
//
-(id) valueForKey:(NSString*) key
{
	return [_preferences objectForKey:key];
}



#pragma mark user defaults
//-- preferencesFromDefaults
// 初期設定ファイルから設定をCurrentValuesに読み込む
- (void) preferencesFromDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* defaults = defaultValues();
	_preferences = [[NSMutableDictionary alloc] initWithCapacity:[defaults count]];
	
	NSEnumerator* e = [defaults keyEnumerator];
	id key;
	while(key = [e nextObject]){
		id value = [userDefaults objectForKey:key];
		if(!value){
			value = [defaults objectForKey:key];
		}
			
		if([value isKindOfClass:[NSArray class]]){
			[_preferences setObject:[self mutableArrayFromArray:value] forKey:key];
		}else{
			[_preferences setObject:value forKey:key];
		}
	}
}


//-- savePreferencesToDefaults
// 初期設定ファイルに設定を書き込む
- (void) savePreferencesToDefaults 
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* defaluts = defaultValues();
	NSEnumerator* e = [defaluts keyEnumerator];
	id key;
	while(key = [e nextObject]){
		id value = [_preferences objectForKey:key];
		if(value){
			[userDefaults setObject:value forKey:key];
		}
	}
    // ファイルに書き込む
    [userDefaults synchronize];
}


//-- mutableArrayFromArray
// 設定ファイルの配列から変更可能な配列を生成する
-(NSMutableArray*) mutableArrayFromArray:(NSArray*) array
{
	NSEnumerator* e = [array objectEnumerator];
	NSMutableArray* copy = [NSMutableArray arrayWithCapacity:[array count]];
	id it;
	while(it = [e nextObject]){
		if([it isKindOfClass:[NSDictionary class]]){
			[copy addObject:[it mutableCopy]];
		}else{
			[copy addObject:[NSMutableDictionary dictionaryWithObject:[it copyWithZone:[self zone]] 
															   forKey:@"name"]];
		}
	}
	return copy;
}

@end
