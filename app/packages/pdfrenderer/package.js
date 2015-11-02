Package.describe({
  name: 'pierreeric:pdfrenderer',
  version: '0.1.0',
  summary: 'A client side PDF renderer',
  git: 'https://github.com/PEM--/pdfrenderer.git',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2.1');
  // Required packages
  api.use([
    // Package from MDG
    'coffeescript',
    'check',
    'underscore',
    // Community packages
    'momentjs:moment@2.10.6',
    'mquandalle:bower@1.5.2_1',
    'iron:controller@1.0.12',
    'aldeed:simple-schema@1.3.3',
    'underscorestring:underscore.string@3.2.2',
    'pierreeric:rxbufferdownload@0.1.0',
    'pierreeric:rxscreenshot@0.1.0'
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
