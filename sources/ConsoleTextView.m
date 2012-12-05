//
//  $RCSfile: ConsoleTextView.m,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "ConsoleTextView.h"
#import "PreferenceModal.h"
#import "BufferedFieldEditor.h"

static void *kUrlColorBindingIdentifier = (void *) @"UrlColor";
static void *kFontBindingIdentifier = (void *) @"Font";

@implementation ConsoleTextView

#pragma mark Initializing
//-- initWithFrame
// 
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_appendString = nil;
		_appendIndex = 0;
		_lines = 0;
    }
    return self;
}


//-- awakeFromNib
//
- (void)awakeFromNib {
	_appendString = nil;
	_appendIndex = 0;
	_lines = 0;
}


//-- dealloc
//
- (void)dealloc
{
	[super dealloc];
}


#pragma mark Bindings

//-- valueClassForBinding:
//
- (Class) valueClassForBinding:(NSString *)binding {
	if([binding isEqualToString:@"urlColor"]) {
		return [NSColor class];
	} else if([binding isEqualToString:@"font"]) {
		return [NSFont class];
	}else{
		return [super valueClassForBinding:binding];
	}
}

//-- bind:toObject:withKeyPath:options:
//
- (void)bind:(NSString *)binding
	toObject:(id)observableObject
 withKeyPath:(NSString *)keyPath
	 options:(NSDictionary *)options
{
	if([binding isEqualToString:@"urlColor"]) {
		[self setObservedControllerForUrlColor:observableObject];
		[self setObservedKeyPathForUrlColor:keyPath];
		[self setUrlColorTransformerName:[options objectForKey:@"NSValueTransformerName"]];
		[observableObject addObserver:self
						   forKeyPath:keyPath
							  options:0
							  context:kUrlColorBindingIdentifier];
		[self syncUrlColorToController];
	}else if([binding isEqualToString:@"font"]) {
		[self setObservedControllerForFont:observableObject];
		[self setObservedKeyPathForFont:keyPath];
		[self setFontTransformerName:[options objectForKey:@"NSValueTransformerName"]];
		[observableObject addObserver:self
						   forKeyPath:keyPath
							  options:0
							  context:kFontBindingIdentifier];
		[self syncFontToController];
	} else {
		[super bind:binding toObject:observableObject withKeyPath:keyPath options:options];
	}
}    


//-- observeValueForKeyPath:ofObject:change:context:
//
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{	
	if (context == kUrlColorBindingIdentifier) {
		[self syncUrlColorToController];
	} else if(context == kFontBindingIdentifier) {
		[self syncFontToController];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}



//-- infoForBinding:
//
- (NSDictionary*) infoForBinding:(NSString *) binding
{
	if([binding isEqualToString:@"urlColor"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
			_observedControllerForUrlColor, NSObservedObjectKey,
			_observedKeyPathForUrlColor, NSObservedKeyPathKey, 
			[NSDictionary dictionaryWithObjectsAndKeys:
				_urlColorTransformerName, @"NSValueTransformerName", nil], NSOptionsKey,nil];
	} else if([binding isEqualToString:@"font"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
			_observedControllerForFont, NSObservedObjectKey,
			_observedKeyPathForFont, NSObservedKeyPathKey, 
			[NSDictionary dictionaryWithObjectsAndKeys:
				_fontTransformerName, @"NSValueTransformerName", nil], NSOptionsKey,nil];
	} else {
		return [super infoForBinding:binding];
	}
}


//-- unbind
// 
- (void)unbind:(NSString *)binding {
	if([binding isEqualToString:@"urlColor"]) {
		[self setObservedControllerForUrlColor:nil];
		[self setObservedKeyPathForUrlColor:nil];
		[self setUrlColorTransformerName:nil];
	} else if([binding isEqualToString:@"font"]) {
		[self setObservedControllerForFont:nil];
		[self setObservedKeyPathForFont:nil];
		[self setFontTransformerName:nil];
	} else {
		[super unbind:binding];
	}
}



#pragma mark urlColor
//-- setObservedControllerForUrlColor
//
-(void) setObservedControllerForUrlColor:(id) controller
{
	if (_observedControllerForUrlColor) [_observedControllerForUrlColor release];
	_observedControllerForUrlColor = [controller retain];
}


//-- setObservedKeyPathForUrlColor
//
-(void) setObservedKeyPathForUrlColor:(NSString*) keypath
{
	if (_observedKeyPathForUrlColor) [_observedKeyPathForUrlColor release];
	_observedKeyPathForUrlColor = (keypath != nil) ? [keypath copy] : nil;
}


//-- setObservedKeyPathForvalue
//
-(void) setUrlColorTransformerName:(NSString*) name
{
	if (_urlColorTransformerName) [_urlColorTransformerName release];
	_urlColorTransformerName =  (name != nil) ? [name copy] : nil;
}



//-- syncUrlColorToController
//
-(void) syncUrlColorToController
{
	id color = [_observedControllerForUrlColor valueForKeyPath:_observedKeyPathForUrlColor];
	
	if (_urlColorTransformerName != nil) {
		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:_urlColorTransformerName];
		color = [transformer transformedValue:color];
	}

	[self setLinkTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName,nil]];
}


