/*
 * PEG.JS grammar for Pal
 */

{
  var collapseRightExpression, collapseLeft;

  /* Warning. The following helpers are much too clever for their own good. */
  function makeCollapser(fieldName, methodName) {
    var reduce;

    /* Recursively collapses binary nodes with left-to-right associativity. */
    reduce = function (expressions) {
      var currentExpression = expressions[methodName]();

      /* If we should reduce... then do it! */
      if (expressions.length) {
        currentExpression[fieldName] = reduce(expressions);
      }

      return currentExpression;
    }

    return reduce;
  }

  /* Collapses a list of expressions from left-to-right; each added child
   * expression is called 'right'. */
  collapseRightExpression = makeCollapser('right', 'shift');
  /* Collapses a list of expressions from right-to-left; each added child
   * expression is called 'apropos' (think 'of', but unnecessarily fancy). */
  collapseLeft = makeCollapser('apropos', 'pop');

  /* Collapses binary and unary expressions. */
  function collapseExpression(expressions, final) {
    if (expressions.length) {
      expressions.push(final);
      return collapseRightExpression(expressions);
    }
    return final;
  }

  function collapseVariable(expressions, leaf) {
    if (expressions.length) {
      expressions.unshift(leaf);
      return collapseLeft(expressions);
    }
    return leaf;
  }

}



program
  = __ head:program_head decls:declarations period {
      return {
        ast: 'program',
        loc: [line, column],

        head: head,
        declarations: decls
      }
    }



/*
 * Program stuff.
 */

program_head
  = program_keyword name:identifier files:program_files smcln {
    return {
      ast: 'program_head',
      loc: [line, column],

      name: name,
      files: files
    }
  }

/* The "files" that the program uses.  A bizarre, non-functional leftover from
 * Pascal. The identifiers MUST be 'input' and 'output', respectively. */
program_files
  = lparen input:identifier comma output:identifier rparen {
    return {
      ast: 'program_files',
      loc: [line, column],

      input: input,
      output: output
    }
  }


/*
 * Declarations!
 */
declarations
  = constants:const_decls?
    types:type_decls?
    vars:var_decls?
    subroutines:sub_decls?
    body: compound_stat {
      return {
        ast: 'declarations',
        loc: [line, column],

        constants: constants || [],
        types: types || [],
        vars: vars || [],
        subroutines: subroutines || [],
        body: body
      }
    }

const_decls
  = const list:const_decl+ { return list; }

type_decls
  = type list:type_decl+ { return list; }

var_decls
  = var list:var_decl+ { return list; }

sub_decls
  = list:subroutine+ { return list; }

subroutine
  = sub:( function_decl / procedure_decl ) smcln decls:declarations smcln {
    sub.declarations = decls;
    return sub;
  }


function_decl
  = function name:identifier params:formal_param_list colon type:named_type {
      return {
        ast: 'function',
        loc: [line, column],

        name: name,
        params: params,
        rtype: type
      };
    }

procedure_decl
  = procedure name:identifier params:formal_param_list {
      return {
        ast: 'procedure',
        loc: [line, column],

        name: name,
        params: params,
      };
    }

/* Simple declarations: */
const_decl
  = name:identifier equal expr:expression smcln {
      return {
        ast: 'constant_declaration',
        loc: [line, column],

        name: name,
        expr: expr
      };
    }

type_decl
  = name:identifier equal type:type_expr smcln {
      return {
        ast: 'type_declaration',
        loc: [line, column],

        name: name,
        type: type
      };
    }

var_decl
  = names:identifier_list colon type:type_expr smcln  {
      return {
        ast: 'variable_declaration',
        loc: [line, column],

        names: names,
        type: type
      };
    }

identifier_list
  = first:identifier rest:(comma id:identifier { return id; })* {
      return [first].concat(rest);
  }


/*
 * Common rules
 */
compound_stat
  = begin list:statements end { return list; }

statements
  = stmt:statement rest:(smcln s:statement { return s; })* {
      return [stmt].concat(rest);
    }

statement
  = conditional
  / while_loop
  / structured_statement
  / compound_stat
  / sub_invocation
  / assignment
  / { return; } /* Return NOTHING. */


