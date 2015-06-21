# A client side PDF Renderer
Enhance client side PDFKit:
- Adds HTML primitives like h1, h2, h3, p, img, br, hr.
- Can take a SimpleSchema, parse it and render it.
- Support for internationalization.
- Can render external image or images within CollectionFS.
- Support regular SVG as well as D3 SVG.
- Can add screenshot of a rendered Blaze's template.

## Installation
```bash
meteor add pierreeric:pdfrenderer
```

## Example usage
Here is the generated PDF from this sample app: [sample](doc/file-mathilde-charpentier-pdf).

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

Customers = new Mongo.Collection 'customers'
Customers.attachSchema CustomerSchema

if Meteor.isServer
  if Customers.find().count() is 0
    Customers.insert
      name: 'Mathilde Charpentier'
      address:
        street: '227 rue, Camille de Richelieu'
        city: 'Strasbourg'
  Meteor.publish 'customers', -> Customers.find()

if Meteor.isClient
  Template.svgTest.onCreated ->
    sub = @subscribe 'customers'
    @autorun =>
      if sub.ready()
        @customer = Customers.findOne()
  Template.svgTest.helpers
    customer: -> Template.instance().customer
  Template.svgTest.events
    'click button': (e, t) ->
      # Create the initial PDF document
      pdf = new PdfRenderer size: 'a4'
      # Load all required assets
      pdf.addAsset "/cfs/files/images/#{t.customer.images}" if t.customer.images
      # Use reactivity for loading assets if any
      t.autorun ->
        if pdf.ready()
          # Customer image if exists
          if t.customer.images?
            pdf.img "/cfs/files/images/#{t.customer.images}", 'RIGHT',
              width: 100
          # Customer's name
          pdf.h1 t.customer.name
          # Address of customer
          pdf.h2 TAPi18n.__ 'address'
          pdf.schema CustomerSchema, 'address', t.customer
          # End the PDF document, display it and enable back the PDF button
          pdf.finish "file-#{t.customer.name}.pdf", ->
            console.log 'PDF finished'
```

## API
[API](doc/api.md)

## Links
* [PDFKit](http://pdfkit.org/)
* [SimpleSchema](https://github.com/aldeed/meteor-simple-schema)
* [tap-i18n](https://github.com/TAPevents/tap-i18n)
* [RxBufferDownload](https://github.com/PEM--/rxbufferdownload)
* [html2canvas](http://html2canvas.hertzen.com/)
* [FileSaver.js](https://github.com/eligrey/FileSaver.js/)

## FAQ
### Contributions
Contributions are very welcomed. Feel free to PR for enhancing this package.

### i18n minimum file
Your i18n file must at least contain the following for using SimpleSchema:
```json
{
  "colon": ": "
}
```

### Testing
A test application is provided in the `app` folder.

### Enhancing documentation
API's documentation uses [DocBlockr](https://atom.io/packages/docblockr) syntax.
Generates the API's documentation using [markdox](https://github.com/cbou/markdox).

```bash
markdox PdfRenderer.coffee -o doc/api.md
```
