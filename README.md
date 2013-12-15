# Pal.JS

An online Pal to JavaScript compiler.

## What's Pal?

It's a variant of ISO Pascal used for instuction in compiler construction
courses. Or maybe just the one I took.

## Why?

I thought redoing my CMPUT 415 project in JavaScript would be a fun
thing to do.

## Does it work?

Kind of?

Right now, I've written a [PEG.js][] [grammar][pal grammar] that recognizes a
subset of the Pal language. A subset of that subset is turned into my own
weird ad-hoc AST format that uses plain JavaScript objects.

This AST skips the semantic analysis phase (that is, checking for valid
programs including type checking and all that jazz), and goes straight to code
generation. The target for code generation is JavaScript since we can just
`eval` that digglydank and run it right in the browser.

Code generation is also just done for a subset of the language. This subset
is enough that it can compile "Hello, World!", and simple functions, but not
enough to do anything truly exciting. For example, call-by-reference works
(because code generation never knows if a given argument should be
call-by-reference), and there are no builtins (other than `writeln`).

[PEG.js]: http://pegjs.majda.cz/
[pal grammar]: https://github.com/eddieantonio/paljs/blob/gh-pages/src/grammar/pal.pegjs

## What's left?

 * Semantic analysis! 
   - Including: a symbol table, constant compilation, type checking, etc.
 * Update code generation to use data from semantic analysis.
 * Make the demo site not as terrible.
 * "Comprehensive test suite"
 * Browser version for web workers

