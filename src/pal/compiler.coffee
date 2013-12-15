# This is the main entry point for the Pal compiler.

PalParser = require './parser'
JSCodeGenerator = require './js-code-generator'

# Call PalCompiler with a string and if all goes well, get back a result
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
PalCompiler = (inputText, options={}) ->
  result =
    ast: null
    src: null
    fn: null
    error: null

  stages = [
    ['ast', PalCompiler.parse],
    ['src', PalCompiler.generateJS]
    ['fn',  PalCompiler.createFn]
  ]

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
  doNext(null, inputText)


PalCompiler.parse = (inputText, cb) ->
  try
    ast = PalParser.parse inputText, 'program'
  catch err
    return cb err

  cb null, ast

PalCompiler.generateJS = (ast, cb) ->
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

# Export the compiler code.
module.exports = PalCompiler
