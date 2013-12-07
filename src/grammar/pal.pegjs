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
  = "const"

type_decls
  = "type"

var_decls
  = "var"

sub_decls
  = "function"
  / "procedure"


/*
 * Useful rules
 */
compound_stat
  = begin statements end


statements
  = statement smcln statements
  / statement
  /

statement
  = sub_invocation
  /

sub_invocation
  = identifier params

params
  = lparen param_list rparen

param_list
  = param comma param_list
  / param

param
  = expression

expression
  = identifier

/*
 * Generic Terminals
 */
period = "." __
lparen = "(" __
rparen = ")" __
comma  = "," __
smcln    = ";" __

/*
 * Keywords
 */

program_keyword
  = "program" token_sep

begin = "begin" token_sep
end   = "end" __
if    = "if" __

 

/*
 * Terminals!
 */

identifier "identifier"
  = text:idtext __ { return text; }

idtext
  = [A-Za-z][A-ZA-z0-9]*



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
