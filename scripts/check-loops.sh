#!/bin/bash
# Run dependency graph analysis and cycle detection on specified source directory

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <opensim-common-dir> <tools-dir> [<results-dir>]"
  exit 1
fi

# Save current directory
ORIG_DIR=$(pwd)

SRC_DIR=$(realpath "$1")
TOOLS_DIR=$(realpath "$2")
RESULTS_DIR=$(realpath "${3:-logs}")
DOT_FILE="$RESULTS_DIR/opensim-common.dot"
LOG_SHORT_LOOP_FILE="$RESULTS_DIR/opensim-common-shortest-loops.log"
LOG_ALL_LOOP_FILE="$RESULTS_DIR/opensim-common-all-loops.log"

# Output files
BASE_NAME="opensim-common"
IMG_TYPE="svg"
OUT_PREFIX="j-opensim-common"
GRAPH_OUT="$RESULTS_DIR/$BASE_NAME.S.$IMG_TYPE"
TMP_SCC="$RESULTS_DIR/$OUT_PREFIX"

# Ensure results directory exists
mkdir -p "$RESULTS_DIR"

echo "Setting up Python virtual environment..."

# Create venv if not already present
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

# Activate venv
source .venv/bin/activate

# Install dependencies
if [ ! -f "requirements.txt" ]; then
  echo "requirements.txt not found in $(pwd)"
  exit 1
fi

pip install --upgrade pip > /dev/null
echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

echo "Running dependency analysis on: $SRC_DIR"
echo

# Step 1: Generate the dependency graph DOT file
echo "Generating DOT file..."
python3 $TOOLS_DIR/dependency_graph.py -c --cluster-labels "$SRC_DIR" "$DOT_FILE"

# Step 2: Detect cycles
echo "Finding shortest cycles..."
python3 $TOOLS_DIR/dot_find_cycles.py --only-shortest "$DOT_FILE" 2>&1 | tee "$LOG_SHORT_LOOP_FILE"

echo "Finding all cycles..."
python3 $TOOLS_DIR/dot_find_cycles.py "$DOT_FILE" > "$LOG_ALL_LOOP_FILE"

# Check if any loops were found
if grep -q -- '->' "$LOG_SHORT_LOOP_FILE"; then
  echo "Dependency cycles detected!"
  echo "See details in: $LOG_SHORT_LOOP_FILE"
  EXIT_WITH_ERROR=1
else
  echo "No cycles detected."
  EXIT_WITH_ERROR=0
fi

# Step 3: Process DOT with sccmap and colorize
echo "Coloring strongly connected components..."
sccmap "$DOT_FILE" -S > "$TMP_SCC"
gvpr -f $TOOLS_DIR/stronglyColored.gvpr "$TMP_SCC" "$DOT_FILE" | dot -T"$IMG_TYPE" > "$GRAPH_OUT"

# Cleanup intermediate file
rm "$TMP_SCC"

# Return to original directory
cd "$ORIG_DIR"

echo
echo "Dependency analysis complete."
echo "Output graph image: "$GRAPH_OUT""

# Exit with error if cycles were found
exit $EXIT_WITH_ERROR