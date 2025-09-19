# opensim-core-code-analysis
```bash
./scripts/check-format.sh ~/opensim-workspace/opensim-core-source ./tools
./scripts/check-iwyu.sh ~/opensim-workspace/opensim-core-source ~/opensim-workspace/opensim-core-build "main"
./scripts/check-tabs.sh ~/opensim-workspace/opensim-core-source
./scripts/check-tidy.sh ~/opensim-workspace/opensim-core-source ~/opensim-workspace/opensim-core-build ./tools
./scripts/check-loops.sh ~/opensim-workspace/opensim-core-source/OpenSim/Common ./tools

./scripts/check-format.sh ~/opensim-workspace/simbody-source ./tools -b master
 ```

To analyze cmake add `--graphviz=deps.dot` and make sure you have `graphviz` installed and pathed

> For large graphs it may take a very long time to render. You can break out of the script (ctrl+c) as soon as the dot file is generated.
For this repo
```
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

```
python3 dependency_graph.py -c --cluster-labels ~/opensim-workspace/opensim-core-source/ results/whole-opensim.dot
python3 dependency_graph.py -c --cluster-labels ~/opensim-workspace/opensim-core-source/OpenSim/ results/opensim.dot
python3 dependency_graph.py -s ~/opensim-workspace/opensim-core-source/OpenSim/Common/ results/opensim-common.dot
```

```
f=opensim-common.dot
F=${f%.*}
T=png
out=j-opensim-common
sccmap $f -S > $out
gvpr -f ../stronglyColored.gvpr  $out  $f  | dot -T$T >$F.S.$T

```

find cycles:
```
python3 dot_find_cycles.py --only-shortest --print-labels results/whole-opensim.dot
python3 dot_find_cycles.py --only-shortest results/opensim-common.dot
```
# References

- [Cmake GraphViz](https://www.systutorials.com/visualizing-cmake-project-dependencies-with-graphviz/)
- [Original Transative Reduction Script](https://blog.jasonantman.com/2012/03/python-script-to-find-dependency-cycles-in-graphviz-dot-files/) - dot_find_cycles.py
- [Color strongly connected components GraphViz script](https://forum.graphviz.org/t/coloring-nodes-in-the-same-strongly-connected-components/2481)
- [scc.g script original](https://graphviz-interest.research.att.narkive.com/iZOwXdv0/postprocess-dot-file-to-highlight-cycles)
- [Original dependency-graph repo](https://github.com/pvigier/dependency-graph)

# dependency-graph

A python script to show the "include" dependency of C++ classes.

It is useful to check the presence of circular dependencies.

## Installation

The script depends on [Graphviz](https://www.graphviz.org/) to draw the graph. 

On Ubuntu, you can install the dependencies with these two commands:

```
sudo apt install graphviz
pip3 install -r requirements.txt
```

## Manual

```
usage: dependency_graph.py [-h] [-f {bmp,gif,jpg,png,pdf,svg}] [-v] [-c]
                           folder output

positional arguments:
  folder                Path to the folder to scan
  output                Path of the output file without the extension

optional arguments:
  -h, --help            show this help message and exit
  -f {bmp,gif,jpg,png,pdf,svg}, --format {bmp,gif,jpg,png,pdf,svg}
                        Format of the output
  -v, --view            View the graph
  -c, --cluster         Create a cluster for each subfolder
```

## Examples

Example of a graph produced by the script:

![Example 1](https://github.com/pvigier/dependency-graph/raw/master/examples/example1.png)

Graph produced for the same project with clusters (`-c`):

![Example 2](https://github.com/pvigier/dependency-graph/raw/master/examples/example2.png)
