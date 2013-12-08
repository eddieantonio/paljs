# A sample AST in JavaScript

AST =
  ast: 'program'

  head:
    ast: 'program_head'
    name: 'factorial'
    files:
      ast: 'files'
      input: 'input'
      output: 'output'

  declarations:
    ast: 'declarations'
    constants: []
    types: []
    subroutines: [

      ast: 'function'
      name: 'factorial'
      params: [
        ast: 'formal_parameter'
        reference: no
        name: 'n'
        type:
          ast: 'named type'
          name: 'integer'
      ]
      rettype:
        ast: 'named_type'
        name: 'integer'

      declarations:
        ast: 'declarations'
        constants: []
        types: []
        subroutines: []
        body: [
          ast: 'if'
          condition:
            ast: '<='
            left:
              ast: 'scalar'
              name: 'n'
            right:
              ast: 'integer'
              val: 1
          consequent: [
            ast: 'assignment'
            left:
              ast: 'scalar'
              val: 'fatorial'
            right:
              ast: 'integer'
              val: 1
          ]
          alternative: [
            ast: 'assignment'
            left:
              ast: 'scalar'
              val: 'fatorial'
            right:
              ast: '*'
              left:
                ast: 'scalar'
                val: 'n'
              right:
                ast: 'subroutine call'
                name:
                  ast: 'scalar'
                  val: 'fatorial'
                args: [
                  ast: '-'
                  left:
                    ast: 'scalar'
                    val: 'n'
                  right:
                    ast: 'integer'
                    val: 1
                ]
          ]
        ]

    ]

    body: [
      ast: 'subroutine call'
      name: 'writeln'
      args: [
        ast: 'subroutine call'
        name: 'factorial'
        args: [
          ast: 'integer'
          val: 6
        ]
      ]
    ]

module.exports = AST
