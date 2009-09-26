//
//  $RCSfile: PreferenceModal.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "PreferenceModal.h"
#import "PreferenceConstants.h"
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
			[NSArray arrayWithObject:
				[NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithString:@"nick"], @"name", 
					[NSString stringWithString:@"0.5 0.0 0.0 1.0"], @"color", nil]], kFriends,
			[NSArray arrayWithObject:
				[NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithString:@"keyword"], IRNotificationTitle,
					[NSString stringWithString:@""], IRNotificationAlertName,
					[NSString stringWithString:@"0.5 0.0 0.0 1.0"], IRNotificationColor,
					[NSNumber numberWithBool:YES], IRNotificationUseAlert,
					[NSNumber numberWithBool:YES], IRNotificationUseColor, nil]], kKeywords,
			[NSArray arrayWithObject:
				[NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithString:@"#channel"], @"name", nil]], kLogChannels,
	    nil];
    }
    return defaults;
};




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
//
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
	return [NSColor whiteColor];
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
		id defaultValue = [defaults objectForKey:key];
		
		if(!value){
			[_preferences setObject:([defaultValue isKindOfClass:[NSArray class]] ? [NSMutableArray array] : defaultValue)
							 forKey:key];
		}else{
			if([value isKindOfClass:[NSArray class]]){
				NSDictionary* defaultKeys = [defaultValue count] > 0 ? [defaultValue objectAtIndex:0] : nil;
				[_preferences setObject:[self mutableArrayFromArray:value keys:defaultKeys] forKey:key];
			}else{
				[_preferences setObject:value forKey:key];
			}
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
-(NSMutableArray*) mutableArrayFromArray:(NSArray*)array keys:(id)defaults
{
	NSEnumerator* e = [array objectEnumerator];
	NSMutableArray* copy = [NSMutableArray arrayWithCapacity:[array count]];
	id it;
	while(it = [e nextObject]){
		NSMutableDictionary* item;
		if([it isKindOfClass:[NSDictionary class]]){
			item = [it mutableCopy];
		}else{
			item = [NSMutableDictionary dictionaryWithObject:[it copyWithZone:[self zone]] 
													  forKey:@"name"];
		}
		if(defaults && [defaults isKindOfClass:[NSDictionary class]]){
			NSEnumerator* e = [defaults keyEnumerator];
			id key;
			while(key = [e nextObject]){
				if([item objectForKey:key] == nil){
					[item setObject:[defaults objectForKey:key] forKey:key];
				}
			}
		}
		[copy addObject:item];
	}
	return copy;
}

@end
