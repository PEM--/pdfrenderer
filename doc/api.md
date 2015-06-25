

<!-- Start PdfRenderer.coffee -->

# PdfRenderer: A custom PDF renderer.

This class inherits from PDFDocument, the main class provided by PDFKit.
Therefore, it exposes all of its methods and enhances them for easing
the transition from HTML to PDF.

## PdfRenderer(options)

C-tor: Create a PDF document instance.

### Params:

* **Object** *options* As used by PDFKit.

## addAsset(url)

Download assets reactively putting them in an `Iron.WaitList`
(see iron:router and eventedmind.com for futher details).
All assets are stored in a dictionary ensuring retrieval based on
the provided URL.

### Params:

* **String** *url* URL of the downloaded assets.

## addScreenshot(unique, tpl, el, styles, width)

Create a screenshot from an element within a template.

### Params:

* **String** *unique* Unique name used in the `img` method.
* **Object** *tpl* Blaze template.
* **String** *el* CSS selector of the element within the template.
* **Object** *styles* A dictionary of styles to inline in the SVG                          if the content is SVG based. It takes the form
                         of a CSS selector and a table of property to
                         inline.
* **Number** *width* Width's of the image, null for the viewport's                          width.

## ready()

Reactive ready state on the Iron.WaitList of assets.

### Return:

* **Boolean** true if all assets are downloaded, false otherwise.

## h1(text)

Insert a title.

### Params:

* **String** *text* Text of the title.

### Return:

* **Object** this.

## h2(text)

Insert a sub-title.

### Params:

* **String** *text* Text of the title.

### Return:

* **Object** this.

## h3(text)

Insert a sub-sub-title.

### Params:

* **String** *text* Text of the title.

### Return:

* **Object** this.

## p(text)

Insert a paragraph.

### Params:

* **String** *text* Text of the paragraph.

### Return:

* **Object** this.

## br(nb)

Insert one or many blank lines.

### Params:

* **Number** *nb* Number of line breaks. 1 as a default.

### Return:

* **Object** this.

## hr()

Insert a line.

### Return:

* **Object** this.

## line()

Draw a simple horizontal line with no vertical margin.

### Return:

* **Object** this.

## fullPageWidth()

Get the current full page's width minus its margins.

### Return:

* **Number** The full page's width.

## img(url, pos, options)

Insert an image already downloaded using the `addAsset` method.

### Params:

* **String** *url* URL of the image.
* **String** *pos* Position of the image:                          * `INLINE`: Directly within the text (default).
                         * `FULL`: Full width of the page.
                         * `RIGHT`: Right aligned to text (need width).
                         * `RATIO`: A ratio of the full page's width.
* **Object** *options* Options as provided by `image` method of PDFKit                          or for `RATIO`, a percentage of the full page.

### Return:

* **Object** this.

## table(theadLabel, labels, rows)

Draw a simple formatted table that takes the full page's width.

### Params:

* **String** *theadLabel* Name of the table.
* **Array** *labels* Array of String for each table's header.
* **Array** *rows* 2d Array of values (String or Number).

### Return:

* **Object** this.

## packRatioImgs(imgs)

Pack images ratio on a single row.

### Params:

* **Array** *imgs* An array of `img` in `RATIO` mode.

### Return:

* **Object** this.

## schema(Schema, keyFilter, data)

Insert elements from a SimpleSchema if their content
 is marked as `pdf: true`.

### Params:

* **Object** *Schema* A SimpleSchema.
* **String** *keyFilter* A key in the SimpleSchema, an empty String                            for no filter.
* **Object** *data* Data fetched from Mongo.

### Return:

* **Object** this.

## formatter(innerData)

Formats value depending on their types.

### Params:

* **Boolean|Number|String|Date** *innerData* Data to format.

### Return:

* **String** Formatted data, null if no match.

## finish(filename, callback)

End document and open a new window containing the PDF.

### Params:

* **String** *filename* Filename for the generated PDF. Note that                           the filename is [slugified](https://github.\
                          com/epeli/underscore.string#\
                          slugifystring--string) for better OS
                          compatibility.
* **Function** *callback* Callback executed after the PDF processing.

<!-- End PdfRenderer.coffee -->

