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
compile = (fetchInput, outputter) ->
  programText = fetchInput()

  # Run the actual dang compiler on it:
  results = PalCompiler programText

  error = results.error
  output =
    results.src or JSON.stringify(results.ast, null, 2)

  # TODO: Figure out how to do this browser thing...
  window.palProgram = results.fn

  # Dig. Output it.
  outputter error, output

# Given an input element...
# Gets the text from the textarea.
makeInputFetcher = ($el) -> ->
  $el.val()

# Given an output element returns a function that...
# Places `output` on the pal-output div, in a pre.
makeOutputter = ($el) -> (err, output) ->
  $output =
    if err
      console.log err
      $('<p>').text(err.toString())
    else
      # This is what people use templates for, but... :/
      $('<pre>')
        .html(output)

  $el.html $output

$ ->
  # These are the two elements on the page where stuff happens.
  $input = $('#pal-program')
  $ouput = $('#pal-output')

  # These will be fed to the compiler dibblydank.
  inputFetcher = makeInputFetcher $input
  outputter = makeOutputter $ouput

  # Debounce the compiler thingy for immediate input, after a while of
  # keyupness. I am making sense.
  delayedCompile =
    _.debounce (-> compile(inputFetcher, outputter)), 500

  # Compile the input on change.
  $input.on 'keyup copy cut paste change', ->
    delayedCompile()

  # Compile the input for the first time.
  $input.trigger 'change'

