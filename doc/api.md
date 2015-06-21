

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

## img(url, pos, options)

Insert an image already downloaded using the `addAsset` method.

### Params:

* **String** *url* URL of the image.
* **String** *pos* Position of the image: 
                         * `INLINE`: Directly within the text.
                         * `RIGHT`: Right aligned to text (need width).
* **Object** *options* Options as provided by `image` method of PDFKit.

### Return:

* **Object** this.

## schema(Schema, keyFilter, data)

Insert elements from a SimpleSchema if their content
 is marked as `pdf: true`.

### Params:

* **Object** *Schema* A SimpleSchema.
* **String** *keyFilter* A key in the SimpleSchema.
* **Object** *data* Data fetched from Mongo.

### Return:

* **Object** this.

## finish(filename, callback)

End document and open a new window containing the PDF.

### Params:

* **String** *filename* Filename for the generated PDF. Note that                           the filename is [slugified](https://github.\
                          com/epeli/underscore.string#\
                          slugifystring--string) for better OS
                          compatibility.
* **Function** *callback* Callback executed after the PDF processing.

<!-- End PdfRenderer.coffee -->

