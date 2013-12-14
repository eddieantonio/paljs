# Gruntfile for Pal.JS

module.exports = (grunt) ->
  # Normal config:
  config =
    pkg: grunt.file.readJSON 'package.json'
    copyright: 'Pal.JS: 2013 (C) Eddie Antonio Santos. MIT license.'

    coffee:
      options:
        join: yes
      paljs:
        dest: 'build/pal.js'
        src: ['src/pal/**/*.coffee']

    peg:
      options:
        trackLineAndColumn: yes
        exportVar: 'PalParser'
      paljs:
        src: 'src/grammar/pal.pegjs',
        dest: 'build/pal.tab.js'

    concat:
      options:
        seperator: ';'
      paljs:
        src:  ['<%= peg.paljs.dest %>', '<%= coffee.paljs.dest %>']
        dest: 'js/pal.js'

    uglify:
      options:
        banner: "/*!<%= copyright %>*/\n"
      paljs:
        files:
          'js/pal.min.js':      ['<%= concat.paljs.dest %>']

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


  # Builds the client-side compiler thing.
  grunt.registerTask 'pal-concat', ['concat:paljs']
  grunt.registerTask 'pal-src', ['coffee:paljs', 'pal-concat']
  grunt.registerTask 'pal-grammar', ['peg', 'pal-concat']
  grunt.registerTask 'paljs', ['peg', 'pal-src']

  # Builds the UI files and ugifilies.
  grunt.registerTask 'ui', ['coffee:ui']
  # Builds EVERYTHING.
  grunt.registerTask 'build', ['paljs', 'ui']
  # Prepares the products of the build for distribution.
  grunt.registerTask 'dist', ['build', 'uglify']

  # Default: Build the project.
  grunt.registerTask 'default', ['dist']

