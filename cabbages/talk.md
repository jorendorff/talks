# Wolf, Goat, and Cabbage In Two Styles!!

## Introduction (1'09")

There's a classic story.
Once upon a time there was a farmer named "you",
*(slide: farmer)*
and this farmer went to a fair and bought some cabbages
*(slide: cabbages "SCORE!")*
and a goat
*(slide: goat "MEEHHH")*
and a wolf.
*(slide: wolf)*
You were at the fair, you were in a good mood, you bought a wolf.

*(slide: the travelers at the river)*
Which makes it a real pain to get home,
because your boat can only fit one of the three items.

*(animated gif?)*

Maybe you've heard of this puzzle? Seeing a lot of nods.
What is the right sequence of moves to get all three items to the other side?
without ever leaving the goat and the cabbages together unsupervised,
or the wolf and the goat.

Today I want to show you what this puzzle looks like
in two very unusual programming languages.

*(slide: title)*

My name is Jason,
and I don't think of myself as a programming language hipster,
but I have to admit,
I kind of collect them,
I'm cursed with good taste in programming languages,
and I flew across the country to hook y'all up
with two amazing indie languages
you've probably never heard of.


## Inform 7 (5')
### Inform 7 intro (0'54")

*(slide: "Book One - Inform 7")*

I chose these two languages because they are full of surprises,
We have nine minutes left;
you won't learn two whole languages,
but you will go "WHAT?" like half a dozen times.

Inform 7 is a language for describing small, finite virtual worlds,
made up of rooms and objects in those rooms,
and then running interactive simulations in those worlds.

Also, for some reason, Inform 7 code looks like English.

So you can start an Inform project like this:

    Chapter 1 - The River

    The East Riverbank is a room.

You can also add some documentation.

    The East Riverbank is a room. "Here a lazy river crosses your path."

We're saying, OK, new room, it's called "the East Riverbank".
Inform knows that a room is a particular type of object: a place.

    Chapter 2 - The Boat

    A boat is an enterable container in the East Riverbank. "A boat is tied
    to the dock here."

Inform knows what "enterable" and "container" mean,
so here we're defining another object called "the boat",
and telling Inform what type it is and where it is.

There is a sort of class hierarchy in Inform; we can define types like this:

    Chapter 3 - The Treasures

    A treasure is a kind of thing.

And then if we define a wolf, and some other things,

    A wolf is in the East Riverbank. [...]

and then we say:

    The wolf, the goat, and the cabbages are treasures.

that means... well, it means exactly what it says.
They're treasures. Why am I explaining English to you?

### Deep English (0'58")

Now, if you've kicked around for a while,
you know some other programming languages that have this vibe
where they look sort of like English.

Here are a few examples. I'm not going to dwell on them.

    COBOL (1959):
        DIVIDE FORCE BY MASS GIVING ACC.

    SQL (1986):
        SELECT title FROM Book
          WHERE author = 'Poe, Edgar Allan'

    AppleScript (1993):
        tell application "Preview" to open "manual.pdf"
        activate application "Preview"

    Gherkin (2008):
        Given a book of macabre poetry is in my cart
        When I click "Buy"
        Then I should see "Checkout"

What these all have in common is that they're not fooling anyone.
You can tell it's code. Every word is a different stinking color!
They use verbs for commands, and that's the extent of the illusion.
Oh, in places where normal programming langauges use punctuation,
these languages use words instead.
Is this helping? No.

Well, Inform 7 isn't fooling anyone either.
But it does take English grammar more seriously.
It maps interesting bits of English to interesting programming concepts.
So learning Inform means seeing both programming and English
from a different viewpoint.
English is more than just action verbs.
And so are programs.

*(slide: previous inform slide)*

Inform knows that the word *is* has a few meanings,
and you can use it to specify relationships between objects, locations, and types.
It knows that adjectives indicate properties of things,
and you can use *is* to attach an adjective to a noun.
For the purpose of describing places and things,
it's all just very natural.

OK, more on this later. I have to spring something on you.


### The Sting (0'35")

*(slide: Inform 7 IDE screenshot)*

One of the weird things Inform and Alloy have in common
is that they both come with an IDE
that I grudgingly respect.
I kinda dislike IDEs,
like I said, bit of a hipster. Anyway.

