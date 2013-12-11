# Used to traverse an AST and outputs JavaScript source code that can be
# eval'd and run.
#
# Because I have a short attention span, this does a very naïve compile over
# any ol' AST. A better version would probably need semantic analysis to tag
# certain AST nodes with metadata. It would also probably rely on a symbol
# table. But this one does nonee such thing.


class JSCodeGenerator
  constructor: ->
    @indentAmount = '  '

  compile: (ast) ->
    # I guess I should initialize the indent or something.
    @indent = '  '

    # I don't know what else to do other than visit the node.
    # Regardless... here it is:
    @visit ast

  # Returns an action for a JS binary operator.
  @makeBinOp: (binop) -> (node) ->
    ['(', @visit(node.left), binop, @visit(node.right), ')']

  # Here's the big array of ast nodes and the actions that should be called
  # when they are visited. Each each action should return either a list or a
  # string of JavaScript code.
  @actions =
    program: (node) ->
      [
        # Emit the header of the self-contained function
        '(function (_input, _output) {\n'
        # Print variables and the body.
        @visit node.declarations
        # Emit the bottom
        '})'
      ]

    declarations: (node) ->
      # Simply delegate to the "body" parsing node.
      @visit node, '$body'

    # Pseudo-node kind. Should be fed a declaration node. This is the body
    # of any function, subroutine, etc.
    $body: (node) ->
      # TODO: visit the var declarations.
      vars = []

      # Need to expliclty defined these in this scope.
      body = undefined
      subroutines = undefined

      @indentThis =>
        # Compile all of the subroutines.
        subroutines =
          @visit sub for sub in node.subroutines

        # Compile every statment that makes up the body
        body = @visit node.body, '$stmt'

      # ...and concatenate all of the above categories.
      [].concat(vars, subroutines, body)

    # Compiles a single statement. Basically indent it and place a semi-colon
    # and newline at the end. Only creates output for statments that are
    # defined.
    $stmt: (node) ->
      if node
        [@indent, @visit(node), ';\n']
      else
        ''

    procedure: (node) ->
      # Get the names of the parameters...
      # TODO:
      params = []

      [
        @indent
        "function #{name}(#{parms.join(', ')}) {"

        # Visit this node as a generic "body" node.
        @visit node, '$body'

        @indent
        "}"
      ]

    'function': (node) ->
      # Get the names of the parameters...
      # TODO:
      # TODO: Also, refactor this to share code with 'procedure'.
      params = []

      [
        @indent
        "function #{name}(#{params.join(', ')}) {"
        "#{@indent}  var _ret;"

        # Visit this node as a generic "body" node.
        @visit node, '$body'

        # Put the return
        "#{@indent}  return _ret;"
        @indent
        "}"
      ]

    'if': (node) ->
      condition =
        ['if (', @visit(node.condition), ') {\n']

      # Compile the list of statements
      body = undefined
      @indentThis =>
        body = @visit node.consequent, '$stmt'

      elsePart =
        if node.alternative?
          topElse = [@indent, '} else {\n']
          elseBody = undefined
          @indentThis =>
            elseBody = @visit node.alternative, '$stmt'
          topElse.concat(elseBody)
        else
          []

      # The final statement should be the condition, the body, the else part
      # (optional) and finally the close brace.
      condition.concat(body, elsePart, @indent, '}')

    'while': (node) ->
      condition =
        ['while (', @visit(node.condition), ') {\n']

      # Compile the list of statements
      body = undefined
      @indentThis =>
        body = @visit node.body, '$stmt'

      condition.concat [body, @indent, '}']

    sub_invocation: (node) ->
      params =
        @visit param for param in node.params
      paramList = params.join ', '

      # Hack! I should have a table of builtins, but instead, I have only
      # implemented this one and only method.
      subroutineName =
        # TODO: Handle builtins.
        if node.name is 'writeln' then '_output' else '_' + node.name

      "#{subroutineName}(#{paramList})"

    # Got to place strings in quotes and escape characters.
    string: (node) ->
      original = node.val
      # Replace \, ', " with its backslash escape and add quotes around it.
      # And voila, a JavaScript string literal!
      "'#{original.replace /[\\'"]/, '//$&'}'"

    # For integers and reals, do nothing more than explicitly convert these to
    # strings.
    integer: (node) -> node.val.toString()
    real: (node) -> node.val.toString()

    binary_equal:  @makeBinOp '==='
    binary_nequal: @makeBinOp '!=='
    binary_gequal: @makeBinOp '>='
    binary_lequal: @makeBinOp '<='
    binary_great:  @makeBinOp '>'
    binary_less:   @makeBinOp '<'

    binary_plus:   @makeBinOp '+'
    binary_sub:    @makeBinOp '-'
    binary_or:     @makeBinOp '||'

    binary_mul:    @makeBinOp '*'
    binary_rdiv:   @makeBinOp '/'
    binary_mod:    @makeBinOp '%'
    binary_and:    @makeBinOp '&&'

    # To ensure integer division, implicitly coerce the result to integer by
    # doing a compliment operation on it, and compliment it again to get the
    # actual result. This works regardless of the operands' sign.
    binary_idiv: (node) ->
      ['(~~(', @visit(node.left), '/', @visit(node.right), '))']

    unary_pos: (node) -> @visit(node.right)
    unary_neg: (node) -> ['(-', @visit(node.right), ')']
    unary_not: (node) -> ['(!', @visit(node.right), ')']


  # General function that generates code. This calls the appropriate node
  # action or the 'explicitAction', if given. The return should be a string.
  # Probably.
  visit: (node, explicitAction=null) ->

    # Node could potentially be a node list:
    if Array.isArray node
      return (@visit n, explicitAction for n in node).join('')

    # Use either the explictly given action or the AST node kind.
    kind = explicitAction or node.ast
    { actions } = JSCodeGenerator

    # Check if we have a valid node AND
    # that we have an appropriate action for it.
    if kind? and actions[kind]?
      nodeAction = actions[kind]
      # Call the node action bound to THIS instance.
      # It should return a list or a string... of CODE!
      codeList = nodeAction.call(@, node)

      if codeList.join?
        # Return the joined list, if it's a list
        codeList.join('')
      else
        # Assume it's just a string and return it verbatim.
        codeList

    else
      console.warn 'No action for', node
      ''

  # Executes the function, but must indent all its output.
  indentThis: (func) ->
      # Increment the indent.
      oldIdent = @indent
      @indent += @indentAmount
      func()
      @indent = oldIdent


