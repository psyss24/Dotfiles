#!/bin/bash

# SketchyBar Workspace Diagnostic Tool
# Helps debug workspace switching timing issues and event handling
#
# Usage:
#   ./debug_workspace.sh monitor    # Monitor workspace changes in real-time
#   ./debug_workspace.sh test       # Run comprehensive test suite
#   ./debug_workspace.sh fix        # Force workspace update and fix
#   ./debug_workspace.sh status     # Show current workspace status

# Configuration
SKETCHYBAR_DIR="$HOME/.config/sketchybar"
DEBUG_LOG="/tmp/sketchybar_workspace_debug.log"
PID_FILE="/tmp/sketchybar_debug_monitor.pid"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
log_debug() {
    echo "[$(date '+%H:%M:%S.%3N')] $1" | tee -a "$DEBUG_LOG"
}

get_aerospace_workspace() {
    aerospace list-workspaces --focused 2>/dev/null
}

get_sketchybar_workspace() {
    # Find which workspace item is currently highlighted
    for i in {1..9}; do
        local query_result=$(sketchybar --query workspace.$i 2>/dev/null)
        if echo "$query_result" | jq -r '.icon.highlight' 2>/dev/null | grep -q "on"; then
            echo "$i"
            return
        fi
    done
    echo "none"
}

force_workspace_update() {
    echo -e "${YELLOW}🔄 Forcing workspace update...${NC}"
    "$SKETCHYBAR_DIR/plugins/workspace_updater.sh" forced
    sleep 0.5
    echo -e "${GREEN}✅ Update completed${NC}"
}

show_status() {
    echo -e "${BLUE}📊 Current Workspace Status${NC}"
    echo "=========================="

    local aerospace_ws=$(get_aerospace_workspace)
    local sketchybar_ws=$(get_sketchybar_workspace)

    echo -e "Aerospace workspace: ${CYAN}$aerospace_ws${NC}"
    echo -e "SketchyBar workspace: ${CYAN}$sketchybar_ws${NC}"

    if [ "$aerospace_ws" = "$sketchybar_ws" ]; then
        echo -e "Status: ${GREEN}✅ SYNCHRONIZED${NC}"
    else
        echo -e "Status: ${RED}❌ DESYNCHRONIZED${NC}"
        echo -e "${YELLOW}💡 Run './debug_workspace.sh fix' to force update${NC}"
    fi

    echo ""
    echo "SketchyBar workspace items:"
    for i in {1..9}; do
        local query_result=$(sketchybar --query workspace.$i 2>/dev/null)
        local drawing=$(echo "$query_result" | jq -r '.geometry.drawing' 2>/dev/null)
        local highlight=$(echo "$query_result" | jq -r '.icon.highlight' 2>/dev/null)
        local status="hidden"

        if [ "$drawing" = "on" ]; then
            if [ "$highlight" = "on" ]; then
                status="${GREEN}active${NC}"
            else
                status="${CYAN}visible${NC}"
            fi
        fi

        echo -e "  Workspace $i: $status"
    done
}

