Package.describe({
  name: 'pierreeric:pdfrenderer',
  version: '0.0.4',
  summary: 'A client side PDF renderer',
  git: 'https://github.com/PEM--/pdfrenderer.git',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  // Required packages
  api.use([
    // Package from MDG
    'coffeescript',
    'check',
    // Community packages
    'mquandalle:bower@1.4.1',
    'iron:controller@1.0.8',
    'aldeed:simple-schema@1.3.3',
    'underscorestring:underscore.string@3.1.1',
    'pierreeric:rxbufferdownload@0.0.1',
    'pierreeric:rxscreenshot@0.0.1'
  ]);
  api.imply('aldeed:simple-schema');
  // Imported files for client
  api.addFiles([
    'PdfRenderer.coffee',
    'bower.json'
  ], 'client');
  // Imported files for client and server
  api.addFiles([
    'SimpleSchemaExtensions.coffee'
  ]);
});
