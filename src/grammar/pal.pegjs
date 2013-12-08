/*
 * PEG.JS grammar for Pal
 */

program
  = __ program_head declarations period { }

program_head
  = program_keyword identifier program_files smcln

/* The "files" that the program uses.  A bizarre, non-functional leftover from
 * Pascal. The identifiers MUST be 'input' and 'output', respectively. */
program_files
  =  lparen identifier comma identifier rparen


/*
 * Declarations!
 */
declarations
  = const_decls?
    type_decls?
    var_decls?
    sub_decls?
    compound_stat

const_decls
  = const

type_decls
  = type

var_decls
  = var var_list smcln

sub_decls
  = function
  / procedure


/*
 * Common rules
 */
compound_stat
  = begin statements end

statements
  = statement smcln statements
  / statement
  /

statement
  = sub_invocation
  / compound_stat
  / assignment
  / conditional
  / while_loop
  / 


conditional
  = if expression then statement else statement
  / if expression then statement

while_loop
  = while expression do statement

assignment
  = variable assign expression


expression
  = simple_expr
  / comparative_expr

comparative_expr
  = term comparative_expr_rest

comparative_expr_rest
  = equal  simple_expr
  / nequal simple_expr

simple_expr
  = term simple_expr_rest
  / plus simple_expr_rest
  / sub  simple_expr_rest
 
simple_expr_rest
  = plus term
  / sub  term
  / or   term
  /

term
  = factor term_rest

term_rest
  = mult term
  / rdiv term
  / div  term
  / mod  term
  / and  term
  /

factor
  = variable
  / unsigned_const
  / lparen expression rparen
  / sub_invocation
  / not factor


sub_invocation
  = identifier params

params
  = lparen param_list rparen
  / lparen __ rparen

param_list
  = param comma param_list
  / param

param
  = expression

unsigned_const
  = integer
  / real
  / string

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

any_type
  = identifier


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
equal  = "=" __
great  = ">" __
less   = "<" __
nequal = "<>" __
lequal = "<=" __
gequal = ">=" __
assign = ":=" __
range  = ".." __
plus   = "+" __
sub    = "-" __
or     = "or" __
and    = "and" __
not    = "not" __
mult   = "*"
rdiv   = "/"


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

/*
 * Even more terminals!
 */

identifier "identifier"
  = text:idtext __ { return text; }

idtext
  = [A-Za-z][A-ZA-z0-9]*

integer
  = [0-9]+

real
  = integer "." integer

string
  = "'" "'"



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
