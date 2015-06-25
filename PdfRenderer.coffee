###*
 * # PdfRenderer: A custom PDF renderer.
 *
 * This class inherits from PDFDocument, the main class provided by PDFKit.
 * Therefore, it exposes all of its methods and enhances them for easing
 * the transition from HTML to PDF.
###
@PdfRenderer = {}
Meteor.startup ->
  class window.PdfRenderer extends PDFDocument
    ###*
     * C-tor: Create a PDF document instance.
     * @param  {Object} options As used by PDFKit.
    ###
    constructor: (options) ->
      # Create the initial PDF document
      super options
      @stream = @pipe blobStream()
      @waitList = new Iron.WaitList
      @assets = {}
    ###*
     * Download assets reactively putting them in an `Iron.WaitList`
     * (see iron:router and eventedmind.com for futher details).
     * All assets are stored in a dictionary ensuring retrieval based on
     * the provided URL.
     * @param {String} url URL of the downloaded assets.
    ###
    addAsset: (url) ->
      rxAsset = new RxBufferDownload url
      @waitList.wait -> rxAsset.get()
      @assets[url] = rxAsset
    ###*
     * Create a screenshot from an element within a template.
     * @param {String} unique Unique name used in the `img` method.
     * @param  {Object}  tpl Blaze template.
     * @param  {String}  el  CSS selector of the element within the template.
     * @param  {Object}  styles A dictionary of styles to inline in the SVG
     *                          if the content is SVG based. It takes the form
     *                          of a CSS selector and a table of property to
     *                          inline.
     * @param  {Number}  width  Width's of the image, null for the viewport's
     *                          width.
    ###
    addScreenshot: (unique, tpl, el, styles = null, width = null) ->
      rxAsset = new RxScreenshot tpl, el, styles, width
      @waitList.wait -> rxAsset.get()
      @assets[unique] = rxAsset
    ###*
     * Reactive ready state on the Iron.WaitList of assets.
     * @return {Boolean} true if all assets are downloaded, false otherwise.
    ###
    ready: -> @waitList.ready()
    ###*
     * Insert a title.
     * @param  {String} text Text of the title.
     * @return {Object} this.
    ###
    h1: (text) -> @fontSize(24).text text
    ###*
     * Insert a sub-title.
     * @param  {String} text Text of the title.
     * @return {Object} this.
    ###
    h2: (text) -> @fontSize(18).text text
    ###*
     * Insert a sub-sub-title.
     * @param  {String} text Text of the title.
     * @return {Object} this.
    ###
    h3: (text) -> @fontSize(14).text text
    ###*
     * Insert a paragraph.
     * @param  {String} text Text of the paragraph.
     * @return {Object} this.
    ###
    p: (text) -> @fontSize(12).text text, align: 'justify'
    ###*
     * Insert one or many blank lines.
     * @param  {Number} nb Number of line breaks. 1 as a default.
     * @return {Object} this.
    ###
    br: (nb = 1) -> @moveDown nb
    ###*
     * Insert a line.
     * @return {Object} this.
    ###
    hr: ->
      @moveDown .5
      x = @page.margins.left
      y = @y
      width = @page.width - @page.margins.left - @page.margins.right
      @moveTo x, y
      @lineTo width + x, y
      @stroke()
      @moveDown .5
    ###*
     * Insert an image already downloaded using the `addAsset` method.
     * @param  {String} url     URL of the image.
     * @param  {String} pos     Position of the image:
     *                          * `INLINE`: Directly within the text (default).
     *                          * `FULL`: Full width of the page.
     *                          * `RIGHT`: Right aligned to text (need width).
     *                          * `RATIO`: A ratio of the full page's width.
     * @param  {Object} options Options as provided by `image` method of PDFKit
     *                          or for `RATIO`, a percentage of the full page.
     * @return {Object}         this.
    ###
    img: (url, pos = 'INLINE', options) ->
      imgArrayBuffer = @assets[url].getBuffer()
      switch pos
        when 'INLINE' then @image imgArrayBuffer, options
        when 'FULL'
          @image imgArrayBuffer,
            width: @page.width - @page.margins.right - @page.margins.left
        when 'RATIO'
          fullPageWidth = @page.width - @page.margins.right - @page.margins.left
          @image imgArrayBuffer, width: fullPageWidth * options
        when 'RIGHT'
          [oldX, oldY] = [@x, @y]
          x = @page.width - options.width - @page.margins.right
          y = @y
          @image imgArrayBuffer, x, y, options
          [@x, @y] = [oldX, oldY]
      @
    ###*
     * Pack images ratio on a single row.
     * @param  {Array} imgs An array of `img` in `RATIO` mode.
     * @return {Object} this.
    ###
    packRatioImgs: (imgs) ->
      x = futureX = @page.margins.left
      y = futureY = @y
      fullPageWidth = @page.width - @page.margins.right - @page.margins.left
      for img, idx in imgs
        imgArrayBuffer = @assets[img.url].getBuffer()
        width = fullPageWidth * img.options
        if idx is 0
          res = @image imgArrayBuffer, width: width
          futureY = @y
        else
          res = @image imgArrayBuffer, x, y, width: width
          # Height of a PNG is at offset 20, stored on 4 bytes, in Big endian
          height = imgArrayBuffer.readUInt32BE 20
          futureY = Math.max futureY, (y + height)
        x += width
      [@x, @y] = [futureX, futureY]
      @
    ###*
     * Insert elements from a SimpleSchema if their content
     *  is marked as `pdf: true`.
     * @param  {Object} Schema    A SimpleSchema.
     * @param  {String} keyFilter A key in the SimpleSchema, an empty String
     *                            for no filter.
     * @param  {Object} data      Data fetched from Mongo.
     * @return {Object}           this.
    ###
    schema: (Schema, keyFilter, data) ->
      for label in Schema.objectKeys keyFilter
        # Check if property needs to be printed
        defName = if keyFilter is '' then label else "#{keyFilter}.#{label}"
        def = Schema.getDefinition defName
        # Check if value is printable
        if def.pdf
          # Extract content
          innerData = if keyFilter is '' then data[label] \
            else data[keyFilter][label]
          # Omit optional field with empty value
          unless innerData is undefined
            # Format value depending on data type
            switch
              # Set value for Object (unnamed sub-Schema)
              when (_.isObject innerData) and not (_.isArray innerData)
                # Recurse on Object (sub-SimpleSchema)
                @h3 TAPi18n.__ label
                @schema Schema, label, data
              # Set value for select/option kind of values
              when def.autoform?.afFieldInput?.type is 'select'
                value = TAPi18n.__ innerData
              # Set value for type Number
              when _.isNumber innerData
                value = String innerData
                # Add units if available in the schema
                if def.autoform?.afFieldInput?.unit?
                  value += ' ' + TAPi18n.__ def.autoform.afFieldInput.unit()
              # Set value for type String (adds i18n support)
              when _.isString innerData then value = TAPi18n.__ innerData
              else
                console.warn 'Unmanaged data type', keyFilter, innerData
            # Print the value in the PDF
            @p TAPi18n.__(label) + TAPi18n.__('colon') + value
      @
    ###*
     * End document and open a new window containing the PDF.
     * @param  {String} filename Filename for the generated PDF. Note that
     *                           the filename is [slugified](https://github.\
     *                           com/epeli/underscore.string#\
     *                           slugifystring--string) for better OS
     *                           compatibility.
     * @param  {Function} callback Callback executed after the PDF processing.
    ###
    finish: (filename, callback) ->
      @end()
      @stream.on 'finish', =>
        content = @stream.toBlob()
        saveAs @stream.toBlob('application/pdf'), s.slugify filename
        # Call provided callback
        callback()