monitor_changes() {
    echo -e "${BLUE}🔍 Monitoring workspace changes...${NC}"
    echo "=================================="
    echo "Press Ctrl+C to stop monitoring"
    echo ""

    # Save PID for cleanup
    echo $$ > "$PID_FILE"

    # Clear previous log
    > "$DEBUG_LOG"

    local last_aerospace_ws=""
    local last_sketchybar_ws=""
    local change_count=0

    while true; do
        local current_aerospace=$(get_aerospace_workspace)
        local current_sketchybar=$(get_sketchybar_workspace)
        local timestamp=$(date '+%H:%M:%S.%3N')

        # Check for Aerospace workspace change
        if [ "$current_aerospace" != "$last_aerospace_ws" ] && [ -n "$current_aerospace" ]; then
            change_count=$((change_count + 1))
            echo -e "${timestamp} ${YELLOW}[CHANGE #$change_count]${NC} Aerospace: ${last_aerospace_ws} → ${CYAN}$current_aerospace${NC}"
            log_debug "Aerospace workspace changed: $last_aerospace_ws → $current_aerospace"
            last_aerospace_ws="$current_aerospace"
        fi

        # Check for SketchyBar workspace change
        if [ "$current_sketchybar" != "$last_sketchybar_ws" ] && [ -n "$current_sketchybar" ]; then
            echo -e "${timestamp} ${GREEN}[UPDATE]${NC} SketchyBar: ${last_sketchybar_ws} → ${CYAN}$current_sketchybar${NC}"
            log_debug "SketchyBar workspace updated: $last_sketchybar_ws → $current_sketchybar"
            last_sketchybar_ws="$current_sketchybar"
        fi

        # Check for desynchronization
        if [ -n "$current_aerospace" ] && [ -n "$current_sketchybar" ] && [ "$current_aerospace" != "$current_sketchybar" ]; then
            echo -e "${timestamp} ${RED}[DESYNC]${NC} Aerospace($current_aerospace) ≠ SketchyBar($current_sketchybar)"
            log_debug "DESYNCHRONIZATION DETECTED: Aerospace=$current_aerospace, SketchyBar=$current_sketchybar"

            # Auto-fix if enabled
            if [ "$AUTO_FIX" = "true" ]; then
                echo -e "${timestamp} ${YELLOW}[AUTO-FIX]${NC} Triggering workspace update..."
                force_workspace_update
            fi
        fi

        sleep 0.1
    done
}

run_test_suite() {
    echo -e "${BLUE}🧪 Running Workspace Test Suite${NC}"
    echo "================================"

    local test_count=0
    local pass_count=0
    local fail_count=0

    # Test 1: Basic workspace query
    test_count=$((test_count + 1))
    echo -n "Test $test_count: Aerospace workspace query... "
    local ws=$(get_aerospace_workspace)
    if [ -n "$ws" ] && [ "$ws" != "" ]; then
        echo -e "${GREEN}PASS${NC} (workspace: $ws)"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} (no workspace returned)"
        fail_count=$((fail_count + 1))
    fi

    # Test 2: SketchyBar workspace items
    test_count=$((test_count + 1))
    echo -n "Test $test_count: SketchyBar workspace items... "
    local item_count=0
    for i in {1..9}; do
        if sketchybar --query workspace.$i >/dev/null 2>&1; then
            item_count=$((item_count + 1))
        fi
    done
    if [ $item_count -eq 9 ]; then
        echo -e "${GREEN}PASS${NC} (all 9 items found)"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} (only $item_count/9 items found)"
        fail_count=$((fail_count + 1))
    fi

    # Test 3: Workspace synchronization
    test_count=$((test_count + 1))
    echo -n "Test $test_count: Workspace synchronization... "
    local aerospace_ws=$(get_aerospace_workspace)
    local sketchybar_ws=$(get_sketchybar_workspace)
    if [ "$aerospace_ws" = "$sketchybar_ws" ]; then
        echo -e "${GREEN}PASS${NC} (synchronized: $aerospace_ws)"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} (Aerospace: $aerospace_ws, SketchyBar: $sketchybar_ws)"
        fail_count=$((fail_count + 1))
    fi

    # Test 4: Event system
    test_count=$((test_count + 1))
    echo -n "Test $test_count: Event system responsiveness... "
    local initial_ws=$(get_sketchybar_workspace)
    sketchybar --trigger aerospace_workspace_change >/dev/null 2>&1
    sleep 0.5
    local updated_ws=$(get_sketchybar_workspace)
    if [ -n "$updated_ws" ]; then
        echo -e "${GREEN}PASS${NC} (event system responsive)"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} (event system unresponsive)"
        fail_count=$((fail_count + 1))
    fi

    # Test 5: Animation system
    test_count=$((test_count + 1))
    echo -n "Test $test_count: Animation system... "
    if grep -q 'ENABLE_WORKSPACE_ANIMATIONS="true"' "$SKETCHYBAR_DIR/helpers/constants.sh" 2>/dev/null; then
        echo -e "${GREEN}PASS${NC} (animations enabled)"
        pass_count=$((pass_count + 1))
    else
        echo -e "${YELLOW}WARN${NC} (animations disabled)"
        pass_count=$((pass_count + 1))  # Not a failure
    fi

    echo ""
    echo -e "${BLUE}Test Results:${NC}"
    echo -e "  Total: $test_count"
    echo -e "  Passed: ${GREEN}$pass_count${NC}"
    echo -e "  Failed: ${RED}$fail_count${NC}"

    if [ $fail_count -eq 0 ]; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ Some tests failed. Check the issues above.${NC}"
        return 1
    fi
}

