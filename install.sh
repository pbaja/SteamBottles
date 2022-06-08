#!/bin/bash

# Configuration
BRANCH="main"
INSTALLATION_DIR=~/SteamJar
REPOSITORY_URL="https://raw.githubusercontent.com/pbaja/SteamJar/$BRANCH"

# Liftoff
echo '=> Welcome to the SteamJar installer!'

# Check installed version
installed_version=0
if [[ -f $INSTALLATION_DIR/version.txt ]]; then
    installed_version=$(cat $INSTALLATION_DIR/version.txt)
    echo "-> Installed version: "$installed_version
    installed_version=$(sed 's/[^0-9]*//g' <<< "$installed_version")
else
    echo "-> No installation found"
fi

# Check latest version
latest_version=$(curl -s -f $REPOSITORY_URL/version.txt)
if [[ "$?" -ne "0" ]]; then
    echo "-> Failed to check latest version"
    latest_version=0
    exit 1
else
    echo "-> Latest version: "$latest_version
    latest_version=$(sed 's/[^0-9]*//g' <<< "$latest_version")
fi

# Check if a latest version is newer
if [[ "$installed_version" -ge "$latest_version" ]]; then
    echo "-> Latest version is already installed"
    exit 0
fi

# Remove old files, create new directory
echo "-> Removing previous installation if exists"
rm -r "$INSTALLATION_DIR" &> /dev/null
mkdir "$INSTALLATION_DIR"

# Download latest zip
echo "-> Downloading latest version..."
curl -fsL "https://github.com/pbaja/SteamJar/archive/refs/heads/$BRANCH.zip" --output "/tmp/SteamJar.zip"
if [[ "$?" -ne "0" ]]; then
    echo "-> Failed to download"
    exit 2
fi

# Unzip
echo "-> Unpacking archive"
bsdtar xf "/tmp/SteamJar.zip" -C "/tmp"
rm /tmp/SteamJar.zip

# Move to installation directory
echo "-> Moving files"
mv "/tmp/SteamJar-$BRANCH"/* "$INSTALLATION_DIR"
rm -r "/tmp/SteamJar-$BRANCH"

# Link desktop shortcut
echo "-> Creating desktop shortcut"
rm ~/Desktop/SteamJar.desktop &> /dev/null
ln -s "$INSTALLATION_DIR/SteamJar.desktop" ~/Desktop/SteamJar.desktop

# Bye
echo '=> Finished! Starting SteamJar'
python "$INSTALLATION_DIR/run.py"
