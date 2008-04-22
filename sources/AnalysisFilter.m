//
//  $RCSfile: AnalysisFilter.m,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import "AnalysisFilter.h"
#import <ApplicationServices/ApplicationServices.h>

LAContextRef sContextRef = nil;

@implementation AnalysisFilter

//-- initAnalysisEngine
//	形態素解析エンジンの初期化をおこなう
+(void) initAnalysisEngine
{
	if(LALanguageAnalysisAvailable() == YES){
		// 日本語環境の参照を得る
		LAEnvironmentRef environmentRef;
		OSStatus err = LAGetEnvironmentRef(kLAJapaneseMorphemeAnalysisEnvironment, &environmentRef);
		// 形態素解析エンジンのContextを得る
		err = LAOpenAnalysisContext( environmentRef, &sContextRef);
	}
}


//-- clearAlaysisEngine
// 形態素解析エンジンの解放を行う
+(void) clearAnalysisEngine
{
	if(sContextRef != nil){
		LACloseAnalysisContext(sContextRef);
		sContextRef = nil;
	}
}


//-- morphemesFromString
// 文字列から形態素の配列を返す.
+(NSArray*) morphemesFromString:(NSString*) inString;
{
	if(sContextRef == nil){
		[[self class] initAnalysisEngine];
	}
	LAMorphemeBundle result = { typeNull, nil };
	LAResetAnalysis(sContextRef);
	// 
	UniCharCount length = (UniCharCount)(CFStringGetLength((CFStringRef)inString));
	UniChar* unistr = (UniChar*)malloc(sizeof(UniChar) * length);
	CFStringGetCharacters((CFStringRef)inString, CFRangeMake(0, length), unistr);
	
	LAMorphemeAnalysis(sContextRef, unistr, length,
					   (LAMorphemePath*)kLAFreeEdge, (LAMorphemePath*)kLAFreeEdge, 
					   1, &result);
	
	NSMutableArray* morphemesArray = [[[NSMutableArray alloc] init] autorelease];
	
	AEDescList morphemeList = { typeNull, nil };
	if(AEGetKeyDesc(&result, keyAELAMorpheme, typeAEList, &morphemeList) == noErr){
		long index;
		if((AECountItems(&morphemeList,&index) == noErr) && index) {
			do {
				AERecord nthMorpheme = { typeNull, nil };
				if(AEGetNthDesc(&morphemeList,index,typeAERecord,nil,&nthMorpheme) == noErr){
					MorphemePartOfSpeech code;
					if(AEGetKeyPtr(&nthMorpheme, keyAEMorphemePartOfSpeechCode, typeAEMorphemePartOfSpeechCode, nil
								   ,&code, sizeof(code), nil) == noErr){
						if(((code & kLASpeechRoughClassMask) == kLASpeechMeishi) || // 名詞
						   (((code & kLASpeechRoughClassMask) == kLASpeechMuhinshi) 
							&& ((code & kLASpeechMediumClassMask) != kLASpeechKigou))){ // 記号以外の無品詞
							MorphemeTextRange textRange;
							if(AEGetKeyPtr(&nthMorpheme, keyAEMorphemeTextRange, typeAEMorphemeTextRange, nil
										   ,&textRange, sizeof(textRange), nil) == noErr){
// CFSwapInt32BigToHost is a patch for Intel (thanks for MIZOGUCHI)
//   Analysis Library's bug?
								[morphemesArray addObject:
									[NSString stringWithCharacters:(unistr + CFSwapInt32BigToHost(textRange.sourceOffset))
															length:CFSwapInt32BigToHost(textRange.length)]];
							}
							
						}
					}
					AEDisposeDesc(&nthMorpheme);
				}
			}while(--index);
			AEDisposeDesc(&morphemeList);
		}
	}
	
	free(unistr);
	AEDisposeDesc(&result);
	
	return morphemesArray;
}

@end
