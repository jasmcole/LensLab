# LensLab
Small GUI for designing simple lens arrangements. Download all files into a folder and run by typing `LensLab;`

The file structure is simple, if in need of substantial refactoring:
- `LensLab.m` - This is a class inherited from `handle` which defines the app layout and user interaction. As the app is primarily driven by clicking-and-dragging, most of the code here involves altering the `WindowButtonMotionFcn` of the figure, and reacting to calls to it.
- `DrawRays.m` - This file is a bit of a mess, and handles the calculation of ray paths as well as drawing the rays and lenses in the figure axes. The first half parses the positions of the lenses stored as a property of the parent app (`app.xpos` and `app.flength`) and creates a cell array `types` and array `params`. Elements of `types` are either `l` or `d` indicating a lens or a section of free-space propagation. Elements of `params` are `double`s defining either a focal length or a distance. The second half of `DrawRays.m` then uses these arrays to calculate image properties and ray locations.
- `FormatPlot` - This simply makes the plot look nicer than the Matlab default. It takes a variable number of inputs in name-value pairs - see the file for more information.

![Screenshot](/Screen Shot 2016-10-19 at 17.48.54.png)
