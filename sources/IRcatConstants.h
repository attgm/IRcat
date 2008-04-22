//
//  $RCSfile: IRcatConstants.h,v $
//  
//  $Revision: 49 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//
#define	kDefaultCommandFormat			@"DEFAULT_COMMAND"
#define	kDefaultReplyFormat				@"DEFAULT_REPLY"
#define kDefaultErrorFormat				@"DEFAULT_ERROR"
#define kInternalMessageFormat			@"INTERNAL_MESSAGE"
#define kInternalErrorFormat			@"INTERNAL_ERROR"

#define kJoinSelfFormat					@"JOIN_SELF"
#define kJoinFormat						@"JOIN"
#define kPartSelfFormat					@"PART_SELF"
#define	kPartFormat						@"PART"
#define kTopicFormat					@"TOPIC"
#define	kModeChannelFormat				@"MODE_CHANNEL"
#define kModeUserFormat					@"MODE_USER"
#define kNickFormat						@"NICK"
#define kPrivmsgChannelSelfFormat		@"PRIVMSG_CHANNEL_SELF"
#define kPrivmsgChannelFormat			@"PRIVMSG_CHANNEL"	
#define	kNoticeChannelFormat			@"NOTICE"
#define kPrivmsgUserSelfFormat			@"PRIVMSG_USER_SELF"
#define kPrivmsgUserFormat				@"PRIVMSG_USER"
#define kPrivmsgServerFormat			@"PRIVMSG_SERVER"
#define kPrivmsgConsoleFormat			@"PRIVMSG_CONSOLE"
#define kKickSelfFormat					@"KICK_SELF"
#define kKickFormat						@"KICK"
#define kQuitSelfFormat					@"QUIT_SELF"
#define kQuitFormat						@"QUIT"
#define kInviteSelfFormat				@"INVITE_SELF"
#define kInviteFormat					@"INVITE"
#define kCTCPDefaultFormat				@"CTCP_DEFAULT"
#define kCTCPActionFormat				@"CTCP_ACTION"
#define kCTCPPingSecFormat				@"CTCP_PING_SEC"
#define kCTCPPingFormat					@"CTCP_PING"
#define kCTCPRecivedFormat				@"CTCP_RECIVE"

enum IRCResponse{
	RPL_NOTHING				= 0,
	IRC_UNDEFINED			= 1000,
	ERR_NOSUCHNICK			= 401,
	ERR_NOSUCHSERVER		= 402,
	ERR_NOSUCHCHANNEL		= 403,
	ERR_CANNOTSENDTOCHAN	= 404,
	ERR_TOOMANYCHANNELS		= 405,
	ERR_WASNOSUCHNICK		= 406,
	ERR_TOOMANYTARGETS		= 407,
	ERR_NOORIGIN			= 409,
	ERR_NORECIPIENT			= 411,
	ERR_NOTEXTTOSEND		= 412,
	ERR_NOTOPLEVEL			= 413,
	ERR_WILDTOPLEVEL		= 414,
	ERR_UNKNOWNCOMMAND		= 421,
	ERR_NOMOTD				= 422,
	ERR_NOADMININFO			= 423,
	ERR_FILEERROR			= 424,
	ERR_NONICKNAMEGIVEN		= 431,
	ERR_ERRONEUSNICKNAME	= 432,
	ERR_NICKNAMEINUSE		= 433,
	ERR_NICKCOLLISION		= 436,
	ERR_USERNOTINCHANNEL	= 441,
	ERR_NOTONCHANNEL		= 442,
	ERR_USERONCHANNEL		= 443,
	ERR_NOLOGIN				= 444,
	ERR_SUMMONDISABLED		= 445,
	ERR_USERSDISABLED		= 446,
	ERR_UNAVAILRESOURCE		= 447, //rfc2812
	ERR_NOTREGISTERED		= 451,
	ERR_NEEDMOREPARAMS		= 461,
	ERR_ALREADYREGISTRED	= 462,
	ERR_NOPERMFORHOST		= 463,
	ERR_PASSWDMISMATCH		= 464,
	ERR_YOUREBANNEDCREEP	= 465,
	ERR_KEYSET				= 467,
	ERR_CHANNELISFULL		= 471,
	ERR_UNKNOWNMODE			= 472,
	ERR_INVITEONLYCHAN		= 473,
	ERR_BANNEDFROMCHAN		= 474,
	ERR_BADCHANNELKEY		= 475,
	ERR_NOPRIVILEGES		= 481,
	ERR_CHANOPRIVSNEEDED	= 482,
	ERR_CANTKILLSERVER		= 483,
	ERR_NOOPERHOST			= 491,
	ERR_UMODEUNKNOWNFLAG	= 501,
	ERR_USERSDONTMATCH		= 502,
	RPL_NONE				= 300,
	RPL_USERHOST			= 302,
	RPL_ISON				= 303,
	RPL_AWAY				= 301,
	RPL_UNAWAY				= 305,
	RPL_NOWAWAY				= 306,
	RPL_WHOISUSER			= 311,
	RPL_WHOISSERVER			= 312,
	RPL_WHOISOPERATOR		= 313,
	RPL_WHOISIDLE			= 317,
	RPL_ENDOFWHOIS			= 318,
	RPL_WHOISCHANNELS		= 319,
	RPL_WHOWASUSER			= 314,
	RPL_ENDOFWHOWAS			= 369,
	RPL_LISTSTART			= 321,
	RPL_LIST				= 322,
	RPL_LISTEND				= 323,
	RPL_CHANNELMODEIS		= 324,
	RPL_NOTOPIC				= 331,
	RPL_TOPIC				= 332,
	RPL_TOPICDATE			= 333,
	RPL_INVITING			= 341,
	RPL_SUMMONING			= 342,
	RPL_VERSION				= 351,
	RPL_WHOREPLY			= 352,
	RPL_ENDOFWHO			= 315,
	RPL_NAMREPLY			= 353,
	RPL_ENDOFNAMES			= 366,
	RPL_LINKS				= 364,
	RPL_ENDOFLINKS			= 365,
	RPL_BANLIST				= 367,
	RPL_ENDOFBANLIST		= 368,
	RPL_INFO				= 371,
	RPL_ENDOFINFO			= 374,
	RPL_MOTDSTART			= 375,
	RPL_MOTD				= 372,
	RPL_ENDOFMOTD			= 376,
	RPL_YOUREOPER			= 381,
	RPL_REHASHING			= 382,
	RPL_TIME				= 391,
	RPL_USERSSTART			= 392,
	RPL_USERS				= 393,
	RPL_ENDOFUSERS			= 394,
	RPL_NOUSERS				= 395,
	RPL_TRACELINK			= 200,
	RPL_TRACECONNECTING		= 201,
	RPL_TRACEHANDSHAKE		= 202,
	RPL_TRACEUNKNOWN		= 203,
	RPL_TRACEOPERATOR		= 204,
	RPL_TRACEUSER			= 205,
	RPL_TRACESERVER			= 206,
	RPL_TRACENEWTYPE		= 208,
	RPL_TRACELOG			= 261,
	RPL_STATSLINKINFO		= 211,
	RPL_STATSCOMMANDS		= 212,
	RPL_STATSCLINE			= 213,
	RPL_STATSNLINE			= 214,
	RPL_STATSILINE			= 215,
	RPL_STATSKLINE			= 216,
	RPL_STATSYLINE			= 218,
	RPL_ENDOFSTATS			= 219,
	RPL_STATSLLINE			= 241,
	RPL_STATSUPTIME			= 242,
	RPL_STATSOLINE			= 243,
	RPL_STATSHLINE			= 244,
	RPL_UMODEIS				= 221,
	RPL_LUSERCLIENT			= 251,
	RPL_LUSEROP				= 252,
	RPL_LUSERUNKNOWN		= 253,
	RPL_LUSERCHANNELS		= 254,
	RPL_LUSERME				= 255,
	RPL_ADMINME				= 256,
	RPL_ADMINLOC1			= 257,
	RPL_ADMINLOC2			= 258,
	RPL_ADMINEMAIL			= 259
};


