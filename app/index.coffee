# In this SimpleSchema, some content are set as 'pdf: true'
# for automatic rendering.
@CustomerSchema = new SimpleSchema
  name:
    type: String
    label: TAPi18n.__ 'name'
    pdf: true
  images:
    type: String
    label: TAPi18n.__ 'images'
    optional: true
    pdf: true
    autoform: afFieldInput:
      type: 'fileUpload'
      collection: 'Images'
  subscription:
    type: Date
    label: TAPi18n.__ 'verified'
    pdf: true
  verified:
    type: Boolean
    label: TAPi18n.__ 'verified'
    pdf: true
  address:
    type: Object
    label: TAPi18n.__ 'address'
    pdf: true
  'address.street':
    type: String
    label: TAPi18n.__ 'street'
    pdf: true
  'address.city':
    type: String
    label: TAPi18n.__ 'city'
    pdf: true
  purchases:
    type: [Object]
    label: TAPi18n.__ 'purchases'
    pdf: true
  'purchases.$.label':
    type: String
    label: TAPi18n.__ 'label'
    pdf: true
  'purchases.$.number':
    type: Number
    label: TAPi18n.__ 'number'
    pdf: true
@Customers = new Mongo.Collection 'customers'
Customers.attachSchema CustomerSchema

# On the server, we create a single customer and publish it.
if Meteor.isServer
  if Customers.find().count() is 0
    Customers.insert
      name: 'Mathilde Charpentier'
      subscription: new Date
      verified: true
      address:
        street: '227 rue, Camille de Richelieu'
        city: 'Strasbourg'
      purchases: [
        {label: 'Bike', number: 10}
        {label: 'Helmet', number: 8}
        {label: 'Tire', number: 3}
        {label: 'Chain', number: 6}
        {label: 'Brake', number: 24}
      ]
  Meteor.publish 'customers', -> Customers.find()

# Client side specific
if Meteor.isClient
  # Here we use the template level subscription, some adaptation are required
  #  when using iron:router (use the data context).
  Template.svgTest.onCreated ->
    @sub = @subscribe 'customers'
    @autorun =>
      @customer = Customers.findOne() if @sub.ready()
      window.customer = @customer
  # Here, we create a simple bar chart
  Template.svgTest.onRendered ->
    @autorun =>
      if @sub.ready()
        width = 400
        height = 200
        y = d3.scale.linear().range [height, 0]
        chart = d3.select('.chart').attr('width', width).attr 'height', height
        data = @customer.purchases
        y.domain [0, d3.max data, (d) -> d.number]
        barWidth = width / data.length
        bar = chart
          .selectAll 'g'
          .data data
          .enter()
          .append 'g'
          .attr 'transform', (d, i) -> 'translate(' + i * barWidth + ',0)'
        bar
          .append 'rect'
          .attr 'y', (d) -> y d.number
          .attr 'height', (d) -> height - y d.number
          .attr 'width', barWidth - 1
        bar
          .append 'text'
          .attr 'x', barWidth / 2
          .attr 'y', (d) -> 3 + y d.number
          .attr 'dy', '.75em'
          .text (d) -> d.number
  Template.svgTest.helpers
    customer: -> Template.instance().customer
    table: ->
      keys = CustomerSchema.objectKeys 'purchases.$'
      theadLabel = _.first keys
      purchases = Template.instance().customer.purchases
      # Exposed results for the helper
      res =
        tableName: CustomerSchema.getDefinition('purchases').label
        labels: _.pluck purchases, theadLabel
        lines: _.map (_.rest keys), (label) ->
          _.flatten [(TAPi18n.__ label), (_.pluck purchases, label)]
      res
  # Handle events for the PDF button
  Template.svgTest.events
    'click button': (e, t) ->
      # Create the initial PDF document
      pdf = new PdfRenderer size: 'a4'
      # Load all required assets
      pdf.addAsset "/cfs/files/images/#{t.customer.images}" if t.customer.images
      # Load all SVG
      pdf.addScreenshot 'svg-chart', t, 'svg.chart'
      ,
        rect: fill: 'steelblue'
        text:
          fill: 'white'
          font: '10px sans-serif'
          'text-anchor': 'middle'
      , 400
      # Use reactivity for loading assets if any
      t.autorun ->
        if pdf.ready()
          # Customer image if exists
          if t.customer.images?
            pdf.img "/cfs/files/images/#{t.customer.images}",'RIGHT',width:100
          # Customer's name
          pdf.h1 t.customer.name
          # Address of customer
          pdf.h2 TAPi18n.__ 'address'
            .schema CustomerSchema, 'address', t.customer
          # Graph of the purchase figure
          pdf.img 'svg-chart'
          # Create a simple table
          keys = CustomerSchema.objectKeys 'purchases.$'
          theadLabel = _.first keys
          purchases = t.customer.purchases
          pdf.table CustomerSchema.getDefinition('purchases').label,
            (_.pluck purchases, theadLabel),
            (_.map (_.rest keys), (label) ->
              _.flatten [(TAPi18n.__ label), (_.pluck purchases, label)])
          # Same print out as before but without filtering (less flexible
          # in terms of layout but cover more automatic cases).
          pdf.hr()
            .schema CustomerSchema, '', t.customer
          # End the PDF document and display it
          pdf.finish "file-#{t.customer.name}.pdf", -> console.log 'PDF done'
