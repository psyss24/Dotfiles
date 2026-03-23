#!/bin/sh

source "$CONFIG_DIR/helpers/constants.sh"

get_app_icon() {
  local app_name="$1"
  echo "$($CONFIG_DIR/helpers/icon_map_fn.sh "$app_name")"
}

get_app_color() {
  local app_name="$1"

  case "$app_name" in
    "Spotify") echo "0xff1db954" ;;
    "Claude") echo "0xffb48ead" ;;
    "Firefox") echo "0xffff7139" ;;
    "Zed") echo "0xff1e90ff" ;;
    "Arc") echo "0xffff6b6b" ;;
    "Safari"|"Safari浏览器"|"Safari Technology Preview") echo "0xff0066cc" ;;
    "Google Chrome"|"Chromium"|"Google Chrome Canary") echo "0xff4285f4" ;;
    "Brave Browser") echo "0xfffb542b" ;;
    "Microsoft Edge") echo "0xff0078d4" ;;
    "Visual Studio Code"|"Code"|"Code - Insiders") echo "0xff007acc" ;;
    "Xcode") echo "0xff1575f9" ;;
    "Android Studio") echo "0xff3ddc84" ;;
    "GitHub Desktop") echo "0xff171515" ;;
    "Docker"|"Docker Desktop") echo "0xff2496ed" ;;
    "TablePlus") echo "0xff3694ff" ;;
    "Cursor") echo "0xff000000" ;;
    "Terminal"|"终端"|"ターミナル") echo "0xff000000" ;;
    "iTerm"|"iTerm2") echo "0xff1e2326" ;;
    "Warp") echo "0xff00d9ff" ;;
    "kitty") echo "0xfffffaa0" ;;
    "Alacritty"|"alacritty") echo "0xfff2c611" ;;
    "Ghostty") echo "0xff87ceeb" ;;
    "Discord"|"Discord Canary"|"Discord PTB") echo "0xff5865f2" ;;
    "Slack") echo "0xff4a154b" ;;
    "WhatsApp"|"‎WhatsApp") echo "0xff25d366" ;;
    "Telegram") echo "0xff26a5e4" ;;
    "Signal") echo "0xff3a76f0" ;;
    "Messages"|"信息"|"Nachrichten"|"メッセージ") echo "0xff34c759" ;;
    "Skype") echo "0xff00aff0" ;;
    "Zoom") echo "0xff2d8cff" ;;
    "Figma") echo "0xfff24e1e" ;;
    "Adobe Photoshop"*) echo "0xff31a8ff" ;;
    "Adobe Illustrator"*) echo "0xffff9a00" ;;
    "Adobe InDesign"*) echo "0xffff3366" ;;
    "Sketch") echo "0xfff5af02" ;;
    "Canva") echo "0xff8b46ff" ;;
    "Notion") echo "0xffffffff" ;;
    "Obsidian") echo "0xff483699" ;;
    "Bear") echo "0xffdc4c3e" ;;
    "Notes"|"备忘录"|"メモ") echo "0xffffc107" ;;
    "Evernote"*) echo "0xff00a82d" ;;
    "Logseq") echo "0xff2a2a2a" ;;
    "App Store") echo "0xff007aff" ;;
    "Books"|"Apple Books") echo "0xffff9500" ;;
    "Music"|"音乐"|"Musique"|"ミュージック") echo "0xfffa2d48" ;;
    "TV"|"Apple TV") echo "0xff1d1d1f" ;;
    "Photos") echo "0xff34c759" ;;
    "Calendar"|"日历"|"Calendrier"|"カレンダー") echo "0xffff3b30" ;;
    "Reminders"|"提醒事项"|"Rappels"|"リマインダー") echo "0xff007aff" ;;
    "FaceTime"|"FaceTime 通话") echo "0xff00c566" ;;
    "ChatGPT") echo "0xffffffff" ;;
    "Copilot") echo "0xff6366f1" ;;
    "Perplexity") echo "0xff20a39e" ;;
    "Raycast") echo "0xffff6363" ;;
    "Alfred") echo "0xff5c6bc0" ;;
    "1Password") echo "0xff0094e6" ;;
    "Bitwarden") echo "0xff175ddc" ;;
    "CleanMyMac"*) echo "0xff4285f4" ;;
    "Activity Monitor") echo "0xff34c759" ;;
    "System Preferences"|"System Settings"|"系统设置") echo "0xff8e8e93" ;;
    "VLC") echo "0xffff8800" ;;
    "IINA") echo "0xff5755d9" ;;
    "Plex") echo "0xffe5a00d" ;;
    "Netflix") echo "0xffe50914" ;;
    "YouTube") echo "0xffff0000" ;;
    "QuickTime Player") echo "0xff1d1d1f" ;;
    "Finder"|"访达") echo "0xff007aff" ;;
    "Path Finder") echo "0xffff6b35" ;;
    "Forklift") echo "0xff2e8b57" ;;
    "Commander One") echo "0xff4a90e2" ;;
    "TextEdit") echo "0xff1c1c1e" ;;
    "Sublime Text") echo "0xffff9800" ;;
    "Atom") echo "0xff1e1e1e" ;;
    "Vim"|"MacVim"|"VimR") echo "0xff019833" ;;
    "Emacs") echo "0xff7f5ab6" ;;
    "Nova") echo "0xff70b7d3" ;;
    "CotEditor") echo "0xff5cb3cc" ;;
    "Steam") echo "0xff1b2838" ;;
    "Epic Games Launcher") echo "0xff0078f2" ;;
    "Battle.net") echo "0xff0084d4" ;;
    "Blender") echo "0xfff5792a" ;;
    "Cinema 4D") echo "0xff011a6a" ;;
    "DaVinci Resolve") echo "0xffff2d55" ;;
    "Final Cut Pro") echo "0xff6c5ce7" ;;
    "Logic Pro") echo "0xff2d3748" ;;
    "GarageBand") echo "0xfffc6621" ;;
    "Vivaldi") echo "0xffef3939" ;;
    "Opera") echo "0xffff1b2d" ;;
    "Tor Browser") echo "0xff7e4798" ;;
    "Firefox Developer Edition") echo "0xff00d7ff" ;;
    "Mail"|"邮件"|"メール") echo "0xff007aff" ;;
    "Outlook"|"Microsoft Outlook") echo "0xff0078d4" ;;
    "Thunderbird") echo "0xff0a84ff" ;;
    "Spark") echo "0xffff6550" ;;
    "Airmail") echo "0xff37b24d" ;;
    *) echo "$BAR_ICON_COLOR_HIGHLIGHT" ;;
  esac
}

