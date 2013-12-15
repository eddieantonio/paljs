# Gruntfile for Pal.JS

module.exports = (grunt) ->
  # Normal config:
  config =
    pkg: grunt.file.readJSON 'package.json'
    copyright: 'Pal.JS: 2013 (C) Eddie Antonio Santos. MIT license.'
    lib: 'lib'
    build: 'build'

    coffee:
      paljs:
        options:
          join: no
        dest: '<%= lib %>/'
        src: ['src/pal/**/*.coffee']

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

    watch:
      src:
        files: ["<%= coffee.paljs.src %>"]
        tasks: ['pal-src']
      grammar:
        files: ["<%= peg.paljs.src %>"]
        tasks: ['pal-grammar']

  # Extend the config with  extra grunt options from src/grunt-extra directory.
  require('./src/grunt-extra')(config)

  grunt.initConfig config

  # Tasks to load:
  grunt.loadNpmTasks 'grunt-peg'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-browserify'


  # Builds the client-side compiler thing.
  grunt.registerTask 'pal-concat', ['concat:paljs']
  grunt.registerTask 'pal-src', ['coffee:paljs', 'pal-concat']
  grunt.registerTask 'pal-grammar', ['peg:pegjs']
  grunt.registerTask 'paljs', ['peg', 'pal-src']

  # Builds the UI files and ugifilies.
  grunt.registerTask 'ui', ['coffee:ui']
  # Builds EVERYTHING.
  grunt.registerTask 'build', ['paljs', 'ui']
  # Prepares the products of the build for distribution.
  grunt.registerTask 'dist', ['build', 'uglify']

  # Default: Build the project.
  grunt.registerTask 'default', ['dist']

