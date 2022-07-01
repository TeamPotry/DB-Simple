#!/bin/bash
# a batch file, used for codespace.
# use this before compile at first time.

cd /

# delete stuff that already downloaded.
sudo rm -rf ./sourcemod_lib ./sourcemod-latest-linux
sudo mkdir ./sourcemod_lib && cd ./sourcemod_lib
# download SourceMod
sudo wget --input-file=http://sourcemod.net/smdrop/1.10/sourcemod-latest-linux
sudo tar -xzf $(cat sourcemod-latest-linux)

# delete unneccessry folders.
sudo mv ./addons/sourcemod/scripting/* ./ 
sudo rm -rf ./addons ./cfg

# Setup Include (same as Github Action)
# Nothing for now.