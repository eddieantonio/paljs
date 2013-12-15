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

  # Dig. Output it.
  outputter results

# Given an input element...
# Gets the text from the textarea.
makeInputFetcher = ($el) -> ->
  $el.val()

# Given an output element returns a function that...
# Places `output` on the pal-output div, in a pre.
makeOutputter = (elements) ->
  [$console, $js, $ast] = elements

  # Adds another line to the console output.
  newConsoleLine = (line) ->
    $container = $console.find('.console-lines')
    $line = $('<li>').text(line)
    $container.append $line

    $line

  updatePlainTextDisplay = ($display, newText) ->
    $display.find('pre > code').text(newText)

  # Displays an error
  showError = (text) ->
    $line = newConsoleLine text
    $line.addClass 'error'

  # This is the outputter:
  (result) ->
    if result.error?
      showError result.error.toString()
    else
      updatePlainTextDisplay $js, result.src
      updatePlainTextDisplay $ast, JSON.stringify(result.ast, null, 2)

$ ->
  # These are the two elements on the page where stuff happens.
  $input = $ '#pal-program'
  $console = $ '#console'
  $astDisplay = $ '#ast'
  $jsDisplay = $ '#js'

  # These will be fed to the compiler dibblydank.
  inputFetcher = makeInputFetcher $input
  outputter = makeOutputter [$console, $jsDisplay, $astDisplay]

  # Debounce the compiler thingy for immediate input, after a while of
  # keyupness. I am making sense.
  delayedCompile =
    _.debounce (-> compile(inputFetcher, outputter)), 500

  # Compile the input on change.
  $input.on 'keyup copy cut paste change', ->
    delayedCompile()

  # Compile the input for the first time.
  $input.trigger 'change'

