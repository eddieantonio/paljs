# Gruntfile for Pal.JS
module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    peg:
      options:
        trackLineAndColumn: yes
      pal:
        src: 'src/grammar/pal.pegjs',
        dest: 'src/grammar/pal.js'

  # Tasks to load:
  grunt.loadNpmTasks 'grunt-peg'

  # Default: Build the project.
  grunt.registerTask 'default', '', ->
    grunt.log.write('Grunting not implemented. ').ok()

