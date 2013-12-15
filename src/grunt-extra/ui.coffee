# Grunt subtasks for UI stuff.
module.exports =
  coffee:
    ui:
      dest: 'js/pal-ui.js'
      src: ['src/ui/**/*.coffee']

  uglify:
    ui:
      files:
        'js/pal-ui.min.js':   ['<%= coffee.ui.dest %>']

  watch:
    ui:
      files: ["<%= coffee.ui.src %>"]
      tasks: ['ui']