Inform has this big friendly "Play" button in the corner.
Let's press it.

    Crossing
    An Interactive Fiction by Jason Orendorff
    Release 1 / Serial number 200218 / Inform 7 build 6M62 (I6/v6.34 lib 6/12N) SD

    East Riverbank
    Here a lazy river crosses your path.

    A boat is tied to the dock here.

    The "sheep" you bought at the fair is here.

    Your goat stands nearby, chewing on nothing in particular.

    >

The prompt here awaits your command.

    >drop the cabbages
    Dropped.

    >take the goat
    Taken.

That's right, Inform 7 is a programming language
for writing interactive fiction. (!)


### Rules (0'53")

Inform has a system of rules for handling user commands like these.
You can write:

    Instead of taking the boat, say "There's no point carrying a boat around."

This is called a rule.

Inform has an execution model that is not quite like anything else.

It starts out a little like React, if you've used that:
when the user types “pick up the boat”,
React first creates an object called an action,
that represents the user intent.

Then it runs the action through a bunch of rules
to decide how to respond.
First it tests rules like this one that are specified by your program,
and if the current action is "taking the boat”,
it stops and prints this message instead.

In addition, Inform has the Standard Rules,
which are kind of like a standard library for common sense.
It contains such wonders as
the "can't take scenery rule",

    >pick up the river
    That's hardly portable.

the "can't take what's already taken rule".

    >take the sack of cabbages
    You already have that.

and the "can't take yourself rule",

    >pick myself up
    You are always self-possessed.

I'm disappointed in everyone who laughed at that joke.


### Crossing (1'15")

One more example to close us out.
My little cabbage puzzle game contains a custom action called "crossing",
which means rowing the boat across the river.

Here's the rule that actually performs this action.

    Carry out crossing:
        if the wolf and the goat are ashore together:
            say "...";
            end the story saying "Someone has got your goat";

Har har, someone has got your goat.
Then imagine a similar if clause for the goat and the cabbages,
which doesn't fit on the slide:

        else if the goat and the cabbages ...:
            ...

And otherwise,

        otherwise:
            move the boat to the other bank.

As you can see, once a rule hits, the body of the rule is kind of like Python.
You've got if statements and colons and indentation.
Yeah, there's a boring normal programming language in here after all.
Surprise!

But this programming model also reminds me a little bit of CSS:
the first line here acts like a selector,
and Inform has a system for deciding whether a rule applies,
and there are a bunch of built-in rules which you can override,
and when multiple rules match there's a system to decide which ones take precedence.

And yeah, when you want a rule to apply, but for some reason it doesn't,
it feels like CSS.
Little bit frustrating.

Still, overall, Inform is brilliant.
The amount of work and love and innovation that went into it is mind-boggling.
Check it out.
And, if you'd like to play *this* game or read the source,
I'll post that link at the end.


### Postscripts (0'27")

Two last surprises about Inform which I can't resist including:

*   **The manual is amazing**

    The documentation is the best time you will ever have reading a software manual.
    It's witty, it's charming, it's full of wonderful examples.

*   **“Use the serial comma.”**

    And, if you take one thing away from this talk, remember that
    Inform has syntax for enabling the Oxford comma,
    which is the nerdiest feature of any programming language ever.


## Alloy (8')
### Alloy intro (1'13")
*(slide: "Book Two - Alloy")*

Alloy is a little different.
It looks more like a programming language.
It has classes. You can say

    class Person {
        loves: set Person
    }

Each `Person` has a field named `loves`, which is a set of people.

except that Alloy is a little too cool for classes,
*(slide: Drake shunning `class`)*
so they're called *signatures*:

    sig Person {
        loves: set Person
    }

*(slide: Drake satisfied with `sig`)*

Also, there is no `new` operator in Alloy.
You can't directly create Person objects,
because Alloy creates all objects for you.
You describe the world you want to see,
one where there are people,
and there is love,
and then you push the button and Alloy creates that world for you.
Or many worlds.

We "run" this model for 3

    run {} for 3

to see worlds containing up to 3 people.

*(slide: Execute)*

Push the button... out come worlds:

*   (one Person who loves themselves)

    Alloy draws these graphs for you.

*   (one Person who does not love themselves)

