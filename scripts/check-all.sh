#!/bin/bash

# Don't exit immediately; we want to run all checks
set +e

# Original working directory
ORIG_DIR="$(pwd)"

# Variables
SCRIPT_DIR="./scripts"
OPENSIM_SOURCE_DIR="$HOME/opensim-workspace/opensim-core-source"
OPENSIM_BUILD_DIR="$HOME/opensim-workspace/opensim-core-build"
TOOLS_DIR="$ORIG_DIR/tools"

# Run check-format.sh
echo "Running check-format.sh..."
"$SCRIPT_DIR/check-format.sh" "$OPENSIM_SOURCE_DIR" "$TOOLS_DIR"
ret1=$?
echo "check-format.sh exited with code $ret1"
echo

# Run check-iwyu.sh
echo "Running check-iwyu.sh..."
"$SCRIPT_DIR/check-iwyu.sh" "$OPENSIM_SOURCE_DIR" "$OPENSIM_BUILD_DIR" "main"
ret2=$?
echo "check-iwyu.sh exited with code $ret2"
echo

# Run check-tabs.sh
echo "Running check-tabs.sh..."
"$SCRIPT_DIR/check-tabs.sh" "$OPENSIM_SOURCE_DIR"
ret3=$?
echo "check-tabs.sh exited with code $ret3"
echo

# Run check-tidy.sh
# echo "Running check-tidy.sh..."
# "$SCRIPT_DIR/check-tidy.sh" "$OPENSIM_SOURCE_DIR" "$OPENSIM_BUILD_DIR" "$TOOLS_DIR"
# ret4=$?
# echo "check-tidy.sh exited with code $ret4"
# echo

# Run check-loops.sh
echo "Running check-loops.sh..."
"$SCRIPT_DIR/check-loops.sh" "$OPENSIM_SOURCE_DIR/OpenSim/Common" "$TOOLS_DIR"
ret5=$?
echo "check-loops.sh exited with code $ret5"
echo

# Summary
echo "Summary:"
echo "check-format.sh: exit code $ret1"
echo "check-iwyu.sh:  exit code $ret2"
echo "check-tabs.sh:  exit code $ret3"
# echo "check-tidy.sh:  exit code $ret4"
echo "check-loops.sh:  exit code $ret5"
