//
//  $RCSfile: IRcatUtilities.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Foundation/Foundation.h>

extern NSString* PrefixString(NSString* inString, NSString* inDevide, NSRange* ioContent);
extern NSString* PrefixCharacterSet(NSString* inString, NSCharacterSet* inDevide, NSRange* ioContent);
extern BOOL IsChannel(NSString* inString);
extern BOOL IsNick(NSString* inString);
extern BOOL IsMode(NSString* inString);
extern BOOL IsAppSandboxed();



