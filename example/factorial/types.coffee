# A sample AST in JavaScript

AST =
  ast: 'program'

  head:
    ast: 'program head'
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
        ast: 'formal parameter'
        reference: no
        name: 'n'
        type:
          ast: 'named type'
          name: 'integer'
      ]
      rettype:
        ast: 'named type'
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
            type: 'boolean'
            left:
              ast: 'scalar'
              name: 'n'
              type: 'integer'
            right:
              ast: 'integer'
              val: 1
              type: 'integer'
          consequent: [
            ast: 'assignment'
            left:
              ast: 'scalar'
              val: 'fatorial'
              type: 'integer'
            right:
              ast: 'integer'
              val: 1
              type: 'integer'
          ]
          alternative: [
            ast: 'assignment'
            left:
              ast: 'scalar'
              val: 'fatorial'
              type: 'integer'
            right:
              ast: '*'
              type: 'integer'
              left:
                ast: 'scalar'
                val: 'n'
                type: 'integer'
              right:
                ast: 'subroutine call'
                type: 'integer'
                name:
                  ast: 'scalar'
                  val: 'fatorial'
                  type: 'integer'
                args: [
                  ast: '-'
                  left:
                    ast: 'scalar'
                    val: 'n'
                    type: 'integer'
                  right:
                    ast: 'integer'
                    val: 1
                    type: 'integer'
                ]
          ]
        ]

    ]

    body: [
      ast: 'subroutine call'
      name: 'writeln'
      type: 'integer'
      args: [
        ast: 'subroutine call'
        type: 'integer'
        name: 'factorial'
        args: [
          ast: 'integer'
          val: 6
          type: 'integer'
        ]
      ]
    ]

module.exports = AST
