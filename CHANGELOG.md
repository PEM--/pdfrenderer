# 0.1.0 - Meteor 1.2.1
* Package bumped

# 0.0.10 - Ellipsis, Static formatting, New data types (null, NaN, undefined)
* Add ellipsis and text truncation to fixed width text (table, essentially).
* Add a small margin before h2 and h3.
* Add a small margin after table.
* Handle data types for null, NaN and undefined as empty strings.

# 0.0.8 - 0.0.9 - Sub-SimpleSchema and Array of sub-SimpleSchema
* Set all fields of unitary and Array of sub-SimpleSchema in a formatter.

# 0.0.7 - Force TAPi18n, Boolean, Date, Array, table
* Always use TAPi18n on displayed value.
* HTML's table equivalent.
* New SimpleSchema types:
  * Boolean: Print a Yes/No message.
  * Date: Print a formatted date.
  * Array: Print a formatted table.

# 0.0.6 - Root of a SimpleSchema & recursion on Object
* When no filter provided, the renderer parse the complete SimpleSchema.
* The renderer recurses on Object.

# 0.0.5 - Auto-adjust height on image packing
* Take the maximum height of provided images when using `packRatioImgs`.
* Better MIME type management.

# 0.0.4 - Options for image placement
* `FULL`: Full width of the page.
* `RATIO`: A ratio of the full page's width.
* Pack multiple `RATIO` images on a single row.

# 0.0.3 - Screenshots & SVG
* Insert part of the template as image in the PDF.
* Insert SVG from the template as image in the PDF.
* Better file saving via [FileSaver.js](https://github.com/eligrey/FileSaver.js/).

# 0.0.2 - New primitives & Filename support
* Use [FileSaver](https://github.com/eligrey/FileSaver.js) for a better filename handling.
* PDF named are slugified for a better OS compatibility.
* New primitives: h3.

# 0.0.1 - Initial package
* PDF rendering for SimpleSchema, img, h1, h2, p, br, hr.
