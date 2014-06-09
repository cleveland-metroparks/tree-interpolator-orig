tree-interpolator-orig
======================

A PovRay-powered tree interpolator for creating forest digital surface models from LiDAR point clouds.

This is a project which puts verisimilitude at or above the level of veracity, i. e. it will create a surface model of a forest canopy down to the last little leaf, in the absence of that level of detail in the LiDAR dataset itself.

![detailed](https://raw.github.com/smathermather/tree-interpolator/master/Licking_zoom.png)

That said, the output data do (also) have a high level of veracity.

This output is accomplished by using (effectively) a 3D tree "stamp" which is placed at each and every LiDAR point, and scaled to the height above groun of that point.  See https://smathermather.wordpress.com/tag/lidar/ for more info.

**Requirements:**

* Ubuntu
* PovRay 3.6 or later: http://povray.org/
* Bourne Again Shell (BASH)

**Functionality**

tree.inc is a triangular mesh of a tree generated using Pov-Tree, now defunct but available at the illustrious Internet Archive: http://web.archive.org/web/*/http://propro.ru/go/Wshop/povtree/povtree.html (in case you want a different tree shape).
treepov.inc is the additional code needed create the renderable povray document

**Usage**
```SHELL
tree-interpolator.sh input.las output-name width-height pixel-size
```
e.g.
```SHELL
./tree-interpolator.sh input.las Licking 5000 10 
```

**Outputs**

The primary outputs from this script are, as mentioned in functionality, are a PNG and a world file that georeferences that PNG.  The data are scaled between 0 and 63575, and the code assumes the tallest trees are 175 feet tall.  While this is a reasonable assumption for Ohio, it may not be reasonable for e.g. California.

![example](https://raw.github.com/smathermather/tree-interpolator/master/Licking_stretched.png)
