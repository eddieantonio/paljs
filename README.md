---
layout: default
title: README
---

# Pal.JS

An online Pal to JavaScript compiler.

## What's Pal?

It's a variant of ISO Pascal used for instuction in compiler construction
courses. Or maybe just the one I took.

## Why?

I thought redoing my CMPUT 415 project in JavaScript would be a fun
thing to do.

## Does it work?

Sort of!

Right now, I've written a [PEG.js][] [grammar][pal grammar] that recognizes a
subset of the Pal language. A subset of that subset is turned into my own
weird AST format that uses plain JavaScript objects.

This AST skips the semantic analysis phase (checking for valid programs
including type checking and all that jazz), and goes straight to code
generation. The target for code generation is JavaScript since we can just
`eval` that digglydank and run it right in the browser.

Code generation is also just done for a subset of the language. This subset
is enough that it can compile "Hello, World!", and simple functions, but not
enough to do anything truly exciting.

Furthermore, I placed what should be two repositories in one: both the demo
and the compiler share the same repository, so things are a bit cluttered.

[PEG.js]: http://pegjs.majda.cz/
[pal grammar]: https://github.com/eddieantonio/paljs/blob/gh-pages/src/grammar/pal.pegjs

