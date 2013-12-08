# Gruntfile for Pal.JS
module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      options:
        join: yes
      paljs:
        dest: 'build/pal.js'
        src: ['src/**/*.coffee']

    peg:
      options:
        trackLineAndColumn: yes
      pal:
        src: 'src/grammar/pal.pegjs',
        dest: 'build/pal.tab.js'


  # Tasks to load:
  grunt.loadNpmTasks 'grunt-peg'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'


  # Define the task that builds the client-side
  # compiler thing.
  grunt.registerTask 'build', ['peg', 'coffee']

  # Default: Build the project.
  grunt.registerTask 'default', ['build']

