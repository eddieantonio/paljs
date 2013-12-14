# Loading additional config based on Thomas Boyt's work:
# http://www.thomasboyt.com/2013/09/01/maintainable-grunt.html

# Extends an object with all of the keys of the given object.
extendOneLevel = (original, nextObject) ->
  for name, category of nextObject
    if original[name]?
      # The category exists in the object. Merge it in.
      for subname, config of category
        original[name][subname] = config
    else
      # The category does not exist. Just copy it over.
      original[name] = category

# Original here:
# https://gist.github.com/thomasboyt/6406507#file-load_config-js
# Modifications to extend the on into one huge config object.
loadConfig = (originalConfig={}, path=__dirname) ->
  glob = require 'glob'

  glob.sync('*', { cwd: path }).forEach (option) ->
    # Get rid of the extension.
    module = option.replace /\.(js|coffee)$/, ''
    extendOneLevel originalConfig, require("#{path}/#{module}")

  originalConfig

module.exports = loadConfig
