# A sample AST in JavaScript

AST =
  ast: 'program'

  head:
    ast: 'program head'
    name:
      ast: 'identifier'
      val: 'factorial'
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
    constants: []
    types: []
    subroutines: [

      ast: 'function'
      name:
        ast: 'identifier'
        val: 'factorial'
      params: [
        ast: 'formal parameter'
        reference: no
        name:
          ast: 'identifier'
          val: 'n'
      ]
      rettype:
        ast: 'identifier'
        val: 'integer'

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
              ast: 'identifier'
              val: 'n'
            right:
              ast: 'integer'
              val: 1
          consequent: [
            ast: 'assignment'
            left:
              ast: 'identifier'
              val: 'fatorial'
            right:
              ast: 'integer'
              val: 1
          ]
          alternative: [
            ast: 'assignment'
            left:
              ast: 'identifier'
              val: 'fatorial'
            right:
              ast: '*'
              left:
                ast: 'identifier'
                val: 'n'
              right:
                ast: 'subroutine call'
                name:
                  ast: 'identifier'
                  val: 'fatorial'
                args: [
                  ast: '-'
                  left:
                    ast: 'identifier'
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
      name:
        ast: 'identifier'
        val: 'writeln'
      args: [
        ast: 'subroutine call'
        name:
          ast: 'identifier'
          val: 'factorial'
        args: [
          ast: 'integer'
          val: 6
        ]
      ]
    ]

module.exports = AST
