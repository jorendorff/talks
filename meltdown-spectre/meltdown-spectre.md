# Meltdown and Spectre

*(This is a transcript of a lightning talk I gave at NashJS on 10 January 2018.)*

## Intro (15s)

*(slide: Meltdown and Spectre logos)*

Meltdown and Spectre are two new security vulnerabilities revealed January 4th.
Yes, security holes have logos now...
You may have heard about this.
These vulnerabilities don't take over your computer.
They allow an attacker to steal sensitive data, like passwords.

These attacks are like nothing I've seen before.
To understand how they work, you need to understand
branches, instruction pipelines, and speculative execution.
Let's get going...


## Branches (30s)

*(slide: "Branches")*

Your computer is a decision-making machine.
Say you've got an `if` statement.

```javascript
if (the light is off) {
    turn the light on;
}
look for keys;
```

There's a decision point in this code.
At the end of the first line,
the CPU has to decide whether to continue with the next instruction,
and turn the light on;
or jump ahead to this part where it looks for your car keys.

This kind of decision point is called a *branch*.
Normal code is full of branches.
They're everywhere.

```javascript
while (sink is not empty) {   <--- branch
    do dishes;
}

switch (game.mode) {  <--- branch
    case EASY_MODE: ...;
    case HARD_MODE: ...;
    ...
}

return;  <--- branch
```

It's not a problem, unless you're a CPU.


## Instruction pipelines (55s)

*(slide: jet engine)*

Modern CPUs have something called an *instruction pipeline*.
They're massive assembly lines for computation.
One part of the CPU is racing ahead and fetching upcoming instructions from RAM;
another part is decoding the instructions that have been fetched;
another part is figuring out what data we need for those instructions;
another part is prefetching that data from RAM;
another part is actually executing the instructions;
and another part is storing the results.

This is a picture of a jet engine, but it's the same idea.

Actual Intel CPUs have a 31-stage pipeline.
It's one of the engineering wonders of the world.

Well, branches are bad for the pipeline.
Why?

*(slide: if statement)*

When you reach a branch,
you can't keep racing ahead and working on what's next,
because you don't know what's next!
You have to wait here until the actual compute stage of the CPU comes along
and tells you which branch you're taking.

*(slide: airplane at a stop sign)*

This is called a *stall*.
We're not moving forward anymore.
Execution is stalled.

Well, stalls suck,
so CPUs are designed to try to figure out as early as possible
which way a branch will go, to avoid stalling.
And if they can't figure it out in advance...

They guess.


## Speculative execution (55s)

*(slide: Speculative execution)*

The CPU will make an educated guess as to which way the branch will go,
and race ahead in that direction.

This is called *speculative execution*, because
the CPU is starting to execute these instructions,
and just sort of hoping they are the right ones.
If so, great! We avoided a stall.

But the guess may turn out to be wrong.
Eventually the CPU figures out the branch should have gone the other way.
Then what?
Well, the parts of the CPU that have been racing ahead
have done a bunch of erroneous work.
The CPU has to discard all that work,
go back to the branch,
and start over, loading, decoding, and executing instructions
along the branch that the program *actually* took.

If that happens, it's as bad as a stall, but we were going to stall anyway.
And CPUs are good at guessing, so at most branches, speculative execution prevents stalls.


## The full attack (2m)

OK, now you know enough to understand Meltdown and Spectre.

These two attacks are very similar.
In five steps:

1.  **Run evil code.**

    First, you have to get your victim to run some code for you.
    If the target is a web browser, you feed it malicious JavaScript.
    That kind of thing.

2.  **Trigger speculative execution.**

    Second, you have to get speculative execution to happen.
    You must “train” the CPU on your code
    so that the CPU expects one branch to be taken,
    and starts speculatively executing those instructions.

