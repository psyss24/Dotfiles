#!/bin/bash

SKETCHYBAR_DIR="$HOME/.config/sketchybar"
STATE_FILE="/tmp/sketchybar_pomodoro_state"
PLUGIN_SCRIPT="$SKETCHYBAR_DIR/plugins/pomodoro.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

WORK_DURATION=1500
SHORT_BREAK=300
LONG_BREAK=900
POMODOROS_UNTIL_LONG=4

print_header() {
    echo -e "${BLUE}🍅 SketchyBar Pomodoro Control${NC}"
    echo "=============================="
}

format_time() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d" $minutes $secs
}

get_state() {
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    else
        STATE="idle"
        REMAINING=0
        SESSION_TYPE="work"
        POMODORO_COUNT=0
    fi
}

show_status() {
    get_state
    echo ""
    echo -e "${CYAN}📊 Current Status${NC}"
    echo "----------------"

    case "$STATE" in
        "idle")
            echo -e "State: ${YELLOW}💤 Idle${NC}"
            ;;
        "running")
            case "$SESSION_TYPE" in
                "work")
                    echo -e "State: ${RED}🔥 Working${NC}"
                    ;;
                "short_break")
                    echo -e "State: ${GREEN}☕ Short Break${NC}"
                    ;;
                "long_break")
                    echo -e "State: ${BLUE}🌴 Long Break${NC}"
                    ;;
            esac
            echo -e "Time Remaining: ${CYAN}$(format_time $REMAINING)${NC}"

            local session_duration
            case "$SESSION_TYPE" in
                "work") session_duration=$WORK_DURATION ;;
                "short_break") session_duration=$SHORT_BREAK ;;
                "long_break") session_duration=$LONG_BREAK ;;
            esac
            local elapsed=$((session_duration - REMAINING))
            local progress=$((elapsed * 100 / session_duration))
            echo -e "Progress: ${CYAN}${progress}%${NC}"

            local bar_length=20
            local filled=$((progress * bar_length / 100))
            local empty=$((bar_length - filled))
            printf "Progress: ["
            printf "%*s" $filled | tr ' ' '█'
            printf "%*s" $empty | tr ' ' '░'
            printf "] %d%%\n" $progress
            ;;
        "paused")
            echo -e "State: ${YELLOW}⏸️  Paused${NC}"
            echo -e "Time Remaining: ${CYAN}$(format_time $REMAINING)${NC}"
            ;;
        "complete")
            echo -e "State: ${GREEN}✅ Complete${NC}"
            case "$SESSION_TYPE" in
                "work")
                    echo -e "Next: ${GREEN}Break time!${NC}"
                    ;;
                *)
                    echo -e "Next: ${RED}Work session${NC}"
                    ;;
            esac
            ;;
    esac

    echo -e "Session Type: ${PURPLE}$(echo $SESSION_TYPE | tr '_' ' ' | sed 's/\b\w/\u&/g')${NC}"
    echo -e "Pomodoros Completed: ${CYAN}$POMODORO_COUNT${NC}"

    local until_long=$((POMODOROS_UNTIL_LONG - (POMODORO_COUNT % POMODOROS_UNTIL_LONG)))
    if [ $until_long -eq $POMODOROS_UNTIL_LONG ]; then
        echo -e "Next Long Break: ${BLUE}After this cycle${NC}"
    else
        echo -e "Pomodoros Until Long Break: ${CYAN}$until_long${NC}"
    fi
}

start_session() {
    echo -e "${GREEN}🚀 Starting work session...${NC}"
    "$PLUGIN_SCRIPT" "toggle"
    sleep 1
    show_status
}

pause_timer() {
    get_state
    if [ "$STATE" = "running" ]; then
        echo -e "${YELLOW}⏸️  Pausing timer...${NC}"
        "$PLUGIN_SCRIPT" "toggle"
    elif [ "$STATE" = "paused" ]; then
        echo -e "${GREEN}▶️  Resuming timer...${NC}"
        "$PLUGIN_SCRIPT" "toggle"
    else
        echo -e "${RED}❌ No active session to pause${NC}"
    fi
    sleep 1
    show_status
}

