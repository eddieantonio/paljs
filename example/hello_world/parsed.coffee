# A sample AST in JavaScript

AST =
  ast: 'program'

  head:
    ast: 'program_head'
    name: 'hello'
    files:
      ast: 'files'
      input: 'input'
      output: 'output'

  declarations:
    ast: 'declarations'
    constants: []
    types: []
    subroutines: []

    body:
      ast: 'statements'
      nodes: [
        ast: 'sub_invocation'
        name: 'writeln'
        params: [
          ast: 'string'
          val: 'Hello, World!'
        ]
      ]


