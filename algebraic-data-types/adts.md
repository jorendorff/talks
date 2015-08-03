# Algebraic Data Types (with examples in Haskell)

*(I gave this mini-talk at NashFP in July 2015.)*


## Motivation

Algebraic data types are boring, and this talk would boring,
except that algebraic data types are also very practical.
They are everywhere in the languages that have them,
and bloated, error-prone code is everywhere in the languages
that don't have them.

> .@lojikil @andywingo surprising how much computer stuff makes sense
> viewed as tragic deprivation of sum types (cf. deprivation of lambdas)

https://twitter.com/graydon_pub/status/555046888714416128

This quote is from Graydon Hoare,
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

I'm going to show examples in Haskell,
because that's just a super easy default choice.
I think this feature came from ML,
and it's in every statically typed functional language in the ML lineage,
which includes OCaml, F#, Elm, and others.

    data Bool = False | True

This one line of code declares three things.

`Bool` is a type.

`False` and `True` are called "constructors".
The terminology is a little different from object-oriented languages.
These are not functions.
They're not special methods or anything like that.
They are values of type `Bool`.

Type names and constructor names have to be uppercase in Haskell,
because of reasons.

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

And that's algebraic data types, pretty much.


## Example: `Maybe`

I want to show off another feature here.

Check out this [tweet from Dave Herman](https://twitter.com/littlecalculist/status/563590067445194753):

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

*(slide: highlight "Option&lt;T&gt;")*

Well, what you need is what's called the option type in languages like ML.
And different languages have different syntax, but
you might write it like Dave did: `Option<T>`.
That's how it's written in Rust.

In Haskell, we write `Maybe a`.
Just like Haskell eliminates the parentheses around the parameters you pass function calls,
it also eliminates the angle brackets in parameterized types.

And instead of `Option`, Haskell uses the word `Maybe` for this type.
Maybe there's a value there. Maybe not.

And how is this defined? It's quite simple:

    data Maybe a = Nothing | Just a

Again, we're declaring three things here:
`Maybe` is a type; `Nothing` and `Just` are the constructors.

A value of type `Maybe ChessPiece` is either `Nothing`, or `Just` a `ChessPiece`.

Are there any advantages of having a `Maybe` type in your language,
instead of just everything being nullable all the time?

One advantage is that in practice,
most variables, most fields, most arguments,
should never be null.
Nullability like they have in Java is bad because it's everywhere:
every variable, every field, every argument,
throughout all code written in that language,
whether you want it or not.
In practice, you mostly don't want it.
The default should be non-nullability.

In Haskell, `Maybe X` is literally a different type from `X`,
so if you want `Nothing` as a possible value, you have to choose that,
and it becomes part of the type signature.
It's opt-in.

The other, more important advantage is that if you do opt in,
you will never accidentally write code that tries to use a `Maybe ChessPiece`
as though it were a `ChessPiece`,
without first doing a null check.
The type system prevents it.
You must pattern-match
in order to get the `ChessPiece` value out of a `Maybe ChessPiece`.

So there are no `NullPointerExceptions` in Haskell.


## Example: `Tree`

One more example, just to show you how powerful this feature is.
You can really express a lot with a line of code.

    data Tree a = Empty | Node (Tree a, a, Tree a)

Here we express the data structure for a binary tree
in one line of code.

This is not some theoretical thing that you *could* do, if you were crazy.
Crack open Okasaki's book, *Purely Functional Data Structures*,
and you'll see he uses algebraic data types for everything.
In fact, he has a tree type
that's essentially identical to this.


## Why "algebraic"?

*(slide: "'algebraic' data types", "'sum' types")*

OK, so just a word or two about this terminology.

Why do we call them *algebraic* data types?

Well, it's because this feature came from academia,
and if you're in computer science academia,
this word is nothing but appealing.

The notion of "algebras", plural, being a thing in computing,
is not something I'm going to completely explain in the next 30 seconds.
But in broad strokes, the idea is this.
An "algebra" is when have three things:

1.  You have some set of conceptual **things** to do algebra with,
    like say the real numbers.

2.  You define **operations** on those things,
    like in the case of numbers, you have addition, multiplication, and so on.

3.  You write **equations** that show laws that real numbers obey:
    `A + 0 = A`, for example, is a law of addition, true for all *A*.

If you've got those three things, you've got an algebra,
and for some people this is very exciting, I suppose, because you can prove things.

Or to say all this in a few words, an algebra is always
"What if we had operators on these things?"

So if you think of data types, could we define operators on types?
Well, yes, we could, because you can think of types as sets of values,
and there *are* operators on sets.

The vertical bar here, for example, strongly resembles an operator:

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

*(I'm not super happy with this.
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

This concept is everywhere in programming--
it subsumes nullability, for starters--
and implementing something like it in Java or C# or C++
requires complicated classes
and causes the type system to throw up its hands.
`NullPointerException`s and undefined behavior naturally follow.


## Why do we care?

Why is this useful?

Let me give you three reasons.

1.  An ADT does so much with so little code!

    It defines types, constructors, pattern-matching syntax,
    and Haskell will even autogenerate default implementations
    of things like the `(==)` operator, if you ask for it.

2.  ADTs and pattern matching cooperate
    really, really, *really* smoothly
    to maintain type safety.
    You can have `Maybe` variables in Haskell
    without the possibility of `NullPointerException`s.

3.  This is the big one though.

    In functional programming, your go-to technique
    is to break things down into functions.
    Wonderful, testable, composable, deterministic functions.

    Like, say you have a timestamp
    and you want to display it approximately.
    You could write one function to do the whole thing.

        exactTimeToRoughEnglish

    In a functional language you might break that in two:

        exactToRoughTime |> toEnglish

    Now both parts are separately testable and so on.

    But note that the value returned by `exactToRoughTime`
    and passed to `toEnglish` is this `RoughTime` thing.
    So this factoring is only possible
    because we can define `RoughTime` without much effort.
    Try to do that in Java,
    and you're gonna have a rough time.

        ADTs = easy types

    **Algebraic data types make it easy
    to spell out the domain and range of functions,**
    which goes a long way toward documenting
    what those functions are supposed to do,
    and even, sometiems, a long way towards implementing them.
    Sometimes, a little pattern matching, and you're almost done already.


## One more thing

Just as a bonus, I saw this article a while back.

Erik Kidd wrote this back in 2007:

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

He then defines a function that performs addition on `Nat` values. And so on.

But this is where things get interesting:

>     infinity = Succ infinity

And if you want to know more, you can read the post yourself
and follow along in your Haskell REPL.

http://www.randomhacks.net/2007/02/02/divide-infinity-by-2/
