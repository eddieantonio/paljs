# Front-end for command line usage of the Pal parser.
# Options based on Team Cats' Pal compiler.

nopt = require 'nopt'

# So, I'm just going to ignore all of these options right now...
options =
  'bounds-checking': [Boolean, true]
  'quiet': Boolean
  'syntax-only': Boolean
  'semantic-only': Boolean

shortHands =
  'q': ['quiet']
  'a': ['bounds-checking']

usage = (name) ->
  """
  USAGE:
        #{name} [options] files...
  """

error = (msg) ->
  console.error 'pal:', msg

fatalError = (msg) ->
  error(msg)
  console.error usage('pal')
  process.exit -1


# This is the main function. I guess it's a cool guy.
main = () ->

  # Parse dem args.
  parsed = nopt options, shortHands
  files = parsed.argv.remain

  # Die if there ain't no files.
  fatalError 'Not enough file arguments' unless files.length > 0

  # We can now import the following
  fs = require 'fs'
  compiler = require './compiler'

  for file in files
    text = fs.readFileSync file, 'utf8'
    results = compiler text

    if results.error
      error "Error compiling #{file}"
      error results.error
    else
      console.log "// Compiled from #{file}"
      console.log results.src

module.exports = main
