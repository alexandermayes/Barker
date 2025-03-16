# Barker

Barker is an advanced chat message automation system for World of Warcraft. It periodically sends messages to one or more chat channels, perfect for advertising services, guild recruitment, event announcements, and more.

## Key Features

* **GUI Interface** - User-friendly graphical interface for easy configuration
* **Multi-channel Support** - Send to multiple channels simultaneously or in rotation
* **Message Rotation** - Maintain a library of messages sent in sequential or random order
* **Customizable Schedules** - Set specific active hours and days for message sending
* **Randomized Timing** - Add variance to message intervals to appear more natural
* **Channel-specific Rates** - Set different intervals for different channels
* **Character-specific Settings** - All settings are saved per character

## Getting Started

1. Install the addon along with its dependency, MessageQueue
2. Type `/bkrui` to open the configuration window
3. Add your messages and configure channels
4. Click "Enable Barker" to start sending messages

## Commands

### Basic Commands
* `/bkr [on|off]` - Start/stop sending messages
* `/bkrui` - Open the graphical user interface
* `/bkrinfo` - Display current settings

### Message Commands
* `/bkrmsg <message>` - Add a message to the rotation
* `/bkrmsgdel <index>` - Remove a message by index
* `/bkrmode <sequential|random>` - Set message rotation mode

### Channel Commands
* `/bkrchan <channel> [rate]` - Add a channel with optional custom rate
* `/bkrchandel <index>` - Remove a channel by index
* `/bkrchantog <index>` - Enable/disable a channel

### Timing Commands
* `/bkrrate <seconds>` - Set the base interval (min 10)
* `/bkrvar <seconds>` - Set random time variance (0-60)
* `/bkrhours <start> <end>` - Set active hours (0-24)
* `/bkrday <1-7>` - Toggle day (1=Sun, 7=Sat)
* `/bkrmax <count>` - Set max messages (0=unlimited)

### Other Commands
* `/bkralt` - Toggle channel alternating
* `/bkrshow` - Toggle showing messages in chat
* `/bkrdebug` - Toggle debug mode
* `/bkrhelp` - Show help message

## Channel Types

Channel can be one of:
* `say` (or `s`)
* `yell` (or `y`)
* `guild` (or `g`)
* `raid` (or `ra`)
* `party` (or `p`)
* `instance` (or `i`)
* `bg` (Battleground)
* A channel number (e.g., `1` for General, `2` for Trade, etc.)

## Requirements

* Requires MessageQueue addon as a dependency
* Works with all versions of World of Warcraft (Retail, Classic, and Cataclysm Classic)

## Notes

* All settings are saved per character/realm
* Minimum message interval is 10 seconds to prevent chat spam
* Messages support item/spell links and other WoW hyperlinks
* Barker will automatically migrate settings from AutoFlood if you are upgrading