#pragma mark Font
//-- setObservedControllerForFont
//
-(void) setObservedControllerForFont:(id) controller
{
	if (_observedControllerForFont) [_observedControllerForFont release];
	_observedControllerForFont = [controller retain];
}

//-- setObservedKeyPathForFont
//
-(void) setObservedKeyPathForFont:(NSString*) keypath
{
	if (_observedKeyPathForFont) [_observedKeyPathForFont release];
	_observedKeyPathForFont = (keypath != nil) ? [keypath copy] : nil;
}


//-- setFontTransformerName
//
-(void) setFontTransformerName:(NSString*) name
{
	if (_fontTransformerName) [_fontTransformerName release];
	_fontTransformerName =  (name != nil) ? [name copy] : nil;
}



//-- syncFontToController
//
-(void) syncFontToController
{
	id font = [_observedControllerForFont valueForKeyPath:_observedKeyPathForFont];
	if (_fontTransformerName != nil) {
		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:_fontTransformerName];
		font = [transformer transformedValue:font];
	}
	
	if(font){
		[self setFont:font];
	}
}  


#pragma mark Append Message
//-- appendString:append:at:scrollLock
// 文字列の追加を行う
- (BOOL) appendString:(NSAttributedString*)inString
			   append:(NSAttributedString*)inAppend
				   at:(NSInteger)inAppendIndex
		   scrollLock:(BOOL) inScrollLock
{
    BOOL isAppend, isNewMessage;
    NSTextStorage* storage;
    
	// 空文字列の場合, 何もしない
    if(inString == nil || [[inString string] isEqualToString:@""]){
        return NO;
    }
    // 挿入前文字列と前回挿入した文字列が等しいかどうかのチェック
    if(inAppend){
        isAppend = YES;
        if(_appendString && [_appendString isEqualToAttributedString:inString]) {
            isNewMessage = NO;
        }else{
            isNewMessage = YES;
            [_appendString release];
            _appendString = [inString copyWithZone:[self zone]];
            _appendIndex = inAppendIndex + [[self textStorage] length];
        }
    }else{
        isAppend = NO;
        isNewMessage = YES;
        [_appendString release];
        _appendString = nil;
        _appendIndex = 0;
    }
    // 文字列の挿入
    storage = [self textStorage];
    [storage beginEditing];
    if(isNewMessage){
        [storage appendAttributedString:inString];
    }
    // 挿入文字列がある場合, 挿入する
    if(isAppend){
        [storage insertAttributedString:inAppend atIndex:_appendIndex];
        _appendIndex += [inAppend length];
    }
	// 行数をチェックしてオーバしている場合一行削除
	if(isNewMessage && ++_lines > [[PreferenceModal prefForKey:kChannelBufferSize] intValue]){
        NSRange range, firstline;
        range = NSMakeRange(0, 0);
        firstline = [[storage string] lineRangeForRange:range];
        [storage deleteCharactersInRange:firstline];
        _lines--;
        _appendIndex -= firstline.length;
    }
    [storage endEditing];
	// scroll lockがかかってない場合最後尾までスクロールする
	if(!inScrollLock){
		[self moveToEndOfDocument:self];
    }
	return YES;
}

#pragma mark KeyDown

//-- keyDown
// すべてのキー入力をtextFieldに渡す
-(void) keyDown:(NSEvent*) event
{
	NSUInteger modifier = [event modifierFlags];
	unsigned short keycode = [event keyCode];
	if(((modifier & NSCommandKeyMask) == NSCommandKeyMask) || (keycode == 0x30)){
		[super keyDown:event];
		return;
	}
	id fieldEditer = [[self window] fieldEditor:YES forObject:self];
	if([fieldEditer isKindOfClass:[BufferedFieldEditor class]]){
		NSView* keyView = [fieldEditer keyView];
		[[NSInputManager currentInputManager] markedTextAbandoned:self];
		[fieldEditer setFirstKeyEvent:[NSApp currentEvent]];
		[[self window] makeFirstResponder:keyView];
		[fieldEditer performSelector:@selector(performFirstKeyEvent:) withObject:nil afterDelay:0.1];	
	}else{
		[super keyDown:event];
	}
}


//-- paste
// field editerにイベントを渡してpasteする
-(IBAction) paste:(id) sender
{
	id fieldEditer = [[self window] fieldEditor:YES forObject:self];
	if([fieldEditer isKindOfClass:[BufferedFieldEditor class]]){
		 NSView* keyView = [fieldEditer keyView];
		[[self window] makeFirstResponder:keyView];
		[fieldEditer paste:sender];
	}else{
		[super paste:sender];
	}	
}


//-- validateMenuItem
// pasteメニューを有効にする
- (BOOL) validateMenuItem:(NSMenuItem*)menuItem
{
	if([menuItem action] == @selector(paste:)){
		NSArray* types = [NSArray arrayWithObject:NSStringPboardType];
		return ([[NSPasteboard generalPasteboard] availableTypeFromArray:types] != nil);
	}
	return [super validateMenuItem:menuItem];
}


@end
