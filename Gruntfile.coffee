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

    watch:
      paljs:
        files: ["<%= coffee.paljs.src %>"]
        tasks: ['paljs']
      ui:
        files: ["<%= coffee.ui.src %>"]
        tasks: ['ui']



  # Tasks to load:
  grunt.loadNpmTasks 'grunt-peg'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'


  # Builds the client-side compiler thing.
  grunt.registerTask 'paljs', ['peg',
    'coffee:paljs', 'concat:paljs', 'uglify:paljs']
  # Builds the UI files and ugifilies.
  grunt.registerTask 'ui', ['coffee:ui', 'uglify:ui']
  # Builds EVERYTHING.
  grunt.registerTask 'build', ['paljs', 'ui']
  # Prepares the products of the build for distribution.
  grunt.registerTask 'dist', ['build']

  # Default: Build the project.
  grunt.registerTask 'default', ['dist']

