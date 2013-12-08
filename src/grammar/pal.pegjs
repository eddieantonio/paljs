/*
 * PEG.JS grammar for Pal
 */

program = __ e:expression { return e;}
/*
program
  = __ head:program_head decls:declarations period {
      return {
        ast: 'program',
        loc: [line, column],

        head: head,
        declarations: decls
      }
    }
*/



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
  = if expression then statement else statement
  / if expression then statement

while_loop
  = while expression do statement

assignment
  = variable assign expression


/*
 * Expressions
 */

expression
  = comparative_expression* simple_expr

comparative_expression
  = simple_expr comparison_op

comparison_op
  = equal
  / nequal
  / lequal
  / gequal
  / less
  / great

simple_expr
  = additive_expression* term

additive_expression
  = term_prefix
  / term additive_op

term_prefix
 = plus
 / sub

additive_op
  = or
  / plus
  / sub

term
  = multiplicative_expression* factor

multiplicative_expression
  = factor multiplicative_op

multiplicative_op
  = mult
  / rdiv
  / div
  / mod
  / and


factor
  = not factor
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
 * Variables and assignables!
 */

variable
  = identifier variable_rest

variable_rest
  = period variable
  / array_index+
  /

array_access
  = variable array_index

array_index
  = lbrack expression_list rbrack

expression_list
  = expression comma expression_list
  / expression

record_access
  = variable period identifier



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
  = text:([A-Za-z][A-ZA-z0-9]*) {
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
