/*
 * PEG.JS grammar for Pal
 */

{
  function makeRightExpression(expressions) {
    var currentExpression = expressions.shift();

    if (!expressions.length) {
      return currentExpression;
    }

    currentExpression.right = makeRightExpression(expressions);

    return currentExpression;

  }

  /* Collapses binary and unary expressions. */
  function collapseExpression(expressions, final) {
    expressions.push(final);

    return makeRightExpression(expressions);
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
  = const

type_decls
  = type

var_decls
  = var var_list smcln

sub_decls
  = list:(subroutine+) {
      return list;
    }

subroutine
  = sub:( function_decl / procedure_decl ) smcln decls:declarations smcln {
    sub.declarations = decls;
    return sub;
  }


function_decl
  = function name:identifier params:formal_param_list colon type:simple_type {
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
  / compound_stat
  / sub_invocation
  / assignment
  /


conditional
  = if cond:expression then
    cons:statement
    alt:(else s:statement {return s;})? {
      return {
        ast: 'if',
        loc: [line, column],

        condition: cond,
        consequent: cons,
        alternative: alt || []
      };
    }

while_loop
  = while expression do statement

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
  / lparen expression rparen
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
  = name:identifier right:variable_rest* {
     return {
       ast: 'variable',
       loc: [line, column],

       name: name,
     };
  }

variable_rest
  = record_access
  / array_access

array_access
  = lbrack list:expression_list rbrack {
      return list;
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
 * Elaboration of declaration list.
 */

var_list
  = var_declaration smcln var_list
  / var_declaration

var_declaration
  = identifier colon any_type



/*
 * Type declarations
 */
any_type
  = simple_type

simple_type
  = name:identifier {
      return {
        ast: 'named_type',
        loc: [line, column],

        name: name
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


/*
 * Even more terminals!
 */

identifier "identifier"
  = text:id_text __ { return text; }

id_text
  = text:([A-Za-z][A-Za-z0-9]*) {
      return text[0] + text[1].join('');
    }


integer
  = d:digits __ {
      return {
        ast: 'integer',
        loc: [line, column],

        val: parseInt(d, 10)
      }
    }

real "real"
  = d:digits "." f:digits __ {
      return {
        ast: 'real',
        loc: [line, column],

        val: parseFloat(d + '.' + f, 10)
      }
    }

digits "digits"
  = chars:[0-9]+ {
      return chars.join('');
    }


string
  = "'" text:(string_char*) "'" {
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
  / "'"  { return "'"; }
  / "\\" { return "\\"; }


/*
 * Formal parameter lists.
 */
formal_param_list
  = "(" list:formal_params? ")" { return list || []; }

formal_params
  = head:formal_param rest:(smcln p:formal_param { return p; })* {
      return [head].concat(rest);
    }

formal_param
  = v:var? name:identifier colon simple_type {
      return {
        ast: 'formal_parameter',
        loc: [line, column],

        reference: !!v, /* If 'var' is present, this is true. */
      };
    }



/*
 * Non program text characters
 */
__ = token_sep *

token_sep
  = ( comment / whitespace / eol )


comment "comment"
  = multiline_comment

multiline_comment "comment"
  = "{" ( !"}" . )* "}"

whitespace "whitespace"
  = [ \t]

eol "end of line"
  = "\n"


empty
  =
