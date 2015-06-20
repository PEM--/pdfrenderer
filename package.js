Package.describe({
  name: 'pierreeric:pdfrenderer',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'A client side PDF renderer',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/PEM--/pdfrenderer.git',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
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
    'aldeed:simple-schema@1.3.3'
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
