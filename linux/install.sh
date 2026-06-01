#!/bin/bash
set -e

APP_NAME="VLighter"
INSTALL_DIR="$HOME/.local/share/$APP_NAME"
REPO_URL="https://github.com/innovainformationtechnologies/VLighter.git"

echo "Installing $APP_NAME..."

# ── Detect package manager ────────────────────────────────────────────────────
if command -v apt &>/dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
    UPDATE_CMD="sudo apt update"
elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
    UPDATE_CMD=""
elif command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    UPDATE_CMD="sudo pacman -Sy"
else
    echo "No supported package manager found (apt, dnf, pacman). Please install git, python, and pipenv manually."
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"

# ── Git ───────────────────────────────────────────────────────────────────────
if ! command -v git &>/dev/null; then
    echo "Installing git..."
    [ -n "$UPDATE_CMD" ] && $UPDATE_CMD
    $INSTALL_CMD git
fi

# ── Python ────────────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo "Installing python..."
    $INSTALL_CMD python3
fi

# ── Pip ───────────────────────────────────────────────────────────────────────
if ! command -v pip3 &>/dev/null; then
    echo "Installing pip..."
    $INSTALL_CMD python3-pip
fi

# ── Pipenv ────────────────────────────────────────────────────────────────────
if ! command -v pipenv &>/dev/null; then
    echo "Installing pipenv..."
    pip3 install --user pipenv
    export PATH="$HOME/.local/bin:$PATH"
fi

# ── FFmpeg ────────────────────────────────────────────────────────────────────
if ! command -v ffmpeg &>/dev/null; then
    echo "Installing ffmpeg..."
    $INSTALL_CMD ffmpeg
fi

# ── Clone and install ─────────────────────────────────────────────────────────
git clone "$REPO_URL" "$INSTALL_DIR"
cd "$INSTALL_DIR"
pipenv install

# ── Copy launcher ─────────────────────────────────────────────────────────────
cp "$(dirname "$0")/launch.sh" "$INSTALL_DIR/launch.sh"
chmod +x "$INSTALL_DIR/launch.sh"

# ── Desktop shortcut ──────────────────────────────────────────────────────────
cat > "$HOME/Desktop/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=bash $INSTALL_DIR/launch.sh
Type=Application
Terminal=true
EOF

chmod +x "$HOME/Desktop/$APP_NAME.desktop"

echo "Done! Shortcut created on Desktop."
# wait for user to close the window
read -n 1 -s -r -p "Press any key to exit..."