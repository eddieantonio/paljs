# A sample AST in JavaScript

AST =
  ast: 'program'

  head:
    ast: 'program head'
    name: 'hello'
    files:
      ast: 'files'
      input: 'input'
      output: 'output'

  declarations:
    ast: 'declarations'
    constants: null
    types: null
    subroutines: null

    body:
      ast: 'statements'
      nodes: [
        ast: 'subroutine call'
        name: 'writeln'
        nodes: [
          ast: 'string'
          val: 'Hello, World!'
        ]
      ]


