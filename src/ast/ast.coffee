# AST stuff

class Node
  constructor: (location, @kind, @children...) ->
    [line, column ] = location
    @location = { line, column }
    child.parent = @ for child in children

class Scope extends Node
  constructor: (location, kind, children...) ->
    super(location, kind, children)
    # Create declarative shortcuts for some children
    [@name, @declarations, _...] = children
    # Create a shortcut to the scope's body
    @body = @declarations.body

class DeclarationBlock extends Node
  constructor: (location, @constants, @types, @vars, @subroutines, @body) ->
    super(location, 'declarations', constants, types, vars, subroutines, body)

module.exports = {
  Node
  Scope
}
