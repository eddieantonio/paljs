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
        src: ['src/pal/**/*.coffee']
      ui:
        dest: 'build/pal-ui.js'
        src: ['src/ui/**/*.coffee']

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
      ui:
        files:
          'js/pal-ui.min.js':   ['<%= coffee.ui.dest %>']

  # Tasks to load:
  grunt.loadNpmTasks 'grunt-peg'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'


  # Builds the client-side compiler thing.
  grunt.registerTask 'build', ['peg', 'coffee', 'concat']
  # Builds the UI files and ugifilies.
  grunt.registerTask 'ui', ['coffee:ui', 'uglify:ui']

  # Prepares the products of the build for distribution.
  grunt.registerTask 'dist', ['build', 'uglify']

  # Default: Build the project.
  grunt.registerTask 'default', ['dist']