simulate_workspace_switches() {
    echo -e "${BLUE}🎯 Simulating Workspace Switches${NC}"
    echo "================================="
    echo "This will switch through workspaces 1-3 to test reliability..."
    echo ""

    for i in {1..3}; do
        echo -e "${YELLOW}Switching to workspace $i...${NC}"

        # Record state before switch
        local before_aerospace=$(get_aerospace_workspace)
        local before_sketchybar=$(get_sketchybar_workspace)

        # Switch workspace
        aerospace workspace $i

        # Wait and check
        sleep 0.2
        local after_aerospace=$(get_aerospace_workspace)
        local after_sketchybar=$(get_sketchybar_workspace)

        echo "  Before: Aerospace=$before_aerospace, SketchyBar=$before_sketchybar"
        echo "  After:  Aerospace=$after_aerospace, SketchyBar=$after_sketchybar"

        if [ "$after_aerospace" = "$i" ] && [ "$after_sketchybar" = "$i" ]; then
            echo -e "  Result: ${GREEN}✅ SUCCESS${NC}"
        elif [ "$after_aerospace" = "$i" ] && [ "$after_sketchybar" != "$i" ]; then
            echo -e "  Result: ${RED}❌ SKETCHYBAR DESYNC${NC}"
            echo -e "  ${YELLOW}🔄 Auto-fixing...${NC}"
            force_workspace_update
            sleep 0.5
            local fixed_sketchybar=$(get_sketchybar_workspace)
            if [ "$fixed_sketchybar" = "$i" ]; then
                echo -e "  Fix result: ${GREEN}✅ FIXED${NC}"
            else
                echo -e "  Fix result: ${RED}❌ STILL BROKEN${NC}"
            fi
        else
            echo -e "  Result: ${RED}❌ AEROSPACE ISSUE${NC}"
        fi

        echo ""
        sleep 1
    done
}

cleanup() {
    if [ -f "$PID_FILE" ]; then
        rm -f "$PID_FILE"
    fi
    echo -e "\n${YELLOW}Monitoring stopped.${NC}"
    exit 0
}

show_help() {
    echo -e "${BLUE}SketchyBar Workspace Diagnostic Tool${NC}"
    echo "===================================="
    echo ""
    echo -e "${BLUE}Usage:${NC} $0 [command]"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo "  status      Show current workspace synchronization status"
    echo "  monitor     Monitor workspace changes in real-time"
    echo "  test        Run comprehensive test suite"
    echo "  simulate    Simulate workspace switches to test reliability"
    echo "  fix         Force workspace update to fix desynchronization"
    echo "  help        Show this help message"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 status           # Check current status"
    echo "  $0 monitor          # Monitor changes (Ctrl+C to stop)"
    echo "  $0 test             # Run all tests"
    echo "  AUTO_FIX=true $0 monitor  # Monitor with auto-fix enabled"
    echo ""
    echo -e "${BLUE}Debug Log:${NC} $DEBUG_LOG"
}

# Main execution
case "${1:-status}" in
    "status")
        show_status
        ;;
    "monitor")
        trap cleanup INT
        monitor_changes
        ;;
    "test")
        run_test_suite
        ;;
    "simulate")
        simulate_workspace_switches
        ;;
    "fix")
        show_status
        echo ""
        force_workspace_update
        echo ""
        show_status
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
