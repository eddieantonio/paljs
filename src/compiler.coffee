# This is the main entry point for the Pal compiler

PalCompiler = (input, options={}) ->
  PalCompiler.parse(input)

PalCompiler.parse = (input) ->
  try
    PalParser.parse input, 'program'
  catch e
    { error: e }

# Installs as a global in a browser or sets this as the main export in Node.
install = (obj, name) ->
  switch
    when module?.exports?
      module.exports = obj
    when window?
      window[name] = obj

# Install to whateve environment this.
install PalCompiler, 'PalCompiler'
