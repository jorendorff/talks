# Algebraic Data Types (with examples in Haskell)

*(I gave this mini-talk at NashFP in July 2015.)*


## Motivation

Algebraic data types are boring, and this talk would be boring,
except that algebraic data types are also very practical.
They are everywhere
in the languages that have them,
and bloated, error-prone code is everywhere
in the languages that don't have them.

> .@lojikil @andywingo surprising how much computer stuff makes sense
> viewed as tragic deprivation of sum types (cf. deprivation of lambdas)

https://twitter.com/graydon_pub/status/555046888714416128

This tweet is from Graydon Hoare,
designer of the Rust programming language
and a programming language history buff.

Graydon calls the lack of sum types "tragic".
He compares it to the deprivation of lambdas,
which—if you don't remember a world without lambdas, good for you,
but you can imagine how awful that must have been, right?

What are sum types? We're about to find out.
Algebraic data types provide sum types.
They're also called "discriminated unions".

People call programming language features "powerful" a lot.
I think the word is overused.

Algebraic data types are the real thing.


## Example: `Bool`

I'm going to show examples in Haskell.
I think this feature came from ML,
and it's in most every statically typed functional language in the ML lineage,
which includes OCaml, F#, Elm, and others.

    data Bool = False | True

This one line of code declares three things.

`Bool` is a type.

`False` and `True` are called "constructors".
The terminology is a little different from object-oriented languages.
These are not functions.
They're not special methods or anything like that.
They are values of type `Bool`.

(Type names and constructor names have to be uppercase in Haskell,
because of reasons.)

So now that we know what's going on here,
let's re-read this line of code one word at a time:

"The data type Bool means either False or True."

So that's it. It's really just an enum.

There's no such thing as subclassing in Haskell,
so there will never be additional values of type `Bool`.
The two constructors declared here
are the *only* values of type `Bool`.


## Example: `TimeUnit`

Here's another very simple example:

    data TimeUnit = Year | Month | Day | Hour | Minute | Second

This one isn't a standard library anything, I just made this up.

Again, we're declaring a type, `TimeUnit`,
and six different constructors of that type.

"The data type `TimeUnit` means either `Year` or `Month` or `Day`, etc."


## Example: `RoughTime`

Now let's build on that.

    data RoughTime = InThePast Int TimeUnit
                   | JustNow
                   | InTheFuture Int TimeUnit

You know how some web sites, when you look at a comment or something,
it'll say, "posted 13 days ago", or "posted 5 minutes ago",
or something like that?

Well, here's an algebraic data type that represents just *that*,
that concept of an approximate point in time, relative to now.
Like a timestamp, but fuzzy. Intuitive rather than precise.

These three lines of code declare a type, `RoughTime`,
and three constructors.
What's new here is that two of the constructors take arguments.

Now, the `TimeUnit` constructors are not functions.
They are literally just values of type `TimeUnit`.
But here, `InThePast` is a function.
You have to call that function and pass arguments
to get a `RoughTime` value.
And whatever arguments you pass are just stored as fields
in the `RoughTime` value that you created.

So for example, you can write

    when = InThePast 27 Day

and the type of `when` is `RoughTime`, and that value means "27 days ago".


## How to consume values of algebraic data types

So I'm showing you on this line how you create values of type `RoughTime`.
But how do you consume them? And the answer is, you use pattern matching.
Constructors not only create values and put data into them,
they can be used in pattern matching to get that data out again.

Let's write a super simple function on `RoughTime` values.
Say we just want to display a `RoughTime` on a web page.
We want to render it in plain English.

    toEnglish :: RoughTime -> String

This is a type declaration.
`toEnglish` is the function we want to write.
Its type is "function taking a `RoughTime` argument
and returning a `String`".

Now we have to write the body of this function.

The easiest way is to use pattern matching:

    toEnglish JustNow = "just now"

Line one, we match `JustNow`.
When you call this function, if the argument happens to be `JustNow`,
then this line is what executes, and the result is this string.

Otherwise, the argument is something else.
Pattern matching fails, and we move to the next line.

    toEnglish (InThePast num unit) =
      show num ++ " " ++ unitToEnglish unit ++ " ago"
    toEnglish (InTheFuture num unit) =
      show num ++ " " ++ unitToEnglish unit ++ " from now"

If the value you pass to this function happens to be in the past,
then pattern matching fishes out the two fields of that `InThePast` value
and binds them to these variables `num` and `unit`.
Pretty neat, huh?

And then we render them. The `++` here means string concatenation.

Note that the ADT defines three constructors,
and here we have one, two, three cases.
If we forgot to write this third case,
the compiler would warn us about that.


## Example: `JSON`

I have another example that might help explain what ADTs are good for.

Does everybody know what JSON is?

Have you read the JSON standard?
It's remarkably short. Just 5 pages long!

