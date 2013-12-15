# Home page for Pal compiler demo thing.
# Dependencies:
#  - PalCompiler
#  - '$' (Zepto or jQuery)
#  - '_' (Underscore.JS)
#
# Eddie Antonio Santos <easantos@ualberta.ca>

# Intended to wrap an event handler.
# Calls event.preventDefault() on it
preventDefault = (fn) -> (event) ->
  event.preventDefault()
  fn.apply @, arguments

# This function based on this answer:
# http://stackoverflow.com/a/14254253
isChar = (e) ->
  modifier =
    (e.ctrlKey) or (e.altKey) or (e.metaKey)
  isAlphanumeric =
    (65 <= e.keyCode <= 90) or (97 <= e.keyCode <= 122)
  not modifier and isAlphanumeric

# Calls the function and times how long it took to complete.
timeIt = (fn) ->
  before = performance.now()
  fn()
  after = performance.now()

  after - before

# Given an element that contains a "button list", turns all links with
# 'data-panel' attribute into button things enabling the given id.
makeButtonBar = ($buttonBar, $outputWrapper) ->
  $buttons = $buttonBar.find 'a[data-panel]'
  $outputPanels = $outputWrapper.find '.output'

  # Make each click toggle the panel
  $buttons.on 'click', preventDefault (event) ->
    $this = $ @
    panelName = $this.data 'panel'

    # Deactivate all buttons and panels.
    $buttons.removeClass 'active'
    $outputPanels.removeClass 'active'

    # Activate the panel...
    $panel = $('#'+panelName)
    $panel.addClass 'active'
    # ...and this button.
    $this.addClass 'active'

# Calls 'inputFetcher', and compiles the string it returns. Then calls
# 'outputter' with an error in the first param or the second param the
# compiled output as a string.
compile = (fetchInput, outputter) ->
  programText = fetchInput()
  results = null

  # Run the actual dang compiler on it:
  elapsedTime =
    timeIt ->
      results = PalCompiler programText

  results.time = elapsedTime

  # Dig. Output it.
  outputter results

# Given an input element...
# Gets the text from the textarea.
makeInputFetcher = ($el) -> ->
  $el.val()

# Given an output element returns a function that...
# Places `output` on the pal-output div, in a pre.
makeOutputter = (elements, $eventSource) ->
  [$console, $js, $ast] = elements

  # Adds another line to the console output.
  newConsoleLine = (line, cls='') ->
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

  # Standard outputter for stuff and things.
  writeln = ->
    rawArgs = _.toArray(arguments)
    # Coerce all arugments and create one line.
    line = _(rawArgs).map((arg) ->
      # Coerce to a string.
      arg + ''
    ).join('')

    newConsoleLine line

  # Given JavaScript source, returns a function ready to call that will
  # execute the program and output on the console.
  makeRunnableProgram = (src) ->
    fn = eval src
    # The returned program takes functions that should provide input and
    # output. Aside from 'prompt'... not sure what kind of blocking input I
    # could use. As for output, just print a new console line.
    ->
      fn(null, writeln)

  rebindRunner = (src) ->
    # Compile the program into native JavaScript.
    program = makeRunnableProgram src

    $eventSource.off 'paljs:run'
    $eventSource.on 'paljs:run', ->
      program()

  # This is the outputter:
  (result) ->
    if result.error?
      showError result.error.toString()
      return

    # No error? Update all of the displays.
    updatePlainTextDisplay $js, result.src
    updatePlainTextDisplay $ast, JSON.stringify(result.ast, null, 2)
    rebindRunner(result.src)

    # Place a nice little 'compiled' line on the output.
    $line = newConsoleLine "Compiled in #{result.time}ms"
    $line.addClass 'info'


$ ->
  # These are the two elements on the page where stuff happens.
  $input = $ '#pal-program'
  $console = $ '#console'
  $astDisplay = $ '#ast'
  $jsDisplay = $ '#js'
  $runEventSource = $ 'a[href="#!run"]'

  # These will be fed to the compiler dibblydank.
  inputFetcher = makeInputFetcher $input
  outputter = makeOutputter [$console, $jsDisplay, $astDisplay], $runEventSource

  # Debounce the compiler thingy for immediate input, after a while of
  # keyupness. I am making sense.
  delayedCompile =
    _.debounce (-> compile(inputFetcher, outputter)), 500

  # Bind the button bar/panel events
  makeButtonBar $('.output-selector'), $('.output-wrapper')
  
  # Compile the input on change.
  $input.on 'copy cut paste change', ->
    delayedCompile()
  $input.on 'keypress', (event) ->
    if isChar event
      $input.trigger 'change'

  # Tell people to run the code when the 'run event source' is clicked
  $runEventSource.on 'click', preventDefault (event) ->
    $(@).trigger 'paljs:run'

  # Compile the input for the first time.
  $input.trigger 'change'

