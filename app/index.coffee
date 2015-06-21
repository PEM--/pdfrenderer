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
      console.log 'template', t
      # Create the initial PDF document
      pdf = new PdfRenderer size: 'a4'
      # Load all required assets
      #pdf.addAsset "/cfs/files/images/#{t.data.images?}" if t.data.images?
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
          console.log 'Customer', t.customer
          pdf.schema CustomerSchema, 'address', t.customer
          # End the PDF document, display it and enable back the PDF button
          pdf.finish -> console.log 'PDF finished'
