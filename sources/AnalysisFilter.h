//
//  $RCSfile: AnalysisFilter.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Cocoa/Cocoa.h>

@interface AnalysisFilter : NSObject {

}


+(void) initAnalysisEngine;
+(void) clearAnalysisEngine;
+(NSArray*) morphemesFromString:(NSString*) inString;

@end