format_app_name() {
  local app_name="$1"

  app_name=$(echo "$app_name" | sed 's/ - .*$//')
  app_name=$(echo "$app_name" | sed 's/\.app$//')

  if [ ${#app_name} -gt 30 ]; then
    echo "${app_name:0:27}..."
  else
    echo "$app_name"
  fi
}

animate_app_change() {
  local app_name="$1"
  local app_icon="$2"
  local app_color="$3"
  local formatted_name="$4"

  sketchybar --set front_app \
                   icon="$app_icon" \
                   icon.color="$app_color" \
                   label="$formatted_name" \
                   label.color="$BAR_LABEL_COLOR_HIGHLIGHT" \
                   background.color=0x18ffffff \
                   background.border_width=1 \
                   background.border_color=0x30ffffff \
                   background.shadow.drawing=on \
                   background.shadow.color=0x04000000 \
                   background.shadow.angle=270 \
                   background.shadow.distance=1 \
                   drawing=on
}

hide_app() {
  sketchybar --animate sin 10 \
             --set front_app drawing=off
}

if [ "$SENDER" = "front_app_switched" ]; then
  APP_NAME="$INFO"

  if [ -z "$APP_NAME" ] || [ "$APP_NAME" = "" ] || [ "$APP_NAME" = "Finder" ]; then
    hide_app
  else
    APP_ICON=$(get_app_icon "$APP_NAME")
    FORMATTED_NAME=$(format_app_name "$APP_NAME")
    APP_COLOR=$(get_app_color "$APP_NAME")

    animate_app_change "$APP_NAME" "$APP_ICON" "$APP_COLOR" "$FORMATTED_NAME"
  fi
fi