enum IRCModeFlag {
	//User Flags
	IRcat_MODE_UserInvisible				= 'i',
	IRcat_MODE_UserReceivesServerNotices	= 's',
	IRcat_MODE_UserReceivesWallops			= 'w',
	IRcat_MODE_UserOperatorPrivs			= 'o',

	//Channel Flags
	IRcat_MODE_ChanOperatorPrivs 			= 'o',
	IRcat_MODE_ChanPrivateChannel 			= 'p',
	IRcat_MODE_ChanSecretChannel 			= 's',
	IRcat_MODE_ChanInviteOnly				= 'i',
	IRcat_MODE_ChanTopicSettable 			= 't',
	IRcat_MODE_ChanNoMessagesFromOutside	= 'n',
	IRcat_MODE_ChanModerated 			= 'm',
	IRcat_MODE_ChanUserLimit 			= 'l',
	IRcat_MODE_ChanBanMask 				= 'b',
	IRcat_MODE_ChanSpeakAbility			= 'v',
	IRcat_MODE_ChanChannelKey			= 'k'
};


typedef enum {
	kIRcatFlagNoting			= 0,
	kIRcatFlagOperator			= 1 << 0,
    kIRcatFlagSpeakAbility		= 1 << 1
} IRCModeFlagMask;


typedef enum {
	kSessionConditionConnecting,
	kSessionConditionRegistering,
	kSessionConditionEstablished,
	kSessionConditionDisconnected
} SessionCondition;

#define	kCommandPing 		@"PING"
#define kCommandPrivmsg 	@"PRIVMSG"
#define kCommandNotice		@"NOTICE"
#define kCommandJoin 		@"JOIN"
#define kCommandPart		@"PART"
#define kCommandQuit		@"QUIT"
#define kCommandTopic		@"TOPIC"
#define kCommandInvite		@"INVITE"
#define kCommandKick		@"KICK"
#define kCommandNick		@"NICK"
#define kCommandSQuit		@"SQUIT"
#define kCommandObject		@"OBJECT"
#define kCommandMode		@"MODE"
// internal commands
#define kCommandConnect		@"CONNECT"
#define kCommandCommand		@"COMMAND"
#define kCommandDisconnect  @"DISCONNECT"
#define kCommandCtcp		@"CTCP"


#define kCommandCtcpClientInfo  @"CLIENTINFO"
#define kCommandCtcpUserInfo	@"USERINFO"
#define kCommandCtcpVersion 	@"VERSION"
#define kCommandCtcpAction		@"ACTION"
#define kCommandCtcpPing		@"PING"
#define kCommandCtcpTime		@"TIME"
#define kCommandCtcpFinger		@"FINGER"

#define kCommandWhois		@"WHOIS"
#define kCommandWhowas		@"WHOWAS"
#define kCommandPong		@"PONG"
#define kCommandPassword	@"PASS"
#define kCommandUser		@"USER"
#define kCommandOper		@"OPER"
#define kCommandNames		@"NAMES"
#define kCommandList		@"LIST"
#define kCommandError		@"ERROR"
#define kCommandAction      @"ACTION"

#define kIRCModeMax		3

