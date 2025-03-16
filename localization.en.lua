-- Version : English (default) ( by LenweSaralonde )
-- Enhanced by Claude

BARKER_LOAD = "Barker VERSION loaded. Type /barkhelp for help or /barkui to open the interface."

-- Basic messages
BARKER_STATS = "\"MESSAGE\" is sent every RATE seconds in channel /CHANNEL."
BARKER_STATS_MULTI = "COUNT messages in rotation will be sent with a base interval of RATE seconds."

BARKER_MESSAGE = "The message is now \"MESSAGE\"."
BARKER_RATE = "The message is now sent every RATE seconds."
BARKER_RATE_VARIANCE = "The rate variance is now VARIANCE seconds."
BARKER_CHANNEL = "The message is now sent in channel /CHANNEL."

BARKER_ACTIVE = "Barker is enabled."
BARKER_INACTIVE = "Barker is disabled."

BARKER_ERR_CHAN = "The channel /CHANNEL doesn't exist."
BARKER_ERR_RATE = "You can't send messages less than every RATE seconds."
BARKER_ERR_NUMBER = "Please enter a valid number."
BARKER_ERR_EMPTY_MESSAGE = "Message cannot be empty."
BARKER_ERR_MESSAGE_MODE = "Valid message modes are: random, sequential"
BARKER_ERR_HOURS = "Hours must be between 0 and 24."
BARKER_ERR_DAY = "Day must be between 1 and 7."

-- Enhanced messages
BARKER_MESSAGE_ADDED = "Message #INDEX added to rotation."
BARKER_MESSAGE_REMOVED = "Message #INDEX removed from rotation."
BARKER_CURRENT_MESSAGES = "Current messages in rotation:"
BARKER_MESSAGE_MODE = "Message rotation mode set to: MODE"
BARKER_INVALID_MESSAGE_INDEX = "Invalid message index."

BARKER_CHANNEL_ADDED = "Channel CHANNEL added."
BARKER_CHANNEL_REMOVED = "Channel CHANNEL removed."
BARKER_CHANNEL_EXISTS = "Channel CHANNEL already exists."
BARKER_CHANNEL_TOGGLE = "Channel CHANNEL is now STATE."
BARKER_CURRENT_CHANNELS = "Current channels:"
BARKER_INVALID_CHANNEL_INDEX = "Invalid channel index."
BARKER_MAX_CHANNELS = "Maximum number of channels reached. Remove a channel first."

BARKER_ACTIVE_HOURS = "Active hours: START to END"
BARKER_DAY_TOGGLE = "DAY is now STATE."

BARKER_MAX_MESSAGES_REACHED = "Maximum number of messages sent. Barker disabled."
BARKER_MAX_MESSAGES_SET = "Maximum messages limit set to COUNT."
BARKER_MAX_MESSAGES_UNLIMITED = "No limit on maximum messages to send."

BARKER_ALTERNATE_ON = "Channel alternating enabled. Messages will be sent to one channel at a time."
BARKER_ALTERNATE_OFF = "Channel alternating disabled. Messages will be sent to all channels simultaneously."

BARKER_SHOW_IN_CHAT_ON = "Messages will be shown in chat when sent."
BARKER_SHOW_IN_CHAT_OFF = "Messages will not be shown in chat when sent."

BARKER_DEBUG_ON = "Debug mode enabled."
BARKER_DEBUG_OFF = "Debug mode disabled."

BARKER_UI_NOT_LOADED = "UI module is not loaded."

-- UI strings
BARKER_ENABLE = "Enable Barker"
BARKER_ENABLE_TT = "Enable or disable message sending"
BARKER_BASE_RATE = "Base send interval"
BARKER_BASE_RATE_TT = "The base interval between messages in seconds"
BARKER_RATE_VARIANCE = "Random variance"
BARKER_RATE_VARIANCE_TT = "Random additional seconds to add to the base rate (0-60)"
BARKER_MAX_MESSAGES_LIMIT = "Max messages to send (0 = unlimited):"
BARKER_ALTERNATE_CHANNELS = "Alternate between channels"
BARKER_ALTERNATE_CHANNELS_TT = "Instead of sending to all channels at once, rotate between them"
BARKER_SHOW_IN_CHAT = "Show messages in chat"
BARKER_SHOW_IN_CHAT_TT = "Show messages in your chat window when they are sent"
BARKER_DEBUG = "Debug mode"
BARKER_DEBUG_TT = "Show additional debugging information"

BARKER_STATUS = "Status"
BARKER_MESSAGES_SENT = "Messages sent"

BARKER_TAB_GENERAL = "General"
BARKER_TAB_MESSAGES = "Messages"
BARKER_TAB_CHANNELS = "Channels"
BARKER_TAB_SCHEDULING = "Schedule"
BARKER_TAB_HELP = "Help"

BARKER_MESSAGE_MODE = "Message rotation mode:"
BARKER_MODE_SEQUENTIAL = "Sequential"
BARKER_MODE_RANDOM = "Random"
BARKER_NEW_MESSAGE = "Add new message:"
BARKER_MESSAGE_LIST = "Message list"
BARKER_ADD = "Add"
BARKER_REMOVE = "Remove"

BARKER_CHANNEL_TYPE = "Channel type:"
BARKER_CHANNEL_NUMBER = "Channel number:"
BARKER_CUSTOM_RATE = "Custom rate for this channel"
BARKER_CUSTOM_RATE_TT = "Set a custom send interval for this channel"
BARKER_ADD_CHANNEL = "Add Channel"
BARKER_CHANNEL_LIST = "Channel list"

BARKER_ACTIVE_HOURS_LABEL = "Active hours (24-hour format):"
BARKER_START_HOUR = "Start hour"
BARKER_END_HOUR = "End hour"
BARKER_ACTIVE_DAYS = "Active days:"

BARKER_VERSION = "Barker Version:"
BARKER_ENABLED = "Enabled"
BARKER_DISABLED = "Disabled"

-- Help text
BARKER_HELP = {
	"==================== Barker ====================",
	"Barker periodically sends messages in one or more chat channels.",
	"Perfect for advertising services, recruiting for guilds, or promoting events.",
	"",
	"Basic Commands:",
	"/bark [on|off] : Start/stop sending messages",
	"/barkui : Open the graphical user interface",
	"/barkinfo : Display current settings",
	"",
	"Message Commands:",
	"/barkmsg <message> : Add a message to the rotation",
	"/barkmsgremove <index> : Remove a message by index",
	"/barkmode <sequential|random> : Set message rotation mode",
	"",
	"Channel Commands:",
	"/barkchan <channel> [rate] : Add a channel with optional custom rate",
	"/barkchanremove <index> : Remove a channel by index",
	"/barkchantoggle <index> : Enable/disable a channel",
	"",
	"Timing Commands:",
	"/barkrate <seconds> : Set the base interval (min 10)",
	"/barkvariance <seconds> : Set random time variance (0-60)",
	"/barkhours <start> <end> : Set active hours (0-24)",
	"/barkday <1-7> : Toggle day (1=Sun, 7=Sat)",
	"/barkmax <count> : Set max messages (0=unlimited)",
	"",
	"Other Commands:",
	"/barkalternate : Toggle channel alternating",
	"/barkshowchat : Toggle showing messages in chat",
	"/barkdebug : Toggle debug mode",
	"/barkhelp : Show this help"
}