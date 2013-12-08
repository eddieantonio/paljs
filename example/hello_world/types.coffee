# A sample AST in JavaScript

AST =
  ast: 'program'

  head:
    ast: 'program head'
    name:
      ast: 'identifier'
      val: 'hello'
    files:
      ast: 'files'
      input:
        ast: 'identifier'
        val: 'input'
      output:
        ast: 'identifier'
        val: 'output'

  declarations:
    ast: 'declarations'
    constants: null
    types: null
    subroutines: null

    body:
      ast: 'statements'
      nodes: [
        ast: 'subroutine call'
        type: null
        name:
          ast: 'identifier'
          val: 'writeln'
        nodes: [
          ast: 'string'
          type: 'string:13'
          val: 'Hello, World!'
        ]
      ]