reset_timer() {
    echo -e "${RED}🔄 Resetting timer...${NC}"
    "$PLUGIN_SCRIPT" "reset"
    sleep 1
    show_status
}

skip_session() {
    get_state
    if [ "$STATE" = "complete" ]; then
        echo -e "${CYAN}⏭️  Skipping to next session...${NC}"
        "$PLUGIN_SCRIPT" "next"
    else
        echo -e "${RED}❌ Can only skip when session is complete${NC}"
    fi
    sleep 1
    show_status
}

run_demo() {
    echo -e "${PURPLE}🎬 Running Pomodoro Demo${NC}"
    echo "========================"
    echo ""
    echo "This demo will show you the Pomodoro timer in action with accelerated timing."
    echo "Watch the SketchyBar widget change colors and states!"
    echo ""
    read -p "Press Enter to start demo..."

    sed -i.bak 's/WORK_DURATION=1500/WORK_DURATION=10/' "$PLUGIN_SCRIPT"
    sed -i.bak 's/SHORT_BREAK=300/SHORT_BREAK=5/' "$PLUGIN_SCRIPT"
    sed -i.bak 's/LONG_BREAK=900/LONG_BREAK=8/' "$PLUGIN_SCRIPT"

    echo ""
    echo -e "${GREEN}1. Starting work session (10 seconds)...${NC}"
    "$PLUGIN_SCRIPT" "toggle"

    sleep 11

    echo -e "${GREEN}2. Work complete! Starting break (5 seconds)...${NC}"
    "$PLUGIN_SCRIPT" "next"

    sleep 6

    echo -e "${GREEN}3. Break complete! Demo finished.${NC}"

    mv "$PLUGIN_SCRIPT.bak" "$PLUGIN_SCRIPT"
    chmod +x "$PLUGIN_SCRIPT"

    "$PLUGIN_SCRIPT" "reset"

    echo ""
    echo -e "${BLUE}✨ Demo complete! Timer reset to normal durations.${NC}"
}

run_test_suite() {
    echo -e "${PURPLE}🧪 Interactive Pomodoro Test Suite${NC}"
    echo "=================================="
    echo ""

    local test_count=0
    local pass_count=0

    test_count=$((test_count + 1))
    echo -n "Test $test_count: State initialization... "
    "$PLUGIN_SCRIPT" "reset" > /dev/null
    get_state
    if [ "$STATE" = "idle" ]; then
        echo -e "${GREEN}PASS${NC}"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} (state: $STATE)"
    fi

    test_count=$((test_count + 1))
    echo -n "Test $test_count: Start work session... "
    "$PLUGIN_SCRIPT" "toggle" > /dev/null
    sleep 1
    get_state
    if [ "$STATE" = "running" ] && [ "$SESSION_TYPE" = "work" ]; then
        echo -e "${GREEN}PASS${NC}"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} (state: $STATE, type: $SESSION_TYPE)"
    fi

    test_count=$((test_count + 1))
    echo -n "Test $test_count: Pause and resume... "
    "$PLUGIN_SCRIPT" "toggle" > /dev/null
    sleep 1
    get_state
    local paused_state="$STATE"
    "$PLUGIN_SCRIPT" "toggle" > /dev/null
    sleep 1
    get_state
    if [ "$paused_state" = "paused" ] && [ "$STATE" = "running" ]; then
        echo -e "${GREEN}PASS${NC}"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} (pause: $paused_state, resume: $STATE)"
    fi

    test_count=$((test_count + 1))
    echo -n "Test $test_count: Widget visibility... "
    local widget_status=$(sketchybar --query pomodoro | jq -r '.geometry.drawing' 2>/dev/null)
    if [ "$widget_status" = "on" ]; then
        echo -e "${GREEN}PASS${NC}"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} (widget not visible during active session)"
    fi

    test_count=$((test_count + 1))
    echo -n "Test $test_count: Reset to idle... "
    "$PLUGIN_SCRIPT" "reset" > /dev/null
    sleep 1
    get_state
    local widget_status=$(sketchybar --query pomodoro | jq -r '.geometry.drawing' 2>/dev/null)
    if [ "$STATE" = "idle" ] && [ "$widget_status" = "off" ]; then
        echo -e "${GREEN}PASS${NC}"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} (state: $STATE, widget: $widget_status)"
    fi

    echo ""
    echo -e "${BLUE}Test Results:${NC}"
    echo "  Total: $test_count"
    echo -e "  Passed: ${GREEN}$pass_count${NC}"
    echo -e "  Failed: ${RED}$((test_count - pass_count))${NC}"

    if [ $pass_count -eq $test_count ]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
    else
        echo -e "${YELLOW}⚠️  Some tests failed. Check the implementation.${NC}"
    fi
}