*   (Person1 loves {Person1, Person0}; Person0 doesn't love anyone)

We can keep clicking and see a bunch of little stories.

Now if I change this:

    run {} for 3

to say this:

    run {} for exactly 15 Person

then what?

*(slide: chaos)*

High school all over again.

Typically things don't get this complicated,
but I just wanted to make sure you see the very basic thing
that Alloy does.
It invents worlds.


### Relations in Alloy (1'23")

We could, of course, show the same data using a table with two columns:

    Table of loves

    Person A  loves  Person B

    Balin      -->    Dwalin
    Óin        -->    Glóin
    Bombur     -->    Balin
    Bombur     -->    Glóin
    Bombur     -->    Bombur

(The field we defined is a `set`,
so one `Person` can have multiple `loves`,
like Bombur here.)

Tables with two columns, like this one,
are the same thing as fields on objects...

    Person.loves

    Balin .loves =  { Dwalin }
    Óin   .loves =  { Glóin }
    Bombur.loves =  { Balin,
                      Glóin,
                      Bombur }

and the same thing as graphs with arrows.
*(slide)*

This is called a *relation*
and Alloy is *all about* them.

Surprisingly, Inform is, too.
Both languages go deep on relations.

*(slide)*

In Alloy, you write `sig Person { loves: set Person }`;
in Inform you say "Love relates various people to various people."
It means exactly the same thing.
And then you define a verb: "The verb to love means the love relation."
In school you learned that verbs are actions: kick, jump, run, swim.
But Inform knows that many English verbs express relationships,
verbs like love, and it can handle both kinds of verb.

As a result, you can write some pretty amazing ideas very simply:

*   Inform 7: "If Bombur loves anyone..."
    Alloy: `some Bombur.loves ...`

*   Inform 7: "everyone loved by Bombur"
    Alloy: `Bombur.loves`

*   Inform 7: "everyone who loves Bombur"
    Alloy: `Bombur.~loves`

*   Inform 7: "Everyone loves Bombur."
    Alloy: `Bombur.~loves = Person`

I don't have time to explain them all, but the point is,
English has some powerful relational calculus built into it,
and it’s pretty awesome that Inform has it too.

And, in fact, the Standard Rules of Inform begin with
a long list of relations that underpin the simulation:

    Part SR1 - The Physical World Model

    The verb to contain means the containment relation.
    The verb to be in means the reversed containment relation.

    The verb to carry means the carrying relation.
    The verb to hold means the holding relation.
    The verb to wear means the wearing relation.

This definition of "to carry" is why I can say
"The player is carrying a sack of cabbages,"
and Inform understands.


### Battle royale (1'06")

But back to our love example.
You know, we're not here to make friends.
We're here to tell a story about four things, call them Objects,

    sig Object {
        loves: set Object
    }

and instead of loving each other, the deal is they want to eat each other:

    sig Object {
        eats: set Object
    }

And here they all are:

    sig Wolf extends Object {}
    sig Goat extends Object {}
    sig Cabbages extends Object {}
    sig Boat extends Object {}

We have to tell Alloy that there's just one of each:

    abstract sig Object {
        eats: set Object
    }

    one sig Wolf extends Object {}
    one sig Goat extends Object {}
    one sig Cabbages extends Object {}
    one sig Boat extends Object {}

Now, when we push the button, what's going to happen? *(short pause)*

Now Alloy is going to create food webs, like this, *(pictures)*
it's just a battle royale of cannibalism...
You know, they *say* goats will eat anything, but I've never seen a goat try to eat itself...

Well, if we don't want Alloy to get creative,
we need to tell Alloy what we actually want.
And we do that using *facts*.

    fact foodWeb {
        // only certain animals want to eat certain food
        eats = (Wolf -> Goat) + (Goat -> Cabbages)
    }

This fact says, Alloy, I’m going to tell you exactly what this “eats”
relation contains. Wolf eats Goat. Goat eats Cabbages. That’s all.

And now *(slide)* we just get the one picture.

### Time (1'19")

Now the interesting part.
This puzzle is about getting across the river, which is something that unfolds in space and time.

The space part is easy:

    sig Riverbank {}

There's such a thing as a riverbank.
But what about time?

*(blank slide)*

In most languages, things happen in a certain order.
Or, things at least happen.
In Alloy, the existence of time is a library feature that you have to import.

And the way it works is pretty weird.
We have to declare something that I’m going to call a `Snapshot`.

    sig Snapshot {

    }

See, once we have time in our model,
Alloy isn’t just going to generate pictures.
It’s going to kind of make a movie for us.
A Snapshot is one frame in this movie.
And what's in a snapshot?
Well, anything we want; but the only thing we need to track
is where things are:

    sig Snapshot {
        location: Object -> one Riverbank
    }

So, each Snapshot has a field that associates each `Object`
with the one riverbank where it’s at.

That arrow means relation; and it also shows up quite literally
as an arrow pointing from each Object to one Riverbank in the graph.

    // first, last, prev, next
    open util/ordering[Snapshot]

    sig Snapshot {
        location: Object -> one Riverbank
    }

Now we open the ordering module.
This module gives us a few variables.
`first` is the first Snapshot in the movie.
`last` is the last Snapshot.
`prev` and `next` are relations between Snapshots.
And there are some facts in this module that say, Snapshots are totally ordered.
Time is linear.

That arrow means relation; and it also shows up quite literally as an arrow in the graph.
*(slide: a picture)*

What can Alloy show us now?

*(slide)*
Well, this picture is a bit of a mess,
but I can ask Alloy to cut this giant graph into slices,
one slice per Snapshot, and show me those instead.
*(Click "Projection: none" and check "Snapshot")*


### Rulefinding (2'42")

*(slide: anomaly 1)*

Now, at the bottom, you see there’s now a control
to click through the sequence of Snapshots.
Basically a `prev` button and a `next` button.
And, now Alloy is showing the `location` relation,
from Objects to Riverbanks, just like we said.
But we notice something funny.
There’s only one Riverbank.
Most rivers have two banks.
It’s a Möbius river?!

I've even seen Alloy show a story where the river has three banks.
Which is clever, right?! That makes the puzzle a lot easier.
Go Alloy! Thinking outside the box!


But no, we should probably fix this, by stating another fact.

    fact twoSidesToEveryRiver {
        #Riverbank = 2
    }

The number of riverbanks is 2.

*(slide: anomaly 2)*

There we go! That's better.
Except the goat is starting out on the other side of the river.
What is it doing over there?
We need to add a fact that says,

    fact beginningAndEnding {
        one first.location[Object]  // one start
        one last.location[Object]   // one finish
        first.location[Boat] != last.location[Boat]  // they are different
    }

*(first line)* there's one bank that's the first location of all Objects;
*(second line)* and one bank that's the last location of all Objects;
*(third line)* and they're different banks.

*(slide: all four objects on Riverbank1)*
And now, sure enough, all four objects start out on one riverbank
*(slide: all four objects on Riverbank2)*
and edn on the other.

You can see how we have to tell Alloy every little thing.
I said earlier how Inform has a bunch of common sense rules in its standard library.
Yeah, Alloy doesn't have any of that.
What else are we missing?
Well, maybe you can figure out some of the missing rules yourself.
We haven’t written any rules for movement yet,
so Alloy will show you solutions like this where everybody rows across at once.
There are a few other bits missing, too.
All in all the solution is about 40 lines of code.
And it does work!

*(I had to cut the final demo for time, which is kind of awful:)*

If we had thought very carefully about everything,
we might have been able to write all this without driving into the guardrails the whole way,
but that is not an experience I have had yet with Alloy.
But hey, check it out: we got there!
*(slide)* Here's the starting snapshot,
and we can click this button to see the next snapshot—so, spoilers! if you
are not familiar with this puzzle,
and you don't want to see the answer, look away!

*(show all 8 steps)*


### Why Alloy? (0'26")

What is Alloy for?

It's not for solving old logic puzzles.

The idea with Alloy is that when you're designing a complex system,
you pick some aspect of the system that's interesting,
you make an Alloy model of it,
and then you can tell Alloy,
"this is broken if all threads get blocked"
or "this is broken if the refcount goes below zero"
or "this is broken if two different servers give different answers"
and then say `run broken for 10` and, if it's broken,
Alloy shows you a picture of the exact test case that breaks your design.
Pretty cool.

You do have to have a program that's complicated enough that the design isn't obviously correct,
but simple enough that you can reasonably build an Alloy model of it.
So, is this useful in the real world, I don't know. Maybe?


## Conclusion (1'15")

Why am I even here talking about this?

I love weird programming languages,
I love having to think in weird ways.
But what I love best is when a weird language is trying to do something,
it has a mission that explains why it's like that.
I aspire to be that kind of person myself.

So far I'm just weird.

I love that Inform is a huge language,
with a 27-chapter manual and a rich set of Standard Rules,
*because* English is a *really good* language for talking about
rooms and people and everyday things.

I love that Alloy reduces fields, and data structures, and time
to a single unifying idea, the relation,
**because** then it can use powerful logical analysis tools
to find bugs in software before it’s built.

These languages surprised me.

Languages like this remind me that there are whole other kinds of programming.
There's more out there.
There is more delight left in programming.
There are more surprises waiting to be discovered.
Some days I need that reminder.
Thank you.
