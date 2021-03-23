# Questions to answer

## Inform

**Do the particular noun phrases I use in the talk actually work in Inform?**

They do now.



## Alloy

***Does Alloy have other operators than just `.` for when I want to take
the present moment snapshot and query through? like, right now it says
`s.location.Left` to mean "the set of objects currently located on the
left bank at time *s*". Is there a nicer way to say that? I don't love
`Farmer.(s.location)`.**

Looks like `s.location[Farmer]` is the answer.

I guess relational joins are not associative in the particular case
where any relations in the middle of the chain are one-column. This is
surprising to me, like I must have misunderstood why joins are
associative in the first place.