conditional
  = if cond:expression then
    cons:statement
    alt:(else s:statement {return s;})? {
      return {
        ast: 'if',
        loc: [line, column],

        condition: cond,
        consequent: cons,
        alternative: alt || null
      };
    }

structured_statement
  = exit {
      return {
        ast: 'exit',
        loc: [line, column],
      }
    }
  / continue {
      return {
        ast: 'continue',
        loc: [line, column],
      }
    }


while_loop
  = while cond:expression do body:statement {
      return {
        ast: 'while',
        loc: [line, column],

        condition: cond,
        body: body,
      };

  }

assignment
  = left:variable assign right:expression {
      return {
        ast: 'assign',
        loc: [line, column],

        left: left,
        right: right
      }
    }


/*
 * Expressions
 */

expression
  = exprs:comparative_expression* right:simple_expr {
      return collapseExpression(exprs, right);
    }

comparative_expression
  = left:simple_expr op:comparison_op {
      return {
        ast: 'binary_' + op,
        loc: [line, column],

        left: left
      };
    }

comparison_op
  = equal  { return 'equal';  }
  / nequal { return 'nequal'; }
  / lequal { return 'lequal'; }
  / gequal { return 'gequal'; }
  / less   { return 'less';   }
  / great  { return 'great';  }

simple_expr
  = exprs:additive_expression* right:term {
      return collapseExpression(exprs, right);
    }

additive_expression
  = op:term_prefix {
      return {
         ast: 'unary_' + op,
         loc: [line, column]
      };
    }
  / left:term op:additive_op {
      return {
        ast: 'binary_' + op,
        loc: [line, column],

        left: left
      }
    }

term_prefix
 = plus   { return 'pos' }
 / sub    { return 'neg' }

additive_op
  = or    { return 'or'; }
  / plus  { return 'plus'; }
  / sub   { return 'sub'; }

term
  = exprs:multiplicative_expression* right:factor {
      return collapseExpression(exprs, right);
  }

multiplicative_expression
  = left:factor op:multiplicative_op {
    return {
      ast: 'binary_' + op,
      loc: [line, column],

      left: left
    }
  }

multiplicative_op
  = mult { return 'mult' }
  / rdiv { return 'rdiv' }
  / div  { return 'idiv' }
  / mod  { return 'mod'; }
  / and  { return 'and'; }


factor
  = not right:factor {
      return {
        ast: 'unary_not',
        loc: [line, column],
        right: right
      };
    }
  / sub_invocation
  / variable
  / lparen x:expression rparen { return x; }
  / unsigned_const


sub_invocation
  = name:identifier params:params {
      return {
        ast: 'sub_invocation',
        loc: [line, column],

        name: name,
        params: params
      }
    }

params
  = lparen list:param_list rparen { return list; }

param_list
  = head:param rest:(comma p:param { return p; })* {
      return [head].concat(rest);
    }
  / { return []; }

param
  = expression

unsigned_const
  = real
  / integer
  / string


/*
 * Variables.
 * This is broken.
 */

variable
  = name:identifier rest:variable_rest* {
      return collapseVariable(rest, {
       ast: 'variable',
       loc: [line, column],

       name: name,
     });
  }

variable_rest
  = record_access
  / array_access

array_access
  = lbrack list:expression_list rbrack {
      return {
        ast: 'array_access',
        loc: [line, column],

        expressions: list,
      };
    }

expression_list
  = head:expression rest:(comma e:expression { return e; })* {
      return [head].concat(rest);
    }

record_access
  = period name:identifier {
      return {
        ast: 'record_access',
        loc: [line, column],
        field: name
      };
    }



/*
 * Type declarations
 */
type_expr
  = structured_type
  / simple_type

simple_type
  = named_type
  / enumeration

named_type
  = name:identifier {
      return {
        ast: 'named_type',
        loc: [line, column],

        name: name
      };
    }

enumeration
  = lparen names:identifier_list rparen {
      return {
        ast: 'enumeration',
        loc: [line, column],

        names: names
      };
    }

structured_type
  = array_type
  / record_type

array_type
  = array lbrack index:index_type rbrack of element:type_expr {
      return {
        ast: 'array_type',
        loc: [line, column],

        indexType: index,
        elementType: element
      };
    }

index_type
  = subrange_type
  / named_type

