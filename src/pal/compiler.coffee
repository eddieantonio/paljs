# This is the main entry point for the Pal compiler.

PalParser = require './parser'

# The export is just the object with all of the helper methods.  The export
# also doubles as a shortcut to the compile() static method.
module.exports = PalCompiler = ->
  PalCompiler.compile.apply(PalCompiler,  arguments)

defaultOptions =
  shouldEval:   no
  syntaxOnly:   no
  analysisOnly: no

# Call the compiler with a string and if all goes well, get back a result
# object with:
#
#  * 'ast' -- The abstract syntax tree, fresh from parsing.
#  * 'src' -- The generated JavaScript code, as a function
#  * 'fn'  -- The Pal program as a JavaScript function.
#
#  Otherwise, an object with the field 'error' will be returned. Also, the
#  object will have a field 'where' that signifies which stage of processing
#  it failed.
#
PalCompiler.compile = (inputText, options=defaultOptions) ->
  # Figure out which compilation stages should be enabled.
  stages = prepareStages options
  # Then do them, returning their final result.
  executeStages inputText, stages


# Returns a list of all stages need for compilation.
prepareStages = (opts) ->
  # Every compilation involves the parsing stage:
  stages = [compilationStage.parse]
  (->
    # Return right away if we only need to check syntax.
    return if opts.syntaxOnly

    stages.push compilationStage.analyze
    # Return again if we just want semantic analysis
    return if opts.analysisOnly

    # Add the code generation stage!
    stages.push compilationStage.generateJS

    stages.push compilationStage.eval if opts.shouldEval
  )()

  stages


executeStages = (initialValue, stages) ->
  # Set some default fields in the result object.
  result =
    ast: null
    src: null
    fn: null
    error: null

  # Set up the initial state of the weird continuation loop thing.
  stageNo = 0
  lastStage = 'input'
  stage = stages[stageNo]

  # Contiunation loop thingy. Calls itself until it's seen every stage of
  # compilation. Stops abruptly if an error occurs.
  doNext = (err, lastResult) ->
    switch
      when err?
        result.error = err
        result.which = stages[stageNo][0]
        result

      # Continue to the next stage of compilation.
      when stageNo < stages.length
        result[lastStage] = lastResult

        # Prepare the next stage and increment the stage number.
        [ lastStage, nextStep ] = stages[stageNo]

        stageNo += 1
        nextStep(lastResult, doNext)

      # Done all stages of compilation:
      else
        result[lastStage] = lastResult
        result

  # Start the continuation loop and return its result.
  doNext(null, initialValue)


PalCompiler.parse = (inputText, cb) ->
  try
    ast = PalParser.parse inputText, 'program'
  catch err
    return cb(err)

    # Rethrow the error if it happens to be an error I made while programming
    # this thing. :/

  cb null, ast

PalCompiler.generateJS = (ast, cb) ->
  JSCodeGenerator = require './js-code-generator'

  codeGenerator = new JSCodeGenerator
  src = codeGenerator.compile ast

  # If things fail, that's because of my own incompetance as a programmer. Do
  # NOT catch the error so that I am instantally notified of my stunning and
  # glorious failure.
  cb null, src

PalCompiler.createFn = (jsCode, cb) ->
  # Oh dear. Eval. Trust me, I'm a doctor (and if it fails... well that's my
  # cue to fix the compiler).
  fn = eval jsCode

  cb null, fn

PalCompiler.semanticAnalysis = (ast, cb) ->
  # TODO: Semantic Analysis has not yet been defined.
  cb null, ast # Pass the AST unchanged.

# These are all of the possible compilation stages, from the above properties.
compilationStage =
  parse:
    ['ast', PalCompiler.parse]
  # Depends on 'parsing'
  analyze:
    ['sast', PalCompiler.semanticAnalysis]
  # Depends on 'parsing'... should depend on 'semanticAnalysis'
  generateJS:
    ['src', PalCompiler.generateJS]
  # Depends on 'codeGeneration'
  eval:
    ['fn',  PalCompiler.createFn]



# Export the compiler code.
module.exports = PalCompiler
