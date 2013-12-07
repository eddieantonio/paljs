# Gruntfile for Pal.JS
module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
	
	# Default: Build the project.
	grunt.registerTask 'default', '', ->
		grunt.log.write('Grunting not implemented. ').ok()

