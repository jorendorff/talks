# Don't blame the decaf: What really causes software failures (and successes)

*This is a talk I gave for a class at Vanderbilt
and another class at Nashville Software School
in December 2017.
No slides for this one, just a big whiteboard.
—@jorendorff*


## Introduction

Back in the 1980s, there was a computer-controlled radiation therapy machine
called the Therac-25.
It produced a powerful beam of electrons or X-rays for destroying tumors.
It was used in hospitals for several years.
As far as I know the machine saved many lives.
But the system software had a bug
that caused it to deliver massive overdoses of radiation
to six patients (that we know of).
The overdoses caused burns and radiation poisoning.
Three of the patients died.
*(write on board, all the way to the right: "3 patients lost")*
These accidents remain the worst in the history of radiation medicine.

This talk is in two parts.
The first half is about this medical device and why it malfunctioned.
The second half is about what safety means now,
whether things are any better in 2017 than they were in 1982.


## Part 1 - Therac-25

The Therac-25 is one of the most thoroughly studied cases
of software engineering failure.
A summary of what we know about this device
is given in ["Medical Devices: The Therac-25"](http://sunnyday.mit.edu/papers/therac.pdf).
The summary is fifty pages.
I am going to try to summarize the summary for you.

But it's hard.
The world is complex, so any event naturally has many threads leading into it,
and therefore many causes.
Along each chain of cause and effect,
there are multiple points where disaster could have been averted.
So I'm just going to go down the list.
I don't mean to say that all of these led directly to overdoses.
But these are things that happened.

Get comfortable.

*(writing in a long list on the right half of the board)*

*   **Bad error messages.** When something went wrong with the machine,
    it would display an error message like "MALFUNCTION 45".

    Obviously this is not a good error message.
    (Pop quiz. What makes an error message good?)

*   **Data races.** Can anyone tell me what this means?

    *(For beginning audiences:)*

    This is a kind of bug that happens when you have multiple things going on at once.
    For example, suppose you have a web page that has several parts that load separately.
    The data for these things can come in off the network in any order,
    and they just appear progressively, one by one, in the page.
    Obviously what you *intend* is that it doesn't matter what order they load.

    But if you have one part that assumes another part has already loaded,
    and if they happen to load in the other order it breaks,
    then you have what's called a *race condition*.
    This kind of bug can be very hard to track down. Why?

    The Therac-25 had a version of this caused by multiple parts of the system
    accessing shared variables, a kind of race condition called a data race.

    *(Or, for more advanced audiences:)*

    These are errors involving variables that are shared by concurrent processes.

    The system had multiple tasks that communicated through global variables.
    One task was responsible for physically setting up the machine.
    Another was responsible for keyboard input.
    Another was responsible for the particle accelerator.

    Whenever parts interact, there is a protocol, whether it's written down or not.
    Here there was no explicit protocol;
    the programmers just kind of kept a half-assed idea of how it should work in their heads.
    It was buggy.

*   **Incrementing a boolean.**
    There's some code where an 8-bit integer variable was treated as a boolean.
    That is, the code would check whether this integer
    was zero, meaning false, or nonzero, meaning true.
    However the code to set the flag did not just set it to 1.
    It incremented the integer.
    And this would happen several times per second.
    Every 256th pass through the code, the integer would overflow,
    and its value would be zero.
    This variable turned out to be safety critical.

    This software is a very low-level system by today's standards,
    written in assembly code with global variables everywhere.
    And it has the bugs of a low-level system!
    A badly programmed system developed today would likely have different issues.

*   **Status confusion.** I made this term up.
    I don't know if there's a better word for this.
    It's a particular kind of bug that I've seen in a lot of programs.

    It happens in game development all the time.
    You have a game, and there's, I don't know, some kind of monster,
    and the monster has a status bit on it, it's either alive or dead.
    Well, you get the game working, everything's great,
    and you decide there should be a death animation for this monster.
    So you add a third status: dying.
    And long story short, nothing ever works again.
    You have this monster trying to run around and fight while it's dying,
    you have it taking damage while it's dying, so its hit points can go way negative,
    which couldn't happen before, and that exposes unrelated bugs.
    Everything just goes to hell.

    Well, the Therac-25 had the unfunny version of this bug.
    There was a form that the operator filled out
    to specify the radiation dosage and so forth.
    This is before Windows; we're talking about a text-only console.
    In hindsight, it is easy to see that
    the process of delivering a dose of radiation should have gone
    through a rigid sequence of steps: fill out the form, hit submit;
    *then* the machine sets itself up;
    *then*, once it's ready, the operator hits the button one last time to confirm;
    *then* the machine delivers the dose of radiation.

    Instead, the machine started setting itself up for treatment as soon
    as the operator got to the end of the form. But the operator could
    still go back and edit the form after that. This was apparently
    intentional. The software was designed to detect if you did this and
    cancel out of the treatment cycle. However, that code was buggy. As
    a result, you could edit the treatment parameters while the machine
    was already halfway through the process of setting itself up to
    deliver radiation to the patient.

*   **Programming mistakes.** Multiple distinct mistakes by programmers
    contributed to the confusion I just described.

    Dumb mistakes, the kind we make every day.
    Instructions that looked like they did one thing, but
    accidentally did the wrong thing, or didn't even run.
    Using an AND instead of an OR. Mistakes.

*   **No hardware interlocks.** An interlock is a physical mechanism
    that rules out dangerous situations. Traditionally, this kind of
    machine would have some kind of electromechanical interlock to
    ensure safety. The Therac-25 relied on software checks instead.

*   **Code reuse.** The Therac-25 reused code from an earlier radiation machine.
    Obviously the assumption was that, since the earlier model was deployed
    and nobody died, the software was OK.
    Later it was discovered that the reused code had some of the bugs,
    but in the old model they resulted in blown fuses instead of
    overdoses, because the old model had hardware interlocks.

*   **Frequent minor errors.** Operators became "insensitive to machine
    malfunctions. Malfunction messages were commonplace and most did not
    involve patient safety." When the machine had a malfunction, it would
    "pause", and the operator could either do a full machine reset or
    press the P key to proceed.

*   **General bad software quality.** One user complained about "poor
    screen-refresh subroutines that leave trash and erroneous
    information on the operator console". A bad sign.

What do you think? What jumps out at you?

*(discussion)*

Well, I have something to confess.
I only gave you half the story.

Yeah, there's more.

These are the technical factors that contributed to the overdoses.
*(writing "Technical" at the top of the right half)*
And here are some organizational factors
*(writing them on the left half)*:

*   **No code reviews.**

*   **No test plan.**
    The product was tested, but the testing was ad hoc.
    After the overdoses, the FDA asked the manufacturer for a copy of the test plan.
    The manufacturer was unable to produce anything.

*   **Software risks not evaluated.**
    The manufacturer did *risk assessments,*
    estimating the probability of failure for every hardware component in the system.
    From that you can compute the total failure probability of the system as a whole
    and make sure it's an acceptable number.

    The probability of bugs in the software was not considered.
    I don't know how you would compute that anyway.
    And it's not the same kind of risk.
    Software risk is nonrandom.

*   **Errors not documented.**
    The user manual did not explain or even mention the numeric error codes.

*   **No final system testing.**
    The final software was not tested together with the actual final hardware
    until the machine was assembled at the hospital.
    (I don't know if testing would have prevented the overdoses, though.)

*   **Overconfidence.** The manufacturer apparently did not believe it was possible
    for the machine to harm patients.
    They repeatedly told hospitals this,
    and their internal investigations did not find the problems.

*   **No FDA oversight.** The FDA approves drugs. It's a whole thing.
    At this time the FDA did not have any role in approving this kind of medical device.
    They got involved after accidents were reported.
    I should say here that I don't know if the FDA had the expertise at the time
    to do a good job with that in the first place.

    It has changed since then—for medical devices.
    For everything else, the situation is much the same today.
    You will be going to work in an unregulated industry.
    There are no building codes for software.
    There's no consensus on what they should be.
    This means the safety of the code you write is *your* responsibility.

All right.

Now what do we think? *(discussion)*


### My assessment

There's kind of a lot going on here, right?

There were many problems in this organization,
and those organizational problems led to many technical problems.
The root human flaw I see in all of this,
and maybe it's just me, but I see a **failure to face reality**.
*(writing that on the far left of the board)*

The people in this organization thought they could make a safe machine
without doing any quality assurance
or any of the other engineering work that makes machines safe.
I'm sure they knew the software was bad. It was garbage.
At the same time they allowed themselves to think it was good enough,
and anyway it couldn't harm patients.
These two beliefs are contradictory.
They should have experienced cognitive dissonance over this.
They probably occasionally did.
Not enough to make them remedy the problems.
It's terribly easy to get used to quality problems.

I am guessing about the mental states of the people involved,
which is reckless,
but I do it because I recognize this *(meaning, the abundance of causes)*
and I want you to recognize it when you see it.
I've been in this situation, thankfully not with medical equipment
(and not at Mozilla, either).

So this is how I see it *(gesturing at the whiteboard)*:
complacency
leads to organizational problems
which lead to technical problems,
which lead to consequences.


### Reflections on failure

Let's take a few steps back.
I want to make some general points about failures and safety.

1.  **Safety and quality are very closely related.**

    This product was both dangerous and buggy as hell.
    We've listed the reasons it was dangerous,
    but the reasons it was buggy are all the same factors. Right?

    So from here on out I am going to treat safety and quality
    as basically the same thing.
    Security too—we hear a lot about software security these days.
    Same deal.

2.  **When you know more, things look different.**

    I'm so old, I can remember a time
    when it looked like this was a technical problem.
    Things have changed since then.

3.  **Failures have a web of causes.**

    This picture is the rule, not the exception.

    The next time you see in the news that
    X Huge Company got hacked due to a device with a default password,
    and you think, why the hell do we still have devices with default passwords,
    well, you're right, that's horrible.
    But also understand: that's a bullet point.
    *(gesturing to one of the technical bullet points)*

    Without knowing anything else,
    you can bet that there are multiple causes, across multiple organizations.
    You can bet that there was no policy to configure every device according to its manual,
    or that the policy wasn't followed.
    You can bet that the organization didn't know about the vulnerability
    and there's a whole set of reasons why they didn't know.

    And you might ask: even if this device was vulnerable,
    does it make sense for that device to be on the same network
    as a hundred million social security numbers (or whatever)?
    Did everyone on that network have access to that data?
    What other vulnerabilities were exploited along the way?

4.  **Blame is not a number.**

    Not only is there not a single cause for a tragedy,
    when you think about the morality of it,
    the total blame does not equal the total harm done.
    I carried this unworkable idea around for years and the math does not balance.
    My normal approach is useless here.

    Fortunately, it's not our job to judge, to assign moral culpability.
    We're engineers. Our job is to solve problems.
    Our job is to prevent this happening again. So:

5.  **The work of engineering quality is
    breaking the causal chains that lead to failure.**

    Some good news, for a change.

    This organization doesn't need to address *all* the problems
    in order to change outcomes.
    That's good, because organizations *can't* tackle everything effectively at once.

    It would be wisest to start with the place where the least effort
    could catch and prevent the widest range of bad outcomes.
    Right?

    If you could go back in time,
    if you had just one week to work in this organization in 1982,
    if you had to decide what *one thing* to work on,
    knowing you might have to persuade some people it's worth working on,
    what would you choose?

    *(discussion — I actually call on people for this until I get two different answers,
    because I want everyone to think it through. Many good answers are possible.
    I was surprised when a student at NSS picked "Error messages".
    Startlingly good, right?)*

A big difference between school and industry is
the sheer scale and complexity of the projects.
These questions actually come up in industry.
The coding projects I worked on in school were not large enough
or messy enough to produce this kind of situation *(indicating the web of causes)*.
Typically, I handled bugs as follows: find a bug, fix it, instantly forget it forever.
That works for small projects,
because the bugs are few, simple, and inconsequential.
In industry, some bugs are not easily found *("data races" again)*,
and some are not easily fixed *("overconfidence")*,
and some are not easily forgotten *("3 patients lost")*.


## Part 2 - Quality at Mozilla

*(continuing)* We need ways to have less bugs,
or to eliminate them with less effort,
and that means bringing weapons to bear other than hard work.

So I have another list for you.
It's a list of quality practices at the company I work for, Mozilla.
If the Therac-25 is a case study in things going wrong,
this is a case study of an organization that takes software quality and safety seriously,
thirty years later.

An incomplete list.
Here I will not separate technical and organizational factors;
I'm just going to give them to you in one big blob.

*   **Version control.**
    Obviously.

*   **Issue tracking.**
    If you want to build awful, buggy software,
    by all means, let information about defects get lost in the shuffle.
    If not, you'd better have a bug tracking system.

    *(pointing at the first two items)*
    This stuff is maybe too obvious to mention, but I'm mentioning it anyway,
    because I don't know how much of this stuff you've learned.

    But OK.
    Tools for collaboration and communication are tools for quality.
    Moving on.

*   **User feedback.**
    Every software team needs to be in contact with its end users
    or it builds the wrong thing.
    This might be the most important item on the whole list.
    Fortunately Firefox users (and ex-Firefox users) are not shy.

*   **Code review.**
    Every code change I make in the Mozilla codebase
    gets peer reviewed by another programmer before it can land.

    If nothing else this helps you enforce your other quality practices,
    so they don't kind of fall by the wayside out of sheer laziness.

*   **Automated testing.**
    I'm going to spend a minute on this one.

    Firefox has hundreds of thousands of regression tests.
    What is a regression test?
    It's a test that detects
    when something that used to work stopped working.

    When we fix a bug, we add a test.
    When we add a new feature, we add tests.
    This is project-wide policy.
    And we run the tests all the time.
    If you make a change, and it breaks something,
    you'll know about it.
    This is an incredibly important tool.

    The problem of introducing this practice in an organization
    is mainly a problem of reducing the marginal cost of creating tests,
    so that adding tests does not feel like a burden.

    One problem with tests is that there's always something
    that isn't under test, and that's the thing that breaks.
    The ability to test that new thing might mean adding a whole new
    test runner, and that's a pain.
    It makes this a continuous investment.
    But as far as I can tell, you just have to do it.

*   **Continuous integration.**
    What is this?
    If you take it literally,
    "continuous integration" just means constantly integrating changes,
    because, well, you've got a whole team of programmers working on a codebase,
    all making changes to it.
    But what this term means to a programmer is,
    the testing infrastructure you need, to make that not be total chaos.

    Whenever anyone checks code into Firefox,
    a bunch of automated systems leap into action.
    They build the whole browser for all the operating systems we support
    and run all the tests.
    So when everything is suddenly broken,
    we tend to know exactly which change broke it.

    There are free tools that do this for you.
    Travis-CI is one of them.

In fact there are free or freeish products to help with all of this stuff.

These six tools are for everyone.
Every nontrivial software project should have—well, probably all of these.
Five out of six is pretty good.

Now is a good time for a disclaimer.
My experience in software is only my experience.
There is no widespread consensus that these practices are the best
or that *any* particular method is necessary or sufficient.
But maybe put these in your back pocket
and use them until something better comes along.
(Software engineering is a whole
[field of science](https://www.amazon.com/Making-Software-Really-Works-Believe-ebook/dp/B004D4YI6G),
so in theory, you don't have to take my word for anything!
But it's a very difficult field.
Reproducible experiments are impossible.
Studies tend to use convenience samples, tiny sample sizes, or both.
I have not found the science actionable.)

What else do we do at Mozilla?
Here are a few more things, just for fun.

*   **Try server.**
    Sometimes you just want to try out some new code and see if it works.

    The Try server takes your code
    and runs all the same tests as our continuous integration system,
    just without the "integration".

*   **Release drivers.**
    Each Firefox release has a release driver,
    a person in charge of making go/no-go decisions on when to ship,
    and how to handle last-minute problems and fixes.

    We release Firefox roughly every six weeks.
    If your product is a web site, you don't want our exact process.
    But you probably want this role.

*   **Security team.**
    We have dedicated staff that work exclusively on security.
    They do things like security reviews of new features.

    They also spend a lot of time helping random developers like me
    do the right thing when we fix security-sensitive bugs.
    We have to fix vulnerabilities
    without revealing them to the bad guys. It's delicate.

*   **Fuzzers.**
    We have programs constantly generating random web pages, 
    random JavaScript programs,
    random CSS stylesheets,
    and so on,
    feeding them to Firefox to see if they can get Firefox to crash.
    These programs are called fuzzers.
    You can think of them as radically randomized regression tests.

    We are running fuzzers literally all the time,
    and we have a team to tend those fuzzers and their hardware,
    and file bugs.

    Many of the bugs filed against the JavaScript engine are found by fuzzers.
    *Most* of them, if you only count reproducible bugs.

*   **Assertions.**
    When I have an invariant in a program,
    I often add a line of code that records that invariant,
    `MOZ_ASSERT(x > 0)`;
    and then in debug builds Firefox will actually check that x is greater than zero,
    and if not, it'll crash.

    Assertions make unit tests better. Why?
    They make fuzzers *much* better. Why?

    Assertions are common in the C++ world,
    but for whatever reason I don't think web developers use them much.
    You see assertions in tests, but not sprinkled through the code.
    I don't know why. Seems like a mistake.
    But that's me.

*   **Quality assurance team.**
    Mozilla has dedicated QA people. I don't hear much from these folks.
    The JavaScript engine must be pretty far removed from what gets tested by QA.

    Even if you're doing everything else right, you will have places
    where the UI just doesn't make sense as designed,
    or where some obvious thing users will try to do doesn't work.
    QA people find these things.
    What QA people have is normal human expectations.
    None of this other stuff gives you that
    (until you get all the way to "User feedback").
    So if you want to fix problems *before* your users are mad,
    obviously you need QA staff.

*   **Automatic updates.**
    If we fix a security bug in Firefox,
    you aren't protected until you start running the fixed browser.
    We have to deliver that new browser build to you.
    We've automated this so that it goes quickly and smoothly.
    For web sites this is easier.
    In any case, automate deployment.

*   **Crash reporter and Telemetry.**
    When Firefox crashes it sends a crash report back to Mozilla.
    We look at those.
    It's one of the ways we know when we've screwed up.
    We'll see the number of crash reports spike.

    Telemetry is a similar thing for when we don't crash;
    it occasionally sends a few summary statistics about your user experience,
    mostly performance information.
    How often do you see the beach ball, and for how long,
    that kind of thing.
    If those numbers spike, we want to know.

*   **Bug triage.**
    We routinely examine open bugs
    to make sure important stuff isn't falling through the cracks.

*   **Bug bounty.**
    If all else fails, there's this.

    If you find a security vulnerability in Firefox,
    and you report it to us,
    we will pay you cash money,
    and we will fix it.
    A typical payout for an exploitable bug is $5,000.
    It can be $10,000 or more.
    The total amount we've paid out in bounties over the years
    is around three million dollars.

We actually have *more* tools and technologies and practices and process rules
and coding conventions that affect quality and security,
*(like the profiler, like compartments, like process separation and sandboxing)*
and I'd love to talk about them,
but they start to get very Firefox-specific,
so I'll stop here.

Well, maybe just one more.
There is one quality technology we have that's a programming language:

*   **Rust.**
    A lot of our codebase is C++,
    and despite our best efforts,
    that stuff has the bugs that C++ codebases have.

    We will not stop using C++ anytime soon,
    but Rust is much safer and we're eager to use it as much as we can.
    Rust rules out dozens of common C++ bugs. This is a big deal for us.

So. This is our toolkit, and you can use these tools too.


## Conclusion

I will end with two very simple observations.

1.  **Don't rely on programmer diligence for software quality.**

    We should all be diligent, obviously.
    But people get tired, they mess up, and worse, they get sloppy.

    Instead, good quality practices do an end run around what programmers do,
    just like good security practices do an end run around all the things attackers can do,
    and good safety practices do an end run around all the boneheaded things users can do.
    It's the only way to be sure.

    Please, engineer your organization not to fail catastrophically
    when someone makes a pot of decaf by mistake.

2.  **You can work on this stuff.**

    I am giving you permission on behalf of your future managers.
    I'm from the future. They told me to tell you it's OK.

    You probably won't work on safety-sensitive systems, not right away.
    But you will work in places that have quality problems.
    You'll find that what they really have is quality process problems.

    Fix them.

    If you go into industry, you'll be green at first.
    Your managers and more experienced engineers will choose what you work on.
    That's normal.
    But if there's something else that's more important,
    more pressing, that can make a big impact, push hard to *do that*.

    What you did earlier,
    when I said you could go back in time and take a week to prevent this,
    the mental work you were doing, weighing the options, knowing what's at stake—
    that *is* your job.
    In industry, in academia, wherever you end up,
    working on the most important thing you can do is magic.
    Managers, coworkers, executives, the whole world will stand on its head
    if you know how to do that.
    Rightly so.

    Find out what your organization's problems are,
    and engineer solutions to those.
    Quality engineering is process engineering.

Thank you.
