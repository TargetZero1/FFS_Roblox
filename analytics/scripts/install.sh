#!/usr/bin/env bash
# WARNING YOU ONLY RUN THIS ONCE, NEVER TWICE!
foreman install
sh scripts/wally.sh
pip install virtualenv
virtualenv .env
source .env/Scripts/Activate
pip install -r requirements.txt

# authorization info
# you'll need to do this afterwards, just run this command:
# midas auth-playfab

# playfab title-id: FAF6D
# playfab secret-key: P8RTXB1RG6WPACT7UEEM1M5PFQGFQJKMJHFR7CG3ON9R6XX5YO

# then run this command:
# midas auth-aad

# aad client-id: f0cea4a6-6f42-4cb4-aab3-9f95cab2a23c
# aad secret-value: xWX8Q~B_nKuRzt60MNABJAaInJPnax1lCMNt3bxz
# aad tenant-id: 23bc396d-18ee-4fcd-b259-78655a83767e

# then run
# sh analytics/scripts/update.sh
# works on unix and windows(Git Bash)
