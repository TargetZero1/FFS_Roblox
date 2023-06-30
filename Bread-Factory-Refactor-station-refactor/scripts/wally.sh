#!/bin/bash
# A sample Bash script
echo Starting Wally Update	# This is a comment, too!
wally-update minor
wally install
sh scripts/sourcemap.sh
wally-package-types --sourcemap sourcemap.json Packages
echo Finishing Wally Update	# This is a comment, too!