/*
 * PEG.JS grammar for Pal
 */

program
  = __ program_head declarations period { /* no return */ }

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
  = assignable assign expression

assignable
  = identifier
/*
  / array_access
  / record_access
*/

expression
  = identifier

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

array_access
  = assignable array_index

array_index
  = lbrack expression_list rbrack

expression_list
  = expression comma expression_list
  / expression

record_access
  = identifier period identifier


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
assign = ":=" __


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
