# A client side PDF Renderer
Enhance client side PDFKit.

## Installation
```bash
meteor add pierreeric:pdfrenderer
```

## Example usage
```coffee
CustomerSchema = new SimpleSchema
  name:
    type: String
    label: TAPi18n.__ 'name'
  images:
    type: String
    label: TAPi18n.__ 'images'
    optional: true
    autoform: afFieldInput:
      type: 'fileUpload'
      collection: 'Images'
  address:
    type: Object
    label: TAPi18n.__ 'address'
  'address.street':
    type: String
    label: TAPi18n.__ 'street'
    pdf: true
  'address.city':
    type: String
    label: TAPi18n.__ 'city'
    pdf: true

if Meteor.isClient
  # Create the initial PDF document
  pdf = new PdfRenderer size: 'a4'
  # Load all required assets
  pdf.addAsset "/cfs/files/images/#{@data.images}" if t.data.images
  # Use reactivity for loading assets if any
  @autorun ->
    if pdf.ready()
      # Customer image if exists
      if @data.images
        pdf.img "/cfs/files/images/#{@data.images}", 'RIGHT', width: 100
      # Customer's name
      pdf.h1 @data.name
      # Address of customer
      pdf.h2 TAPi18n.__ 'address'
      pdf.schema CustomerSchema, 'address', @data
      # End the PDF document, display it and enable back the PDF button
      pdf.finish -> console.log 'PDF finished'  
```

## API
[API](doc/api.md)

## Links
* [PDFKit](http://pdfkit.org/)
* [SimpleSchema](https://github.com/aldeed/meteor-simple-schema)
* [tap-i18n](https://github.com/TAPevents/tap-i18n)
* [RxBufferDownload](https://github.com/PEM--/rxbufferdownload)
