# Half-way through writing a meaty example, I decided that identifiers should
# *not* be AST nodes, per se. Rather, they can just be string properties of
# objects. Yeah!

isArray = Array.isArray

# Unidentify
unidentify = (node) ->
  switch
    when isArray node
      # It's an array!
      unidentify child for child in node

    when 'identifier' is node?.ast
      node.val

    when node.ast?
      for own name, child of node
        node[name] = unidentify child
      node

    else
      node

module.exports = unidentify