But the data that JSON can represent is even simpler:

    data JSON = JNull
              | JBool Bool
              | JNum Float
              | JStr String
              | JArray [JSON]
              | JObject [(String, JSON)]

Does this need any explanation? No? Great. On we go.


## Example: `Maybe`

If you're coming from dynamically-typed languages,
you may be thinking, yeah, I'm sorry your language sucks,
but I'm using Awesome Language X,
where I've got strings, I've got tuples,
and I can just pass whatever value I want wherever I want.

All right then, smarty-pants,
riddle me [this tweet from Dave Herman](https://twitter.com/littlecalculist/status/563590067445194753):

> What's your favorite way to represent Option&lt;T&gt; in JS?
> I'm partial to `null | { value: T }`.

Important follow-up tweet:

> (Assume that T can include null and undefined so the judges
> will not accept using either of them for None.)

Sometimes you need some way to express this idea:
there may or may not be a value.
Sometimes the value is `null`,
but sometimes there *isn't* a value,
and those are two different things.
So this need is *not* addressed by nullability.

*(The ECMAScript standard committee needed a way to express this
in the iterator protocol: the return value of `.next()`.)*

*(slide: highlight "Option&lt;T&gt;")*

Well, what you need is what's called the option type in languages like ML.
And different languages have different syntax, but
you might write it like Dave did: `Option<T>`.
That's how it's written in Rust.

In Haskell, we write `Maybe a`.
Just like Haskell eliminates the parentheses around the parameters you pass to functions,
it also eliminates the angle brackets in parameterized types.

And instead of `Option`, Haskell uses the word `Maybe` for this type.
Maybe there's a value there. Maybe not.

And how is this defined? Super simple:

    data Maybe a = Nothing | Just a

Again, we're declaring three things here:
`Maybe` is a type; `Nothing` and `Just` are the constructors.
And `a` is whatever type you like.

A value of type `Maybe ChessPiece` is either `Nothing`, or `Just` a `ChessPiece`.

This is how `Maybe` is defined in the Haskell standard library.

Are there any advantages of having a `Maybe` type in your language,
instead of just everything being nullable all the time?

*   Well, for one thing, in practice,
    most variables, most fields, most arguments,
    should never be null.

    Nullability like they have in Java is bad because it's everywhere:
    every variable, every field, every argument,
    throughout all code written in that language,
    whether you want it or not.
    In practice, you mostly don't want it.
    Nullable is a really terrible default.

    In Haskell, `Maybe X` is literally a different type from `X`,
    so if you want `Nothing` as a possible value, you have to choose that,
    and it becomes part of the type signature.
    It's opt-in.

*   And, if you do opt in,
    you'll never accidentally write code that tries to use a `Maybe ChessPiece`
    as though it were a `ChessPiece`
    without first doing a null check.
    The type system prevents it.
    You must pattern-match
    in order to get the `ChessPiece` value out of a `Maybe ChessPiece`.

    And when you pattern-match, if you forget to also handle the `Nothing` case,
    the compiler sees that. And it'll warn you about it.

    So there are no `NullPointerException`s in Haskell.


## Example: `Tree`

Can we do one more example?

    data Tree a = Empty | Node (Tree a, a, Tree a)

Here we express the data structure for a binary tree
in one line of code.

A tree is either the empty tree,
or it contains a triple: both a value of type `a`,
and a left tree and a right tree.

This is not some theoretical thing that you *could* do, if you were crazy.
Crack open Okasaki's book, *Purely Functional Data Structures*,
and you'll see he uses algebraic data types for everything.
In fact, he has a tree type
that's essentially identical to this.


## Why "algebraic"?

*(slide: "algebraic" data types, "sum" types)*

Why do we call them *algebraic* data types?

Well, it's because this feature came from academia,
and if you're in computer science academia,
this word is nothing but appealing.

Mathematicians love algebras.
In broad strokes, the idea is this.
An "algebra" is when you have three things:

1.  You have some set of conceptual **things** to do algebra with,
    like say the real numbers.

2.  You define **operations** on those things,
    like in the case of numbers, you have addition, multiplication, and so on.

3.  You write **equations** that show laws that real numbers obey:
    `A + 0 = A`, for example, is a law of addition, true for all *A*.

If you've got those three things, you've got an algebra,
and for some people this is very exciting, I suppose, because you can prove things.

Or to say all this in a few words, an algebra is always
"What if these things were values?
What if we had operators on these things?"

So if you think of data types, could we define operators on types?
Well, yes, we could, because you can think of types as sets of values,
and there *are* operators on sets.

The vertical bar here, for example, looks like an operator:

    data JSON = JNull
              | JBool Bool
              | JNum Float
              | JStr String
              | JArray [JSON]
              | JObj [(String, JSON)]

The set of JSON values is one big set
made by throwing together all these other sets.
So this vertical bar is something like an addition operator.
Hence "sum types".

Another reason is that *the number of different possible values*
in a discriminated union is, quite simply,
the *sum* of the number of different values each constructor can create.
Maybe you can also see why tuples are called "product types".

    data Curry = Red | Green | Panang | Massaman  --  4 curries
    data Stuff = Chicken | Pork | Tofu            --  3 "meats"

    type LunchSpecial = (Curry, Stuff)            -- 12 combinations

*(I'm not super happy with all this.
ISTM the word "algebraic" has another meaning here:
Algebraic data types also encourage a rather mathematical way of thinking about
the concrete types being defined.
An algorithm on a discriminated union is subject to case analysis.
But none of this is the main thrust of the talk.)*


## Recap: What are algebraic data types?

So what are algebraic data types?

They're a programming language feature.
Special syntax for concisely defining types.

Algebraic data types define types where all data is public,
and there's no mutable state.

They complement case-expressions and pattern-matching.

They can define plain old enums.

They can define *discriminated unions,*
that is, types that are either A or B or C,
different possibilities that might include different kinds of fields.


## Why do we care?

So what?

I said algebraic data types are "powerful"
and the lack of them in mainstream languages is "tragic".
How can I back that up?

1.  An ADT does a ton with a little code.

    It defines types, constructors, pattern-matching syntax,
    and Haskell will even autogenerate default implementations
    of things like the `(==)` operator, if you ask for it.

2.  ADTs and pattern matching cooperate
    really, really, *really* smoothly
    to support type safety.
    No downcasting, no `NullPointerException`s. Ever.

    ADTs close a significant type-safety hole in other statically-typed languages!

    Because this concept of a value being maybe one thing, maybe
    another thing? Or maybe a third thing?
    That's *everywhere* in programming, once you start looking for it—
    it subsumes nullability, *just for starters*—
    and implementing something like that in Java or C# or C++
    requires complicated classes
    and causes the type system to throw up its hands.
    `NullPointerException`s and `ClassCastException`s follow.
    Or if you're using C++ `union`s, undefined behavior, which is even worse.

3.  ADTs close a significant expressivity gap between static and dynamic languages!

    They make it possible to throw around values of multiple types
    *almost* like you do for free in Ruby or Clojure or Elixir.
    You want a function that takes "either a function or an integer" as the argument?
    No sweat. Make a one-line ADT with two constructors and get going.

    A single feature both improving type safety *and* doing this is pretty remarkable.

4.  This is the big one though.

    In functional programming, your go-to technique
    is to break things down into functions.
    Wonderful, testable, composable, deterministic functions.

    Like, say you have a timestamp
    and you want to display it approximately.
    You could write one function to do the whole thing.
    Maybe that's how you would do it in Java.

        exactTimeToRoughEnglish t

    In a functional language, you might break that into three parts:

    *   get the current time now;
    *   compute the RoughTime between now and the target timestamp;
    *   convert the RoughTime to English text.

    Only one of those is nondeterministic.
    The other two are separately testable and so on.

    But note that the value returned by step 2,
    and passed to step 3, is this `RoughTime` thing.
    So this factoring is only possible
    because we can define the `RoughTime` type concisely.
    Try to do that in Java,
    and you're gonna have a rough time.

        ADTs = easy types = better code

    **Algebraic data types make it easy
    to spell out the domain and range of functions,**
    which goes a long way toward documenting
    what those functions are supposed to do,
    and even, sometiems, a long way towards implementing them.
    Sometimes, a little pattern matching, and you're almost done already.


## Infinity!

Just as a bonus, I saw this article a while back.

Eric Kidd wrote this back in 2007:

> Sometime back in elementary school, I first asked teachers, "What
> happens when you divide infinity by 2?" Some teachers couldn't answer,
> and others told me, "It's still infinity!"

Eric is right to be skeptical of this answer, don't you agree?

So he decides to tackle this question for real, once and for all, the right way:
ask Haskell.

Haskell wouldn't tell you something if it wasn't so.

> A number is either zero, or the successor of another number. We can write that in Haskell as:
>
>     data Nat = Zero | Succ Nat
>       deriving (Show, Eq, Ord)

That sentence, incidentally, is most of the definition of natural numbers.
Like, for-real mathematicians will tell you that's what numbers are.

(The `deriving` keyword asks Haskell to autogenerate some code for us.
Because we're `deriving Eq`, the `==` operator automatically works on `Nat` values.)

Eric then implements addition on `Nat` values. And so on.
Blah blah blah.

This is where things get interesting:

>     infinity = Succ infinity

And if you want to know more, you can read the post yourself
and follow along in your Haskell REPL.

http://www.randomhacks.net/2007/02/02/divide-infinity-by-2/
