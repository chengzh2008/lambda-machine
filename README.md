![Lambda Machine Screenshot](https://raw.githubusercontent.com/cdparks/lambda-machine/master/static/images/lambda-machine.png)

## What?

It's a machine for evaluating expressions in the untyped lambda calculus. You get lambdas, variables, applications, and top-level definitions. You can try it [here](http://cdparks.github.io/lambda-machine).

## Really?

Yep. Here's a grammar:

```plaintext
<definition>
    ::= <name> [<name> ...] = <expression>       -- Definition

<expression>
    ::= \ <name> . <expression>                  -- Lambda
    |   <name>                                   -- Variable
    |   <expression> <expression>                -- Application
    |   ( <expression> )                         -- Parenthesization

<name>
    ::= [<lower> <underscore>]
        [<lower> <digit> <hyphen>]*
        [<question-mark>]?
        ([<prime>]* | [<subscript>]*)
```

There is also optional syntax for natural numbers and lists, but these are desugared to plain lambda calculus at parse time:

```plaintext
[a, b, c]
    -> λcons. λnil. cons a (cons b (cons c nil))
3
    -> λs. λz. s (s (s z))
[1]
    -> λcons. λnil. cons (λs. λz. s z) nil
```

## Why?

I've been working through the exercises in [Introduction to Functional Programming Through Lambda Calculus](http://www.amazon.com/Introduction-Functional-Programming-Calculus-Mathematics/dp/0486478831) by [Greg Michaelson](http://www.macs.hw.ac.uk/~greg/), and some of these expressions have become rather tedious to reduce by hand. It'd be nice to have something that would do it for me step-by-step, ya know?

## How?

It's written in [PureScript](http://www.purescript.org/) and [React](https://facebook.github.io/react/) using the [Thermite](https://github.com/paf31/purescript-thermite) library. Expressions are converted to a locally nameless representation before being evaluated in normal order.

You can run it like this:

```bash
npm install
bower install
pulp browserify --optimise --to static/js/main.js
open index.html
```

## Who?

Me, [Chris Parks](mailto:christopher.daniel.parks@gmail.com). Feel free to say hi!