subrange_type
  = left:expression range right:expression {
      return {
        ast: 'subrange_type',
        loc: [line, column],

        lower: left,
        upper: right
      };
    }

record_type
  = record fields:field_list end {
      return {
        ast: 'record_type',
        loc: [line, column],

        fields: fields
      };
    }

field_list
  = first:field rest:(smcln f:field { return f; })* {
      return [first].concat(rest);
    }

field
  = name:identifier colon type:type_expr {
      return {
        'ast': 'record_field',
        loc: [line, column],

        name: name,
        type: type
      };
    }



/*
 * Generic Terminals
 */
period = "." __
lparen = "(" __
rparen = ")" __
lbrack = "[" __
rbrack = "]" __
comma  = "," __
colon  = ":" __
smcln  = ";" __
plus   = "+" __
sub    = "-" __
mult   = "*" __
rdiv   = "/" __
equal  = "=" __
great  = ">" __
less   = "<" __
nequal = "<>" __
lequal = "<=" __
gequal = ">=" __
assign = ":=" __
range  = ".." __

/*
 * Keywords
 */
program_keyword = "program" token_sep
begin     = "begin" __
end       = "end" __
const     = "const" __
type      = "type" __
var       = "var" __
procedure = "procedure" __
function  = "function" __
if        = "if" __
then      = "then" __
else      = "else" __
while     = "while" __
do        = "do" __
div       = "div" __
mod       = "mod" __
or        = "or" __
and       = "and" __
not       = "not" __
array     = "array" __
of        = "of"__
record    = "record"__
continue  = "continue"__
exit      = "exit"__

/* Great big list of keywords. These cannot be matched by an identifier. */
keyword =
  "begin" / "end" /
  "const" / "type" / "var" / "procedure" / "function" /
  "if" / "then" / "else" / "while" / "do" /
  "div" / "mod" / "or" / "and" / "not" /
  "array" / "of" / "record" /
  "continue" / "exit"


/*
 * Even more terminals!
 */

identifier "identifier"
  = !keyword text:id_text __ { return text; }

id_text
  = head:ALPHA tail:(ALPHA/DIGIT)* { return head + tail.join(''); }


integer "integer"
  = d:digits __ {
      return {
        ast: 'integer',
        loc: [line, column],

        val: parseInt(d, 10)
      }
    }

real "real"
  = iPart:digits "." fPart:DIGIT+ __ {
      return {
        ast: 'real',
        loc: [line, column],

        val: parseFloat(iPart + '.' + fPart, 10)
      }
    }

digits
  = head:NZDIGIT tail:DIGIT* { return head + tail.join(''); }
  / "0"


string "string"
  = "'" text:(string_char*) "'" __ {
      return {
        ast: 'string',
        loc: [line, column],

        val: text.join('')
      }
    }

string_char
  = normal_string_char
  / string_escape

normal_string_char
  = !("'" / eol / "\\") char:. { return char; }

string_escape
  = "\\" char:escaped_char { return char; }

escaped_char
  = "n"  { return "\n"; }
  / "t"  { return "\t"; }
  / "'"  { return "'"; }
  / "\\" { return "\\"; }


/*
 * Basic lexical entities.
 */

ALPHA
  = [A-Z]i

DIGIT "digit"
  = [0-9]

NZDIGIT "non-zero digit"
  = [1-9]

/*
 * Formal parameter lists.
 */
formal_param_list
  = lparen list:formal_params? rparen { return list || []; }

formal_params
  = head:formal_param rest:(smcln p:formal_param { return p; })* {
      return [head].concat(rest);
    }

formal_param
  = v:var? name:identifier colon type:named_type {
      return {
        ast: 'formal_parameter',
        loc: [line, column],

        name: name,
        type: type,
        reference: !!v, /* If 'var' is present, this is true. */
      };
    }



/*
 * Non program text characters
 */
__ = token_sep * { return; } /* No need to return anything at all. */

token_sep
  = ( comment / whitespace / eol )


comment "comment"
  = multiline_comment
  / cpp_comment

multiline_comment "comment"
  = "{" ( !"}" . )* "}"

cpp_comment
  = "//" (!eol .)*

whitespace "whitespace"
  = [ \t]

eol "end of line"
  = "\n"

