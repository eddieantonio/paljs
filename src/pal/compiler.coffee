# This is the main entry point for the Pal compiler

PalCompiler = (input, options={}) ->
  PalCompiler.parse(input)

PalCompiler.parse = (input) ->
  result =
    output: null
    error: null
  try
    ast = PalParser.parse input, 'program'
  catch err
    result.error = err
    return result

  codeGenerator = new JSCodeGenerator
  result.output = codeGenerator.compile ast

  result

# Installs as a global in a browser or sets this as the main export in Node.
install = (obj, name) ->
  switch
    when module?.exports?
      module.exports = obj
    when window?
      window[name] = obj

# Install to whateve environment this.
install PalCompiler, 'PalCompiler'
