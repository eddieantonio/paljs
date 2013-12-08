# Gruntfile for Pal.JS
module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    copyright: 'Pal.JS: 2013 (C) Eddie Antonio Santos. MIT license.'

    coffee:
      options:
        join: yes
      paljs:
        dest: 'build/pal.js'
        src: ['src/**/*.coffee']

    peg:
      options:
        trackLineAndColumn: yes
        exportVar: 'palParser'
      pal:
        src: 'src/grammar/pal.pegjs',
        dest: 'build/pal.tab.js'

    concat:
      options:
        seperator: ';'
      dist:
        src:  ['build/pal.tab.js', 'build/lib.js']
        dest: 'js/pal.js'

    uglify:
      options:
        banner: "/*!<%= copyright %>*/\n"
      dist:
        files:
          'js/pal.min.js': ['<%= concat.dist.dest %>']

  # Tasks to load:
  grunt.loadNpmTasks 'grunt-peg'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'


  # Builds the client-side compiler thing.
  grunt.registerTask 'build', ['peg', 'coffee']

  # Prepares the products of the build for distribution.
  grunt.registerTask 'dist', ['build', 'concat:dist', 'uglify:dist']

  # Default: Build the project.
  grunt.registerTask 'default', ['build']

