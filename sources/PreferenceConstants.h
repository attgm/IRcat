//
//  $RCSfile: PreferenceConstants.h,v $
//  
//  $Revision: 59 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#import <Cocoa/Cocoa.h>

#define kWindowSplitRatio @"WindowSplitRatio"
#define kPaneSplitRatio @"PaneSplitRatio"
#define kWindowCollapseRatio @"WindowCollapseRatio"

#define kUserInfo @"userInfo"
#define kQuitMessage @"quitMessage"
#define kTextFont @"textFont"
#define kTextColor @"textColor"
#define kDisplayTime @"displayTime"
#define kUseInternetTime @"useInternetTime"
#define kDisplayCommandTime @"displayCommandTime"
#define kColoredTime @"coloredTime"

#define kBeepFile @"keywordBeepName"
#define kColoredNotification @"coloredNotification"
#define kKeywordColor @"keywordColor"
#define kNotifyOfNewPrivChannel @"notifyOfNewPrivChannel"
#define kNotifyOfInvitedChannel @"notifyOfInvitedChannel"
#define kKeywords @"keywordsList"
#define kUseAnalysis @"useAnalysisLibrary"

#define kAutoJoin @"autoJoinInvitedChannel"
#define kAllowMultiLineMessage @"allowMultiLineMessage"
#define kColoredCommand @"coloredCommand"
#define kCommandColor @"commandColor"
#define kErrorColor @"errorColor"
#define kFriendsColor @"friendsColor"
#define kTimeColor @"timeColor"
#define kURLColor @"urlColor"

#define kBeepKeyword @"beepKeyword"
#define kColoredFriends @"coloredFriends"

#define kBackgroundColor @"backgroundColor"
#define kChannelBufferSize @"channelBufferSize"
#define kColoredError @"coloredError"
#define kColoredURL @"coloredUrl"
#define kDisplayCTCP @"displayCTCPMessage"
#define kUseCommand @"useCommandMessage"
#define kFriends @"friendsList"
#define kLogPrivChannel @"logPrivChannel"
#define kLogChannels @"logChannelList"
#define kLogFolder @"logFolder"
#define kHistoryNum @"historyNum"

#define kColoredKeyword @"coloredKeyword"

//-- notifications
extern NSString* const IRNotificationTitle;
extern NSString* const IRNotificationUseAlert;
extern NSString* const IRNotificationAlertName;
extern NSString* const IRNotificationUseColor;
extern NSString* const IRNotificationColor;

//-- ServerSetup
#define kServerDefaults @"Servers"
#define kSelectedServerNumber @"DefaultServerNumber"

#define kIdentifier @"id"
#define kServerName @"name"
#define kAutoJoinChannels @"autoJoinChannels"
#define kNickname @"nick"
#define kRealName @"realName"
#define kMailAddress @"mailAddress"
#define kServerAddress @"address"
#define kPortNumber @"port"
#define kServerPassword @"password"
#define kServerLabel @"serverLabel"
#define kInvisibleMode @"invisibleMode"
#define kServerCondition @"condition"
#define kTextEncoding @"encoding"

//-- toolbar items
#define kAddServer @"AddServer"
#define kRemoveServer @"RemoveServer"
#define kServerList @"ServerList"

//-- TAG
#define kTagUserInfo @"UserInfo"
#define kTagFontAndColor @"FontAndColor"
#define kTagView @"View"
#define kTagNotification @"Notification"
#define kTagFriend @"Friend"
#define kTagLog @"Log"
#define kTagEtc @"Etc"