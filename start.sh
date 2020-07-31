#!/bin/bash

echo "starting instantCI"

source ./utils.sh || exit 1

checkvar "$SURGEMAIL"
checkvar "$SURGEPASS"
