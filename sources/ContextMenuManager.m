//
//  $RCSfile: ContextMenuManager.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import "ChannelModal.h"
#import "ContextMenuManager.h"

static ContextMenuManager* sSharedContextMenuManager = nil;

@implementation ContextMenuManager
//-- IncreaseRange
// レンジを1つ進める
#define IncreaseRange(range) {	\
		range.location++;		\
		range.length--;			\
}


//-- init
// 初期化
- (id) init
{
    self = [super init];
    if(self != nil){
        NSString* path = [[NSBundle mainBundle] pathForResource:@"ContextMenu" ofType:@"xml"];
        _menus = [[NSDictionary alloc] initWithContentsOfFile:path];
	}
	return self;
}


//-- sharedManager
// 共通インスタンスを返す
+ (ContextMenuManager*) sharedManager
{
	if(!sSharedContextMenuManager){
		sSharedContextMenuManager = [[ContextMenuManager alloc] init];
	}
	return sSharedContextMenuManager;
}


//-- createMenuForID
// メニューを生成して返す
- (NSMenu*) createMenuForID:(NSString*) inKey
					  state:(BOOL) inMulti
					 action:(SEL) inSelector
					 target:(id) inTarget
{
	NSArray* items = [_menus objectForKey:inKey];
	if (!items) return nil;
	
	NSEnumerator* e = [items objectEnumerator];
	NSMenu* menu = [[[NSMenu alloc] initWithTitle:@"ContextMenu"] autorelease];
	[menu setAutoenablesItems:NO];
	
	id it, item;
	while(it = [e nextObject]){
		if([it objectForKey:@"separator"]){
			[menu addItem:[NSMenuItem separatorItem]];
		}else{ 
			item = [menu addItemWithTitle:[it objectForKey:@"title"] action:inSelector keyEquivalent:@""];
			if([[it objectForKey:@"multi"] boolValue] == NO && inMulti == YES){
				[item setEnabled:NO];
				[item setTarget:nil];
			}else{
				[item setEnabled:YES];
				[item setTarget:inTarget];
				[item setRepresentedObject:[it objectForKey:@"command"]];
			}
		}
	}
	return menu;
}


//-- expandFormat
// Formatを展開する
// ※括弧のなかに変数を入れると正常にうごかないよん
+ (NSString*) expandFormat : (NSString*) inFormat
					 param : (NSArray*) inParam
					context: (ChannelModal*)inChannel
{
    NSRange format = NSMakeRange(0, [inFormat length]);
    NSRange context = NSMakeRange(0,0);
    NSMutableString* outputString = [[[NSMutableString alloc] init] autorelease];
    unichar	c;
    BOOL isRepeat = NO;
	
    if (format.length == 0) return outputString;
	
    while(format.length > 0){
        c = [inFormat characterAtIndex:format.location];
        IncreaseRange(format);
        if ((c == '$') && context.length > 0) {
            // 文字列部分の展開
            [outputString appendString:[inFormat substringWithRange:context]];
        }
        
        if(c == '$'){
            // 変数部分の処理
            c = [inFormat characterAtIndex:format.location];
            IncreaseRange(format);
            context = NSMakeRange(format.location, 0);
            switch (c){
				case 'c': // $c : active channel
					[outputString appendString:[inChannel name]];
					break;				
				case 's': // $s : server id
					[outputString appendString:[NSString stringWithFormat:@"@%d", [inChannel serverid]]];
					break;				
				case '_': // $_ : context(only one)
					[outputString appendString:[inParam objectAtIndex:0]];
					break;
				case '@': // $@ : context(all (maxinum 4))
					[outputString appendString:[inParam componentsJoinedByString:@" "]];
					break;
				case ',': // $, : context(all (maxinum 4))
					[outputString appendString:[inParam componentsJoinedByString:@","]];
					break;
				case '(': // $( : repeart start
					isRepeat = YES;
					break;
				default:
					context.location--;
					context.length++;
					break;
			}
		}else if(c == ')' && isRepeat == YES) {
			int i;
			for(i=0; i<[inParam count]; i++){
				[outputString appendString:[inFormat substringWithRange:context]];
			}
			context = NSMakeRange(format.location, 0);
		}else{
			context.length++;
		}
	}
	
	if(context.length > 0){
		[outputString appendString:[inFormat substringWithRange:context]];
		
	}
	
	return outputString;
};

@end
