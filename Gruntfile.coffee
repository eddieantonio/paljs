# Gruntfile for Pal.JS

module.exports = (grunt) ->
  # Normal config:
  config =
    pkg: grunt.file.readJSON 'package.json'
    copyright: 'Pal.JS: 2013 (C) Eddie Antonio Santos. MIT license.'
    lib: 'lib'

    peg:
      paljs:
        options:
          trackLineAndColumn: yes
          exportVar: 'module.exports'
        src: 'src/grammar/pal.pegjs',
        # The destination is in src/ because that makes it easy to `require`
        # from other CoffeeScript things.
        dest: 'src/pal/parser.js'

    browserify:
      paljs:
        options:
          transform: ['coffeeify']
          extensions: '.coffee'
        src: ['./src/pal/browser.coffee']
        dest: 'pal.js'

    uglify:
      options:
        banner: "/*!<%= copyright %>*/\n"
      paljs:
        files:
          'pal.min.js':  ['<%= browserify.paljs.dest %>']

    mochaTest:
      paljs:
        options:
          reporter: 'spec'
          require: 'coffee-script'
          clearRequireCache: yes
        src: ['test/**/*.coffee']

    watch:
      src:
        files: [
          "src/pal/**/*.coffee",
          "src/pal/parser.js",
          "<%= mochaTest.paljs.src %>"]
        tasks: ['pal-src']
      grammar:
        files: ["<%= peg.paljs.src %>"]
        tasks: ['pal-grammar']

  # Extend the config with  extra grunt options from src/grunt-extra directory.
  require('./src/grunt-extra')(config)

  grunt.initConfig config

  # Tasks to load:
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-peg'


  # Builds the client-side compiler thing.
  grunt.registerTask 'pal-src', ['mochaTest:paljs']
  grunt.registerTask 'pal-grammar', ['peg:paljs']
  grunt.registerTask 'paljs', ['peg', 'pal-src']

  # Builds the UI files and ugifilies.
  # TODO: this should be specified only in the gh-pages branch. Somehow.
  grunt.registerTask 'ui', ['browserify:paljs', 'coffee:ui']
  # Builds EVERYTHING.
  grunt.registerTask 'build', ['paljs', 'browserify:paljs']
  # Prepares the products of the build for distribution.
  grunt.registerTask 'dist', ['build', 'uglify']

  # Default: Build the project.
  grunt.registerTask 'default', ['build']

