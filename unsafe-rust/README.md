# Building on an unsafe foundation: What "unsafe" means in Rust and how to deal with that

*(first given at Rust Belt Rust, 27 Oct 2017)*

## Intro

Thank you.

I'm really glad to be here in Columbus.
Anyone else here from out of town?

I'm a Columbus fan because this is where Jeni's Ice Creams got started.

*(slide: Jeni's)*

*(scattered shouts of appreciation from audience)*

Did you hear that? The locals know.
So, check that out. The Brambleberry Crisp is good stuff.

*(slide: arts, nightlife, books)*

Columbus has a lot going on.
Arts, nightlife,
there's a killer indie bookstore...

*(slide: topiary park)*

There's also Topiary Park. Right around the corner actually.
Free Instagram likes, just sitting there.

*(slide: [Drainage Hall of Fame](https://www.tripadvisor.com/Attraction_Review-g50226-d209200-Reviews-Drainage_Hall_of_Fame-Columbus_Ohio.html#photos;geo=50226&detail=209200&aggregationId=101))*

The Drainage Hall of Fame is here, big tourist attraction.

*(slide: [Ironwood Wolves](http://www.ironwoodwolves.com/index.html) http://www.ironwoodwolves.com/uploads/2/3/1/7/23176402/untitled-1.png?1400)*

If you're up for a little drive, there's a wolf sanctuary
where you can meet live "ambassador wolves", that's what they call them,
because wolves are nature's diplomats...

*(slide: Cornhenge)*

Cornhenge is here.
I feel like Jimmy Fallon.
"We've got a great show for you tonight, folks. Cornhenge is here!"

*(slide: Ohio Stadium)*

They also play a little football, is that right? That's what I heard.

So I bring up football because
during the formative years when I was still capable of learning the names of cities,
I only learned the ones that had pro sports teams.
Because, I grew up in suburbia, in the Eighties.

*(slide: Cleveland Browns and Cincinnati Bengals circa 1987)*

So I knew Cleveland and Cincinnati were big American cities,
right up there with New York and, uh, Green Bay...

I even knew what these cities looked like on Monday night, from a blimp.

*(slide: overhead view of Cincinnati)*

But not Columbus,
even though all three cities are actually the same size.

*(slide: bar graph of Ohio cities)*

The deal is, Columbus had Ohio State, so they never had any use for the NFL,
and in fact to this day most people here have never heard of it.

*(slide: [JAMA paper](https://jamanetwork.com/journals/jama/article-abstract/2645104))*

The NFL has an even bigger problem than that, though.
It's actually very serious.
This study was published in July of this year.
Researchers studied the brains of 111 former NFL players,
and found evidence of brain damage in 110 of them.
It was a sample selected by those players' surviving relatives,
so, probably skewed,
but still.
If I had to guess, based on the NFL's actions on this issue,
I would guess that they don't think better equipment or rules changes or schedule changes
are going to make this go away.
They're acting like they don't think anything will help.
And they may be right.

*(slide: blank)*

So now what? We always knew a career in the NFL was risky, it's hard on the body,
and injuries happen all the time.
but this is different.
It's beginning to look like a career in the NFL is just a bad idea,
if you value your brain.
As a longtime NFL fan, ...I don't know.
On the one hand, football.
On the other hand, I don't want people burning up their brains for my entertainment.

You probably want to hear about Rust...
I just like to start every talk with a lengthy non sequitur,
something nice and heavy...

But enough about serious dangers being ignored.
Let's talk about C++.


## Part 1 - C++ and undefined behavior

*(slide: "1. I'm fuzzy on this whole good/bad thing (or, C++)")*

<https://www.youtube.com/watch?v=wyKQe_i9yyo>

It sounds like we might have some C++ users in the house.
Quick show of hands: how many of you have used C or C++ professionally?

Look around you.
These people with their hands up,
these people have seen some things, OK?
They know how the sausage gets made.
They know that all software is built on top of a giant pile of sausages,
and that knowledge haunts them.

Let me try to convey just a little bit of what C++ did to these poor people, OK?

*(slide: unsafe operations in C++, 1/n)*

THREAD.


### Unsafe operations in C++

C++ is a statically typed language,
which means the compiler catches all kinds of simple mistakes,
like if you misspell a method name.
But there are still a few ways that a C++ program can go wrong at run time.
For example, if you declare a variable, let's say a nice integer:

    int count;

and then you print the value of that integer,
which for some reason in C++ looks like this:

    cout << count << endl;

This is terrible. A calamity.
You forgot to initialize the variable.
Now if you've never used C++,
right now you are thinking, oh no, C++ will throw an exception here, that's very sad.
Or maybe it will print zero.
Or maybe it will print some random number,
because it's printing the value of an int that we never assigned to.
Well, *(elaborate shrug)* it might.
C++ might do any of these things... or all of them...
because this is what's called undefined behavior.
And when a C++ program triggers undefined behavior,
the Standard says that it may do literally anything.

In practice what that means is, the compiler generates some machine code for this,
and it just assumes that you would never do anything so stupid as to forget to initialize a variable.
Yeah, the compiler thinks very highly of you.

So what happens when you do forget?
Well, whatever. The compiler writers don't care.
That machine code just runs, and it does whatever.

What could possibly go wrong?
Well, let me tell you. We'll have a slide on that later.

*(slide: unsafe operations in C++, 2/)*

First let me show a couple more examples of the kind of C++ code
that can trigger undefined behavior,
because there's more than one kind.
Say you have a counter.

    int count = 0;

See, I remembered to initialize it this time.

But now I'm about to do something stupid,
I'm going to add up some numbers.

    for (int num : numbers) {
        count += num;
    }

This works fine,
unless the total gets too big to fit in an `int`.
Then, guess what?
Undefined behavior.

Well, you know, math is tough. Say we just want to do something nice and simple,

*(slide: unsafe operations in C++, 3/)*

...like pass an argument to a function.

    string hello_str = "hello>";

    set_prompt(hello_str);

This... looks fine.
Yeah, this code is probably fine.
I mean,
*(back to previous slide)*
this code is clearly nuts, but this?
*(forward to `set_prompt` slide)*
This is safe.

*...unless...*

...the function takes that `string` by reference.
Then it might store a reference to the string somewhere,
and it might expect the string to still be there later,
like when it needs to print a prompt.
In a language with garbage collection, that would be fine,
but in C++, once that variable goes out of scope, the string is really truly gone.
So what happens later when we try to print the prompt?
Undefined behavior.

This example is tricky, because whose bug is this?
It's my bug. I'm calling the function incorrectly.
But where is the information I would need to understand that this is wrong?
It's in the documentation, which I skimmed.

You may say I'm a skimmer... but I'm not the only one.

*(slide: unsafe operations in C++, 4-15/)*

There are a few other ways to get undefined behavior.
And I'm just going to go through these quickly,
because life is short...

    int x;   <--- uninitialized
    count += num;  <--- signed int overflow
    set_prompt(hello_str);  <--- dangling ref
    delete ptr;  <--- double free
    ptr->method(); <-- use after free
    obj.field = &variable; <--- dangling ptr
    this  <--- always a raw ptr
    bottles_of_beer[100]  <--- out of bounds
    obj1 = obj2;  <--- so many pitfalls
    int i = pow(2, 39);  <--- float-to-int overflow
    Shape& ref = *shape;  <--- null reference
    for (auto v: vec) {
      if (v) vec.push_back(v/2); <--- iterator invalidation
    }
    ...threads, exceptions, one-definition rule...

Sometimes people claim that smart pointers make C++ safe,
like "solved!", I don't really understand this impulse.
But `this` is always a dumb pointer, so like...

Out of bounds array accesses are undefined behavior in C++.

Assigning one object to another can go wrong in a lot of ways I don't have time to get into.
Et cetera.

Threads and exceptions have their own pitfalls
and actually those are especially hard to get right.

So yes, some of these are mistakes that you could make in any language.
But reading off the end of an array in Java,
or using a variable you never initialized in Python,
causes an exception.
You can't miss it. Your program dies.
You get a stack trace. It tells you what line number your bug is on.
The developer experience in C++ is a little different.
Your program just keeps on going.
It might even work beautifully, on your machine.
Undefined behavior lurks.

Yeah, it's great.

It is possible to write a correct program in C++.
Each feature of the language has rules for its use.
You just have to keep these rules in mind, and don't make mistakes.
Break one rule, and the consequences are bounded only by the limits of what your process can do.


### Undefined behavior in practice

*(slide: "Undefined behavior: consequences" on Spengler)*

So, don't do undefined behavior, kids. It would be bad.

Maybe you're thinking,
"I'm fuzzy on the whole good/bad thing. What do you mean, 'bad'?"

Well, it turns out to be unreasonably bad.
Here's the deal.

When your program has undefined behavior,

*(ticking off on fingers)*

*   Sometimes it crashes and dies. That's the good case.
    It's kind of like an exception.
    You'll notice it, and it's pretty easy to track down.

*   Sometimes some memory gets overwritten,
    or uninitialized memory is treated as data,
    and your program keeps running.
    It'll crash later. Or behave funny. Maybe.
    It may never bite, in which case, is it really a bug?

And then there's the bad case.
While a program with undefined behavior is obviously unreliable,

*(slide: "too unpredictable for programmers")*

it's still a program.
It's still a sequence of CPU instructions.
And unscrupulous people can study those instructions
and figure out what your program is going to do after it goes off the rails.

*(slide: + "predictable enough for attackers")*

Programs with undefined behavior are very often predictable enough to be exploitable.
Attackers use undefined behavior to take over servers and browsers.


## Part 2 - You don't understand safety

*(slide: "2. It's dangerous to go alone (or, "Safety")")*

OK, so this concludes our crash course in C++.

See what I did there? "Crash course"?

Why are we rehashing all this?
Well, we all know Rust is a safe language;
it says so right here on the label.

*(slide: the trifecta quote)*

If you know nothing else about Rust, you know you're being protected from *something*.
From what, it's not always clear.
Yourself, maybe.

*(slide: [it's dangerous to go alone](https://images.rapgenius.com/3001f37c67fcca9d037dbed83625f4e5.500x344x1.png))*

It's funny, in other contexts, it's obvious what "safe" means.
Say you're a kid hero and an old man tells you,
"It's dangerous to go alone. Take this."
You don't need to ask what he means by "dangerous".
The fact that he's giving you a *sword* kind of answers that question.

    What dangers?
    X   unmaintained roads
    X   moral quandaries
    X   awkward conversations
    !   monsters

It's the monsters.

*(blank slide)*

But if someone tells you, hey, it's dangerous out there, take this,
and hands you... moves and ownership and references and a borrow checker,
you might be perplexed.

Rust's notion of "safety" is best understood as a response to C++.
It's keeping you safe from, above all, undefined behavior.
And some other things.
But mostly its the undefined behavior.

See, we've always known writing a bunch of C++ is risky.
It's painstaking work, programmers make mistakes.
But now that we're a couple decades into this Internet thing,
now that we're seeing the consequences,
it's beginning to look like writing a bunch of C++ is just a bad idea.

We want a language that is as fast as C++, but without the monsters.
Wouldn't that be great?

Well, funny story...


### Unsafe code in Rust

Have you used unsafe code in Rust?

No. OK. So let me explain what unsafe code is.

> Unsafe code is code where mistakes can lead to undefined behavior.
>
> In Rust, unsafe code is always marked with the `unsafe` keyword.

Now this leads to a question—

*(slide: Yzma + crocodile)*

https://i.pinimg.com/736x/c7/4f/18/c74f18b6c9badec046f645f029830350--emperors-new-groove-funny-disney.jpg

Why do we even have that lever?
In a language designed from scratch for reliability,
why on earth would you allow undefined behavior?

For that matter, why does C++ allow it?
Why is this a thing at all?
Crashing is bad, right?
So, like... *well??*

This is something we have not done a good enough job of explaining, I think.
So I'm going to take a couple of slides to try and explain it.

Let's start by looking at a little source code.

*(slide: `Vec` source code, with two regions covered by rectangles)*

    impl<T> Vec<T> {
        ...
        pub fn push(&mut self, value: T) {
            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
            YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
            YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
            YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
            YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
        }
        ...
    }

This is the `push` method of Rust's `Vec` type.
This of course is an example of a *safe* method.
Pushing a value onto a vector is a totally normal thing we do all the time.
And what you're about to see is the real source code from Rust's standard library.
So how does this work?

*(slide: reveal first region)*

            if self.len == self.buf.cap() {
                self.buf.double();
            }

Well, first we check to make sure there is room in the vector for another element.
If it's already full, we have to call this `.double()` method to double the size.
And then,

            unsafe {
                let end = self.as_mut_ptr().offset(self.len as isize);
                ptr::write(end, value);
                self.len += 1;
            }

*AAAUGH!* Unsafe code!
Raw pointers!
Pointer arithmetic!
Writing to uninitialized memory!
And then to top it off, we mess with the value of this private field,
which is critical to the correctness of unsafe code elsewhere.

Oh emm gee, y'all.

How can this code be considered safe?

Is— Wait a minute.
Is this sort of thing going on anywhere else in Rust's standard library?
What do you think?

*(slide: scrolling grep output)*

Yep.

Well, Rust is not alone.
Think about it — what's a safe programming language?
Java? What language is the JVM written in?
It's a quarter million lines of C++.
Do you think the JVM's implementation of arrays is safe and free of pointer arithmetic?
Python? Half a million lines of C.
Here's Ruby's `Array#push` method.
[It's written in C.](https://ruby-doc.org/core-2.2.0/Array.html#method-i-3C-3C)
Well, what about a language designed by smart people?
Haskell—well, now, we all know Haskell is special—Haskell has a runtime system,
actually written in Haskell, right?
Lol, no. It's 80,000 lines of C.

Underpinning every safe programming language, library, or virtual machine
is a whole lot of unsafe code.

And that's not even all of it.
Because *all* of our programs run on some operating system,
Linux, Windows, Mac OS, all written in C.
Filesystems, network drivers, all C.

*(slide: castle in the sky)*

When we imagine safe languages as cozy and secure from the ground up,
we are pretending all this support code isn't there.
It's a bit of a fairy tale.

*(slide: orthanc)*

The reality is more like Saruman's tower, in Lord of the Rings.
You look at the actual tower, and you think, ok,
this is nice.
It's clearly designed to be pretty robust.
But the basement is a maze of goblin warrens,
with building code violations all over the place.

This is where we're at in software today,
even in safe languages. Even in Rust.
And that's what this talk is about.

*(slide: title)*

You made it to the title slide, congratulations.

Why is it like this?
Why is there unsafe code under every rock?
And that being the case, how safe are we, really?
Is there any point in adopting a so-called safe language?
Should we all give up and become goatherds?
How do we engineer safety in unsafe code?


## Part 3 - Writing unsafe Rust: why and how

*(slide: Why we have that lever)*

So that's kind of a lot of questions,
To start, let me try to explain why we have that lever.

There are two basic reasons Rust allows unsafe code.

    * Speed

One, sometimes the safest thing is too slow.
Sometimes the safest thing is just to check everything at run time,
to repeat a bound check,
to repeat a lookup to make sure the value is still there;
and the end of that road is Python performance.

Sometimes in a Rust program,
you the programmer are quite sure the value is still there or whatever,
and in those cases you can sometimes just write a little unsafe code and then it's fast.

Two, sometimes we need to break Rust's safety assumptions.

I said earlier that Rust is designed to prevent undefined behavior.
Those little arguments you get into with the borrow checker?
That's because Rust wants proof your program isn't going to trigger undefined behavior.
The type system, moves, borrows, lifetimes—all of that is part of this proof Rust is building.

But that system, and all those rules, it's kind of designed for normal code, not super weird code.
And some things your program needs to do
can't be done in safe Rust,
because they don't fit in with Rust's safety proof system.
They break some of the system's assumptions.

What assumptions?

*(slide: Rust's big untrue safety assumptions)*

I can think of two big ones.

1.  All code is Rust.

    Rust can prove safety right up to the edges of all the Rust code in your program,
    but approximately all programs use some non-Rust code.
    Say we're importing something like OpenGL.
    This is a ton of C code that we're just going to plunk right into our process,
    and we're going to call these C functions,
    and we assume they're correct.
    And it's not just OpenGL.
    The C standard library is the same thing: just a ton of C code,
    and it's loaded into *every* Rust program at startup.
    (Maybe you can opt out. I've honestly never tried.)

    So from Rust's perspective, these calls into C code,
    well, Rust can prove that the arguments you're passing are the right types,
    but if you've ever used C, you know that's not the whole story.
    C functions have pointer arguments.
    Is it safe to pass a null pointer?
    It depends on the function. Sometimes it is and sometimes it isn't. Rust doesn't know.
    Does the function save the pointer and try to use it later? Rust doesn't know.
    Is the function itself correct, or is it buggy and crashy?
    Welllll...

    Calling into non-Rust code is beyond the reach of Rust's proof technology.
    But we still want to allow it.
    Hence, the `unsafe` keyword in Rust.

    Second big assumption:

2.  Uninitialized memory doesn't exist.

    Again, this is "true enough" for most Rust code.

    If you have a variable, Rust only lets you use it if it's initialized.

    If you have a struct, all the fields are initialized.
    
    If you have a reference, the value it refers to is always fully initialized.

    And so on.
    In normal code, this assumption is fine.
    There are two kinds of memory in a process,
    memory that's in use, and has data in it;
    and memory that's uninitialized, and has garbage bits in it.
    Making sure we're only using the first kind is a really nice feature of Rust,
    a big step up from C++, and an important part of the safety proof.

    But of course it means you can't write Rust code
    that's *about* uninitialized memory.
    Remember the `Vec::push` method we were looking at earlier?
    It's fundamentally about the vector having some extra memory ready to store the next value.
    The subject matter of that function is fundamentally at odds with Rust's safety system.

    I think this actually gets a lot of C++ programmers into trouble immediately
    when they pick up Rust.
    Often the very first thing they want to do is make a doubly linked list,
    or implement `malloc()`,
    and these are actually *great* uses for Rust,
    but they're memory management,
    and therefore not the best fit for *safe* Rust.
    Not the best introduction to the language.

    So code that does memory management is beyond the reach of Rust's proof technology.
    But we still want to write that code in Rust.
    Hence, the `unsafe` keyword in Rust.

Now if you look at these assumptions,
there's a sort of comfort zone, where you're writing normal Rust code and these are true,
and the safety proof goes through just fine.

Unsafe code is a gap in the proof.
It's a place where we're saying, look,
I gotta write code that crosses these lines.
And I understand that undefined behavior can happen, if I screw up.


### Trust me blocks

*(slide: `Vec::push`)*

That "I understand" statement is a big part of what unsafe code is about.

When we see an `unsafe` block in Rust code,
what it oughta say is, "TRUST ME".

        pub fn push(&mut self, value: T) {
            if self.len == self.buf.cap() {
                self.buf.double();
            }
            TRUST ME {
                let end = self.as_mut_ptr().offset(self.len as isize);
                ptr::write(end, value);
                self.len += 1;
            }
        }

That's what we mean, right?

What we're saying is, this pointer arithmetic here?
This pointer write?
I've thought it through,
and this code is correct.
Trust me.

Now I know what you're thinking.
I don't trust this guy.

Which is probably smart...
maybe a little hurtful...
but the fact that we're even talking about it is probably a good thing.
I've been doing C++ for years, I *never* had to type "trust me"!
"Yeah, I'm gonna XOR these two pointers together."
The compiler just trusted me!
I'm telling you, it's bonkers!

Rust isn't quite so trusting; in normal code it checks your work.
Even in an `unsafe` block, types still exist, lifetimes still exist,
the rules of the language still apply.
The only thing this `TRUST ME` unlocks
is the ability to call unsafe methods, and dereference raw pointers.

So now you know how to shoot yourself in the foot in Rust.

*(slide: "Unsafe you shoot yourself in the foot.")*

My last few slides here are going to be about how *not* to shoot yourself in the foot.


### How To Write Unsafe Rust, The Slide

*(slide: How to write unsafe Rust)*

The techniques are all classics,
and I hope you've heard of them all before.

The first thing to keep in mind is,

*   **Don't**

    obviously, don't do it.
    I mean, you probably don't need to be reminded, but for completeness...

    The nice thing about unsafe Rust is,
    you also get a whole *safe* language, free of charge!
    So, maybe consider that.

*   **Contracts**

    are just the rules for how you're supposed to call a function.
    Because that's kind of the building block of this safety proof
    I keep talking about.

    Every unsafe operation *can* be used correctly.
    As long as you follow the contract, then the unsafe method is in fact safe.

*   **Invariants**

    are the best idea in object-oriented programming;
    very useful when you've got unsafe code.

    They're conditions that you could always assert for a given type of value.
    This is what makes that pointer arithmetic in the `Vec` example safe.
    There's an invariant in `Vec` that the `.len` field
    is always less than or equal to the capacity.
    There's another invariant that every element of the buffer up to the `len`
    is fully initialized.
    Without those invariants, `push` would not be safe.
    And all code that has access to the `.len` field has to be carefully written
    to make sure the invariant stays true.

*   **Making invalid values impossible**.

    This one comes from those smug functional languages,
    the Haskells and MLs of the world.

    The idea is, when your language has a good type system,
    you can use the type system to rule out things like
    null references, dangling pointers, and bad values generally.

    Rust is good for this because the type system has lots of features.
    It can express ideas like,
    this string is only good for this one function call;
    or, this field is optional.

Anyway, the common thread here is simply:
do the things you need to do in order to reason about your code.
I said that unsafe code is a gap in the safety proof.
You're filling the gap.
Write your code to convince yourself that it's safe after all,
even though Rust can't fully verify that.
All these techniques are about building that safety proof in your head,
and making as much of that proof as possible live inside your code.


### Contracts

Of these four things, contracts, I think, could bear a little more explanation.
So let's talk about contracts.

*(slide: Safe or unsafe?)*

In Rust, when I started out,
it wasn't obvious sometimes if I should mark a function `unsafe` or not.
The language lets you choose, which is a little surprising:

*(slide: `Vec::push`, modified to be unsafe)*

you can either declare the whole function unsafe,
basically flag this method as being unsafe to call;
or you can say, "trust me",

*(slide: on the right, the actual code, w/ `unsafe` block)*

and the difference is, if you do this, your function is considered safe.
`unsafe` is not in the method signature,
so the caller receives no warning that you've got this unsafe code in here.
Which is right, and why?
And how important is it to get this right?

I started out thinking,
well, if this code does dangerous things,
then obviously calling it is going to be dangerous.
So, option 1.
In this view, unsafety is kind of this spreading contagion
that can't be stopped and infects your whole program.
It's an all-or-nothing view of risk that's pretty typical for beginners.

But option 2 is what actually appears in the standard library.
What I think now is, option 2 here is kind of what Rust is all about.
Rust is a toolkit for making dangerous stuff safe,
without compromising performance.

Wrapping carefully-written unsafe code in a safe API
is the underappreciated cornerstone of Rust.

The *right* way to decide when a method should be declared safe
is to understand its contract.

It's really simple.
Every function has a contract,
a set of rules for correct use.
Not just in Rust and C++, all languages are like this:
when you call a function,
you have to pass a certain number of arguments, of particular types,
if you want the function to work right.

And then if you misuse the function, then what?
Well, best case, like with this `push` method,
there are no invalid arguments,
because the type system completely captures
what arguments are acceptable here.
It's part of the type signature.
The compiler enforces that, and in theory nothing else should go wrong here.

Other functions, in addition to the type,
they might have to *check* the arguments to make sure they're ok.
Like the `String::insert()` method,
if you pass an index that's off the end of the string,
it'll panic.
It doesn't say that in the type signature.
It says it in the documentation.

Usually some combination of types and runtime checks is sufficient.
But if not—if misusing a function could lead to undefined behavior—well,
*then* it needs to be marked unsafe.

`unsafe` means two problems:
First, the contract is more detailed than the type system can handle,
so if you want to use it safely, you actually have to read the documentation.
Second, if you do break the contract, that would be bad.

That's the case for functions like `ptr::write`.

*(slide: `ptr::write` docs)*

And sure enough, the documentation has five paragraphs
of stuff you need to read if you want to use this function without crashing.
The fine print of the contract.

*(slide: `Vec::push` docs)*

The `push` method doesn't have any fine print about safety.
It can *panic*, in one bizarro case that happens with zero-size structs.
But panic is safe, programs can survive panic.
There are no safety rules in the contract,
therefore this is a safe method.

However, that leaves the implementers, then, with the task
of building a safe method from unsafe parts!
It can be done.

*(slide: "Build safe code from unsafe parts", showing the `Vec::push` code one more time)*

You need to carefully follow the contracts for those unsafe parts
Check the data flowing into unsafe code.
Or use invariants to make it impossible for the data to be wrong.
Make it impossible for your caller to break that contract.
Take responsibility yourself for enforcing it.

For example, `ptr::write` requires this pointer
to be a valid, aligned pointer to memory no one else is using,
practically speaking, it must be within the vector's buffer.
How do we make sure that is true?
All the parts of the method are working together to that end.


## Conclusion

So what have we learned today?

*(slide: bullets)*

*   We learned that while you're in Columbus,
    you should visit Jeni's and try the Brambleberry Crisp.

*   We learned what kind of C++ code can cause undefined behavior,

*   and what that means, in theory and in practice.

*   We learned what "safe" means in Rust,

*   why unsafe code is allowed,

*   and a few key ideas for writing unsafe code responsibly.

*(slide: blank)*

So what?

I've noticed that sometimes, in some fields,
engineers get the idea in their heads that they can engineer a safer future.
Medical equipment, airplanes, the space program. Industrial machines. Highways.
When that's the case, we do safety engineering.
We study failures.
We seek to understand them.
We design tools that rule out those failures.

Well?

What about software?
Is it safe enough today?
Can we engineer a safer future, or do we think nothing will help?

That's for you to decide.

I think we can build a safer future.
So if you take one thing from this talk,
I hope it's an understanding—at a technical level—of how Rust fits into that effort.
Sure, Rust prevents some bugs outright, but it's more than that.

*   It also helps you understand what the safety rules are
    that good C++ hackers have been accumulating in their heads,
    one by one, the hard way, for decades.

*   It also helps you put unsafe code behind a safe API
    and have reason to believe it is actually solid.
    That is a safety engineering tool.

*   It also has an expressive type system and ownership system,
    so you can write more contracts in the language itself,
    enforced by the compiler,
    instead of writing unsafe methods with long comments explaining how to use them.
    That is a safety engineering tool.

*   Maybe most important, it's economically viable.
    So you can actually choose it and use it.
    Rust can be your competitive advantage.

Unsafe code isn't going away.
If you're a systems programmer,
and your job involves writing unsafe code, or consuming unsafe APIs,
you should be using Rust.
It's the right tool for the job.
It's ready today.
Let's do it.

Thanks for your time.

*(ideally I would then go,
"Now the moment you've been waiting for... Please welcome... Cornhenge!"
and we would hear the Broken Brass Ensemble cover of "Thrift Shop"
<https://www.youtube.com/watch?v=Pmaub5P4CRE&t=21s>)*


## TODO

* [ ] Circle back to the scrolling grep thing later, say explicitly what's unsafe in libstd.

Two suggestions from folks who saw the talk the first time:

* [ ] Point out that the "unsafe" part is not the only scary part.

* [ ] Mention use of private fields to crack down on invalid values.





