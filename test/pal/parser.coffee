# Test basic parsing.

{ expect } = require 'chai'

parser = require '../../src/pal/parser'

describe 'Pal Parser', ->

  describe 'integer parser', ->
    parse = (input) -> parser.parse input, 'integer'

    it 'should parse simple integers', ->
      zero = parse('0')

      expect(zero).to.have.property 'ast', 'integer'
      expect(zero).to.have.property 'val', 0

      num = parse('123456789')
      expect(num).to.have.property 'ast', 'integer'
      expect(num).to.have.property 'val', 123456789

  describe 'identifier parser', ->
    parse = (input) -> parser.parse input, 'identifier'
      
    it 'should return a string', ->
      str = 'D10Zbdsaf10'
      sample = parse(str)

      expect(sample).to.be.a 'string'
      expect(sample).to.equal str

    it 'should not accept a leading digit', ->
      expect(-> parse('0input')).to.throw(parser.SyntaxErrro)
      expect(-> parse('9output')).to.throw(parser.SyntaxErrro)

    it 'should not accept keywords', ->
      # A select few are tested here.
      expect(-> parse('begin')).to.throw(parser.SyntaxErrro)
      expect(-> parse('if')).to.throw(parser.SyntaxErrro)
      expect(-> parse('while')).to.throw(parser.SyntaxErrro)
      expect(-> parse('end')).to.throw(parser.SyntaxErrro)

