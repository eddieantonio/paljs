PalCompiler = require './compiler'

# Installs as a global in a browser
install = (obj, name) ->
  switch
    when window?
      window[name] = obj
    when module?.exports?
      module.exports = obj

# Install to whateve environment this.
install PalCompiler, 'PalCompiler'