show_config() {
    echo ""
    echo -e "${CYAN}⚙️  Pomodoro Configuration${NC}"
    echo "------------------------"
    echo -e "Work Duration: ${CYAN}$(format_time $WORK_DURATION)${NC}"
    echo -e "Short Break: ${CYAN}$(format_time $SHORT_BREAK)${NC}"
    echo -e "Long Break: ${CYAN}$(format_time $LONG_BREAK)${NC}"
    echo -e "Pomodoros Until Long Break: ${CYAN}$POMODOROS_UNTIL_LONG${NC}"
    echo ""
    echo -e "State File: ${YELLOW}$STATE_FILE${NC}"
    echo -e "Plugin Script: ${YELLOW}$PLUGIN_SCRIPT${NC}"
    echo ""

    echo -e "${CYAN}🔊 Testing Sound Notifications...${NC}"
    if command -v afplay > /dev/null; then
        echo -e "Sound System: ${GREEN}✅ Available${NC}"
        echo "Testing notification sound..."
        afplay /System/Library/Sounds/Tink.aiff 2>/dev/null &
    else
        echo -e "Sound System: ${RED}❌ Not Available${NC}"
    fi
}

toggle_sounds() {
    echo -e "${YELLOW}🔊 Sound toggle functionality${NC}"
    echo "To toggle sounds, edit the SOUND_ENABLED variable in:"
    echo "$PLUGIN_SCRIPT"
}

show_help() {
    echo ""
    echo -e "${BLUE}Usage:${NC} $0 [command]"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo "  start           Start a work session"
    echo "  pause           Pause current session"
    echo "  resume          Resume paused session (same as pause)"
    echo "  reset           Reset timer to idle"
    echo "  skip            Skip to next session (when complete)"
    echo "  status          Show detailed status"
    echo "  test            Run interactive test suite"
    echo "  demo            Run demonstration sequence"
    echo "  config          Show configuration details"
    echo "  sounds          Show sound information"
    echo "  help            Show this help message"
    echo ""
    echo -e "${BLUE}Interactive Controls:${NC}"
    echo "  Left Click      Start/Pause/Resume timer"
    echo "  Right Click     Reset timer"
    echo "  Middle Click    Skip to next session"
    echo "  Shift+Click     Show status in terminal"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 start        # Start a 25-minute work session"
    echo "  $0 status       # Check current timer status"
    echo "  $0 demo         # Run quick demonstration"
    echo "  $0 test         # Validate timer functionality"
}

validate_environment() {
    if [ ! -f "$PLUGIN_SCRIPT" ]; then
        echo -e "${RED}❌ Error: Pomodoro plugin not found${NC}"
        echo "Expected location: $PLUGIN_SCRIPT"
        exit 1
    fi

    if ! pgrep -x "sketchybar" > /dev/null; then
        echo -e "${YELLOW}⚠️  Warning: SketchyBar is not running${NC}"
        echo "The timer will work, but the widget won't be visible."
        echo ""
    fi

    if ! command -v jq > /dev/null; then
        echo -e "${YELLOW}⚠️  Warning: jq not found (some tests may fail)${NC}"
        echo "Install with: brew install jq"
        echo ""
    fi
}

main() {
    print_header
    validate_environment

    case "${1:-status}" in
        "start")
            start_session
            ;;
        "pause"|"resume")
            pause_timer
            ;;
        "reset")
            reset_timer
            ;;
        "skip"|"next")
            skip_session
            ;;
        "status")
            show_status
            ;;
        "test")
            run_test_suite
            ;;
        "demo")
            run_demo
            ;;
        "config")
            show_config
            ;;
        "sounds")
            toggle_sounds
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
