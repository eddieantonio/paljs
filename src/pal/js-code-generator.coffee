# Used to traverse an AST and outputs JavaScript source code that can be
# eval'd and run.
#
# Because I have a short attention span, this does a very naïve compile over
# any ol' AST. A better version would probably need semantic analysis to tag
# certain AST nodes with metadata. It would also probably rely on a symbol
# table. But this one does nonee such thing.

class JSCodeGenerator
  constructor: -> # Do nothing
  compile: (astRoot) ->
    @ident = '  ' # I guess I should have an indent or something.
    # I don't know what else to do other than visit the node.
    # Regardless... here it is:
    @visit astRoot

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

      # Compile all of the subroutines. This is the only place where we
      # increment the indent.
      oldIdent = @ident
      @ident += '  '
      subroutines =
        @visit sub for sub in node.subroutines
      @ident = oldIdent

      # Compile the body...
      body =
        "#{@ident}#{@visit stmt};\n" for stmt in node.body

      # ...and concatenate all of the above categories.
      [].concat(vars, subroutines, body)

    'procedure': (node) ->
      # Get the names of the parameters...
      # TODO:
      params = []

      [
        @ident
        "function #{name}(#{parms.join(', ')}) {"

        # Visit this node as a generic "body" node.
        @visit node, '$body'

        @ident
        "}"
      ]

    'function': (node) ->
      # Get the names of the parameters...
      # TODO:
      # TODO: Also, refactor this to share code with 'procedure'.
      params = []

      [
        @ident
        "function #{name}(#{params.join(', ')}) {"
        "#{@ident}  var _ret;"

        # Visit this node as a generic "body" node.
        @visit node, '$body'

        # Put the return
        "#{@ident}  return _ret;"
        @ident
        "}"
      ]

    sub_invocation: (node) ->
      params =
        @visit param for param in node.params
      paramList = params.join ', '

      subroutineName =
        if node.name is 'writeln' then '_output' else '_' + node.name

      # TODO: Handle builtins.
      "#{subroutineName}(#{paramList})"

    string: (node) ->
      original = node.val
      # Replace \, ', " with its backslash escape and add quotes around it.
      # And voila, a JavaScript string literal!
      "'#{original.replace /[\\'"]/, '//$&'}'"

    # I'll get around to making these later.
    binary_plus: (node) -> @makeSimpleBinOp '+'

  # Creates a basic action for a JS binary operator.
  @makeSimpleBinOp: (binop) -> (node)->
    [visit(node.left), binop, visit(node.right)]

  # General function that generates code. This calls the appropriate node
  # action or the 'explicitAction', if given. The return should be a string.
  # Probably.
  visit: (node, explicitAction=null) ->
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

    
