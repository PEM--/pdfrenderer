# Extend SimpleSchema for allowing automatic PDF rendering
# See: https://github.com/aldeed/meteor-simple-schema#extending-the-schema-options
SimpleSchema.extendOptions
  pdf: Match.Optional Boolean
