# Home page for Pal compiler demo thing.
# Dependencies:
#  - PalCompiler
#  - '$' (Zepto or jQuery)
#  - '_' (Underscore.JS)
#
# Eddie Antonio Santos <easantos@ualberta.ca>

# Calls 'inputFetcher', and compiles the string it returns. Then calls
# 'outputter' with an error in the first param or the second param the
# compiled output as a string.
compile = (inputFetcher, outputter) -> ->
  programText = inputFetcher()
  {output, error} = PalCompiler.parse programText
  outputter error, output

$ ->
  fetchInput = ->
    $('#pal-program').val()
  outputter = (err, output) ->
    $('#pal-output').html(output)

  delayedCompile = _.debounce compile(fetchInput, outputter), 300

  $('#pal-program').change ->
    delayedCompile()

