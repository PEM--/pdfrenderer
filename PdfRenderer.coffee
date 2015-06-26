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
    FONT_SIZE = 10
    H1_SIZE = FONT_SIZE*2
    H2_SIZE = Math.floor FONT_SIZE*1.5
    H3_SIZE = Math.floor FONT_SIZE*1.2
    BOLD_SIZE = Math.floor FONT_SIZE*1.1
    SMALL_MARGIN = .3
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
    h1: (text) -> @fontSize(H1_SIZE).text text
    ###*
     * Insert a sub-title.
     * @param  {String} text Text of the title.
     * @return {Object} this.
    ###
    h2: (text) -> @fontSize(H2_SIZE).moveDown(SMALL_MARGIN).text text
    ###*
     * Insert a sub-sub-title.
     * @param  {String} text Text of the title.
     * @return {Object} this.
    ###
    h3: (text) -> @fontSize(H3_SIZE).moveDown(SMALL_MARGIN).text text
    ###*
     * Insert a paragraph.
     * @param  {String} text Text of the paragraph.
     * @return {Object} this.
    ###
    p: (text) -> @fontSize(FONT_SIZE).text text, align: 'justify'
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
    hr: -> @moveDown(.5).line().moveDown .5
    ###*
     * Draw a simple horizontal line with no vertical margin.
     * @return {Object} this.
    ###
    line: ->
      [x, y] = [@page.margins.left, @y]
      @moveTo(x, y).lineTo(@fullPageWidth() + x, y).stroke()
    ###*
     * Get the current full page's width minus its margins.
     * @return {Number} The full page's width.
    ###
    fullPageWidth: -> @page.width - @page.margins.left - @page.margins.right
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
          @image imgArrayBuffer, width: @fullPageWidth()
        when 'RATIO'
          @image imgArrayBuffer, width: @fullPageWidth() * options
        when 'RIGHT'
          [oldX, oldY] = [@x, @y]
          x = @page.width - options.width - @page.margins.right
          y = @y
          @image imgArrayBuffer, x, y, options
          [@x, @y] = [oldX, oldY]
      @
    ###*
     * Draw a simple formatted table that takes the full page's width.
     * Note that the caller must pass formatted and internationalized Strings.
     * @param  {String} theadLabel  Name of the table.
     * @param  {Array} labels       Array of String for each table's header.
     * @param  {Array} rows         2d Array of values (String or Number).
     * @return {Object}             this.
    ###
    table: (theadLabel, labels, rows) ->
      colWidth = @fullPageWidth() / (labels.length + 1)
      @y += FONT_SIZE / 2
      [x, y] = [@page.margins.left, @y]
      # Options used for text truncation and ellipsis
      truncOptions =
        width: colWidth
        lineBreak: false
        ellipsis: true
        height: BOLD_SIZE
      # Create table's header
      @line()
      y = (@y += FONT_SIZE / 2)
      @font 'Helvetica', 'Helvetica-Bold', BOLD_SIZE
        .text theadLabel, x, y, truncOptions
      @text label, (x += colWidth), y, truncOptions for label in labels
      # Register y position as printed text may be empty (when row content
      #  has empty value for instance).
      futureY = @y
      # Create tables's body
      [x, y] = [@page.margins.left, @y]
      @line()
      for row in rows
        y = (@y += FONT_SIZE / 2)
        for value, idx in row
          # Check if text is a row label (the first column).
          if idx is 0
            @font 'Helvetica', 'Helvetica-Bold', BOLD_SIZE
          else
            @font 'Helvetica', 'Helvetica', FONT_SIZE
          @text value, x, y, truncOptions
          x += colWidth
          futureY = Math.max futureY, @y
        # Set x position to the beginning of the page.
        x = @page.margins.left
        # Adjust y position so that even after empty cells in the table
        #  the proper row height is taken into account.
        @y = futureY
        # Draw a closing line for the table.
        @line()
      [@x, @y] = [@page.margins.left, futureY + FONT_SIZE / 2]
      @moveDown SMALL_MARGIN
    ###*
     * Pack images ratio on a single row.
     * @param  {Array} imgs An array of `img` in `RATIO` mode.
     * @return {Object} this.
    ###
    packRatioImgs: (imgs) ->
      x = futureX = @page.margins.left
      y = futureY = @y
      for img, idx in imgs
        imgArrayBuffer = @assets[img.url].getBuffer()
        width = @fullPageWidth() * img.options
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
            # @NOTE Array and Object have the same prototype.
            if _.isObject innerData
              # The data type is an Array
              if _.isArray innerData
                keys = Schema.objectKeys "#{label}.$"
                theadLabel = _.first keys
                @table Schema.getDefinition(label).label,
                  # Format each table header
                  (_.map (_.pluck innerData, theadLabel), (tlabel) =>
                    @formatter tlabel),
                  # Iterate over each rows
                  _.map (_.rest keys), (rowName) =>
                    _.flatten [
                      (@formatter rowName)
                      _.map (_.pluck innerData, rowName), (innerLabel) =>
                        @formatter innerLabel
                    ]
                # Nullify value: printing is already ensured in the loops.
                value = null
              # The data type is an unnamed sub-Schema
              else
                # Recurse on Object (sub-SimpleSchema)
                @h3 TAPi18n.__ label
                @schema Schema, label, data
                # Nullify value: printing is already ensured in the recursion.
                value = null
            else
              value = @formatter innerData
              # Add units if available in the schema
              if value isnt null and def.autoform?.afFieldInput?.unit?
                value += ' ' + TAPi18n.__ def.autoform.afFieldInput.unit()
            # Print the value in the PDF
            unless value is null
              @p TAPi18n.__(label) + TAPi18n.__('colon') + value
      @
    ###*
     * Formats value depending on their types.
     * @param  {BaseType} innerData   Data to format.
     * @return {String|null} Formatted data, null if no match.
    ###
    formatter: (innerData) ->
      switch
        # Set value for type Boolean
        when _.isBoolean innerData
          return TAPi18n.__ if innerData then  'yes' else 'no'
        # Set value for type Number
        when _.isNumber innerData then return String innerData
        # Set value for type String (adds i18n support)
        when _.isString innerData then return TAPi18n.__ innerData
        # Set value for type Date
        when _.isDate innerData then return moment(innerData).format 'L'
        # Set value for null, NaN and undefined
        when (_.isNaN innerData) or (_.isNull innerData) or \
            (_.isUndefined innerData) then return ''
      console.warn 'Unmanaged data type', innerData, typeof innerData
      return null
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
