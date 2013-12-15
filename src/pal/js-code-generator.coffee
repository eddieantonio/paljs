# Used to traverse an AST and outputs JavaScript source code that can be
# eval'd and run.
#
# Because I have a short attention span, this does a very naïve compile over
# any ol' AST. A better version would probably need semantic analysis to tag
# certain AST nodes with metadata. It would also probably rely on a symbol
# table. But this one does nonee such thing.


class JSCodeGenerator
  constructor: ->
    # Initiailize the... indent amount, I guess.
    @indentAmount = '  '

  # Compiles the given AST.
  compile: (ast) ->
    # I guess I should initialize the indent or something.
    @indent = '  '

    # I don't know what else to do other than visit the node.
    # Regardless... here it is:
    @visit ast

  ##
  # Static helpers -- used for generation of this class def.
  ##

  # Returns an action for a JS binary operator.
  @makeBinOp: (binop) -> (node) ->
    ['(', @visit(node.left), binop, @visit(node.right), ')']

  # Given a function of (body, node), givens an action that compiles the
  # subroutine. It calls the given function which should return a 'filtered'
  # body.
  @makeWrappedSubroutine: (func) -> (node) ->
    params =
      @variableNameFor(paramNode.name) for paramNode in node.params

    name = @subroutineNameFor node.name
    header = "function #{name}(#{params.join(', ')}) {\n"

    # Visit the body of the subroutine, calling the given wrapper function
    # (in this context).
    body =
      @indentThis =>
        func.call(@, @visit(node.declarations, '$body'), node)

    [@indent, header, body, @indent, '}\n']


  ##
  # Actions
  ##

  # Here's the big array of AST nodes and the actions that should be called
  # when they are visited. Each each action should return either a list or a
  # string of JavaScript code.
  @actions =
    program: (node) ->
      [
        # Emit the header of the self-contained function
        '(function (input, output) {\n'
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
    # Assumes indent is set at the correct level.
    $body: (node) ->
      vars = @visit node.vars, '$stmt'

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

    procedure: @makeWrappedSubroutine (body) -> body

    'function': @makeWrappedSubroutine (body, node) ->
      retName = @variableNameFor node.name

      [
        @indent
        "var #{retName};\n"
        body
        # The return always goes at the bottom.
        @indent
        "return #{retName};\n"
      ].join('')



    'if': (node) ->
      condition =
        ['if (', @visit(node.condition), ') {\n']

      # Compile the list of statements
      body =
        @indentThis =>
          body = @visit node.consequent, '$stmt'

      elsePart =
        if node.alternative?
          topElse = [@indent, '} else {\n']
          elseBody =
            @indentThis =>
              @visit node.alternative, '$stmt'
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
      body =
        @indentThis =>
          @visit node.body, '$stmt'

      condition.concat [body, @indent, '}']

    # These two statements map 1-to-t with JS statements.
    'continue': (node) -> 'continue'
    exit: (node) -> 'break'

    # Assignment may be a statement in Pal, but it's just an operator in
    # JavaScript. I could have used @makeBinOp, but I wanted a more customized
    # appearance. Not that it'll matter to eval().
    assign: (node) ->
      [@visit(node.left), ' = ', @visit(node.right)]

    sub_invocation: (node) ->
      params =
        @visit param for param in node.params
      paramList = params.join ', '

      # Hack! I should have a table of builtins, but instead, I have only
      # implemented this one and only method.
      subroutineName =
        # TODO: Handle other builtins.
        if node.name is 'writeln'
          'output'
        else
          @subroutineNameFor node.name

      "#{subroutineName}(#{paramList})"

    variable_declaration: (node) ->
      # TODO: There should be some form of intiailization, but for that, I'd
      # need to know the types of things.
      nameList = (@variableNameFor name for name in  node.names)

      ['var ', nameList.join(', ')]

    # Variables are complicated, but I'm just going to do the following naïve
    # thing: Just spit out a dollar and the name. The dollar is so that people
    # don't name a Pal variable 'return' and generate invalid JavaScript.
    variable: (node) -> @variableNameFor(node.name)

    array_access: (node) ->
      subexpressions =
        "[#{@visit(index)}]" for index in node.expressions

      # TODO: Bounds checking.
      [@visit(node.apropos)].concat(subexpressions)

    # Turns a record access into a
    record_access: (node) ->
      [@visit(node.apropos), '[', @visit({val: node.field}, 'string'), ']']

    # Got to place strings in quotes and escape characters.
    string: (node) ->
      original = node.val
      # Replace \, ', and \n with their respective backslash escape and add
      # quotes around it. And voila, a JavaScript string literal!
      "'#{original.replace(/[\\']/g, '\\$&').replace(/\n/g, '\\n')}'"

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

    binary_mult:   @makeBinOp '*'
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

  ##
  # Additional utilities
  ##

  # Executes the function, incrementing the indent while it's running. When
  # the function returns, the original identation is restored.
  # Returns the result of the given function.
  indentThis: (func) ->
      # Increment the indent.
      oldIdent = @indent
      @indent += @indentAmount
      result = func()
      @indent = oldIdent
      result

  # Returns the 'standardized' variable name for the given string.
  variableNameFor: (str) -> '$' + str
  # Returns the 'standardized' subroutine name for the given string.
  subroutineNameFor: (str) -> '_' + str



# Export the main class.
module.exports = JSCodeGenerator
