#!/bin/bash

SKETCHYBAR_DIR="$HOME/.config/sketchybar"
CONSTANTS_FILE="$SKETCHYBAR_DIR/helpers/constants.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}🎬 SketchyBar Animation Control${NC}"
    echo "=============================="
}

get_current_status() {
    if grep -q 'ENABLE_WORKSPACE_ANIMATIONS="true"' "$CONSTANTS_FILE" 2>/dev/null; then
        echo "enabled"
    else
        echo "disabled"
    fi
}

show_current_status() {
    local status=$(get_current_status)
    echo ""
    if [ "$status" = "enabled" ]; then
        echo -e "📊 Current Status: ${GREEN}✅ ANIMATIONS ENABLED${NC}"
        echo "   • Smooth workspace highlighting transitions"
        echo "   • Fluid app icon updates"
        echo "   • Elegant visibility animations"
        echo "   • Stylish workspace switching effects"
    else
        echo -e "📊 Current Status: ${RED}❌ ANIMATIONS DISABLED${NC}"
        echo "   • Instant workspace updates"
        echo "   • No transition effects"
        echo "   • Maximum performance mode"
    fi
    echo ""
}

enable_animations() {
    echo -e "${YELLOW}🔄 Enabling animations...${NC}"

    sed -i.bak 's/ENABLE_WORKSPACE_ANIMATIONS="false"/ENABLE_WORKSPACE_ANIMATIONS="true"/' "$CONSTANTS_FILE"

    echo "   🔄 Reloading SketchyBar configuration..."
    "$SKETCHYBAR_DIR/reload.sh" > /dev/null 2>&1

    "$SKETCHYBAR_DIR/plugins/workspace_updater.sh" > /dev/null 2>&1

    echo -e "${GREEN}✅ Animations enabled successfully!${NC}"
    echo ""
    echo -e "${BLUE}🎨 Animation Features Active:${NC}"
    echo "   • Elastic highlighting for active workspace"
    echo "   • Smooth app icon transitions"
    echo "   • Fade in/out effects for workspace visibility"
    echo "   • Gentle pulse effects on workspace changes"
    echo ""
    echo -e "${YELLOW}💡 Test by switching workspaces: Alt+1 through Alt+9${NC}"
}

disable_animations() {
    echo -e "${YELLOW}🔄 Disabling animations...${NC}"

    sed -i.bak 's/ENABLE_WORKSPACE_ANIMATIONS="true"/ENABLE_WORKSPACE_ANIMATIONS="false"/' "$CONSTANTS_FILE"

    echo "   🔄 Reloading SketchyBar configuration..."
    "$SKETCHYBAR_DIR/reload.sh" > /dev/null 2>&1

    "$SKETCHYBAR_DIR/plugins/workspace_updater.sh" disable_animations > /dev/null 2>&1

    echo -e "${GREEN}✅ Animations disabled successfully!${NC}"
    echo ""
    echo -e "${BLUE}⚡ Performance Mode Active:${NC}"
    echo "   • Instant workspace updates"
    echo "   • No transition delays"
    echo "   • Minimal resource usage"
    echo "   • Maximum responsiveness"
    echo ""
    echo -e "${YELLOW}💡 Workspace switching is now instant${NC}"
}

toggle_animations() {
    local current_status=$(get_current_status)

    if [ "$current_status" = "enabled" ]; then
        disable_animations
    else
        enable_animations
    fi
}

show_help() {
    echo -e "${BLUE}Usage:${NC} $0 [option]"
    echo ""
    echo -e "${BLUE}Options:${NC}"
    echo "  enable      Enable workspace animations"
    echo "  disable     Disable workspace animations"
    echo "  toggle      Toggle animation state"
    echo "  status      Show current animation status"
    echo "  help        Show this help message"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 enable           # Enable smooth animations"
    echo "  $0 disable          # Disable for performance"
    echo "  $0 toggle           # Switch current state"
    echo "  $0 status           # Check current setting"
    echo ""
    echo -e "${BLUE}Animation Details:${NC}"
    echo "  • Elastic highlighting: Subtle bounce when workspace becomes active"
    echo "  • Smooth transitions: Fluid app icon updates with tanh easing"
    echo "  • Fade effects: Graceful show/hide with sine wave transitions"
    echo "  • Pulse feedback: Gentle visual confirmation on workspace changes"
    echo ""
    echo -e "${YELLOW}💡 Tip: Use 'disable' for debugging or maximum performance${NC}"
}

if [ ! -f "$CONSTANTS_FILE" ]; then
    echo -e "${RED}❌ Error: SketchyBar configuration not found${NC}"
    echo "Expected location: $CONSTANTS_FILE"
    exit 1
fi

print_status

case "${1:-status}" in
    "enable"|"on")
        enable_animations
        ;;
    "disable"|"off")
        disable_animations
        ;;
    "toggle"|"switch")
        toggle_animations
        ;;
    "status"|"check")
        show_current_status
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        show_current_status
        echo -e "${YELLOW}💡 Run '$0 help' for usage options${NC}"
        ;;
esac

echo ""
echo -e "${BLUE}🔧 Quick Commands:${NC}"
echo "  Toggle: $0 toggle"
echo "  Status: $0 status"
echo "  Help:   $0 help"