3.  **Read the secret.**

    Now the attack.
    In those speculative instructions,
    you speculatively read data you're not supposed to have access to.

    One way to do that is to read off the end of a typed array.

    ```javascript
    if (index < array.length) {         // CPU expects this to be true
        let secretByte = array[index];  // index is actually > array.length
        ...
    }
    ```

    For now, just accept that this is allowed.
    Obviously it shouldn't be.
    But in theory, it's OK,
    because we're only *speculatively* executing this code.
    If the read turns out to be bogus,
    all this gets rolled back,
    so it's no big deal.

    OK. Now we're in a scenario from a science fiction story.
    You're an evil secret agent,
    and you've obtained the top-secret information!
    But the universe you're living in is a spurious universe. A mistake universe.
    Mere nanoseconds from now, the CPU is going to detect the mistake and roll all this back.
    Your temporary universe where you've got the secret
    is going to be rolled back out of existence.
    How do you get the secret out?

4.  **Smuggle it out.**

    It turns out there are several ways to do this.
    There are things you can tell the CPU to do that
    have subtle side effects that won't get rolled back.

    For example, do a second memory access,
    for a location that depends on this secret data.

    So if the byte you've read is, I dunno, 65,
    the next thing you do is look up element number 65 in a separate array,
    one that you created.

    ```javascript
    if (index < array1.length) {
        let secretByte = array1[index];
        let dontCare = array2[secretByte];
    }
    ```

    I know, this looks super pointless.
    But this is what it looks like when you’re trying to smuggle information
    from one timeline to another, OK?
    Here’s why this works.
    The CPU *caches* every piece of memory it reads, for speed.
    It remembers values, just in case it needs the same value again soon.
    So when you do this, the CPU grabs element number 65 out of `array2`, and that gets cached.

    Eventually, the CPU detects its mistake,
    rolls back the universe to the branch,
    and executes the correct path.
    Your precious secret information is lost.

    Or is it?
    You've still got `array2`,
    and one element of `array2` is cached in the CPU.
    The cache was not rolled back.

5.  **Recover it.**

    How can you recover the secret number that you lost?

    Think it over...

    What you have to do is very precisely measure how much time it takes
    to read each element of `array2`.
    One of those elements is cached, and that one will be faster.
    When you measure that `array2[65]` is twice as fast to read as the other elements,
    you know that the secret value you read was 65.

    *(This is a simplification.
    The actual unit of caching, called a “cache line”, is bigger than just one array element.
    To learn how to get around that problem, read the Meltdown paper.)*

    This is what's called a timing attack.
    You've just recovered one byte of the secret.
    Now repeat this for the next byte, and the next byte,
    until you've got the whole secret.

    Speaking of timing attacks, I think *I'm* about to be attacked,
    for running over my time,
    so let's move on.


## Stopping Meltdown (45s)

Meltdown attacks operating systems,
using a specific CPU bug.
In step 3, Meltdown reads from operating system memory
that it categorically should not have access to.
The CPU allows the read, speculatively,
while the permission check is going on in parallel.
Eventually it rolls everything back, but it's too late.

How do we fix this?
Well, Intel needs to mail everyone a new CPU.
But while we're waiting for that to happen,
operating systems have been patched
so that kernel memory isn't addressable at all in user processes.
That stops Meltdown.

It also makes computers slower.
So if you haven't installed updates lately,
your laptop is about 5% faster than everyone else's!
Good work!


## Stopping Spectre (45s)

Spectre is the single-process version of this bug.
It attacks browsers.
With Spectre, it's easiest to block step 5.
That's why all browsers are now rounding off the value of `performance.now()`
and disabling something called `SharedArrayBuffer`.
We're trying to eliminate this timing attack by eliminating timers.

It's not good enough.
We expect to see attacks that don't require precise timers,
so we're going to have to somehow keep JIT code from accessing secrets even speculatively.

This makes Spectre unique and scary.
We're talking about locking down code that *in theory isn't even executing*.
That's where we are.

I'm out of time.
For more, read the two papers at [meltdownattack.com](https://meltdownattack.com/).
They're 16 pages each and very good.

Thank you!
