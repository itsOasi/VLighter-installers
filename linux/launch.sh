#!/bin/bash
set -e

APP_NAME="VLighter"
INSTALL_DIR="$HOME/.local/share/$APP_NAME"

cd "$INSTALL_DIR"

echo "Pulling latest..."
git pull

echo "Installing dependencies..."
pipenv install

echo "Launching $APP_NAME..."
pipenv run python main.py