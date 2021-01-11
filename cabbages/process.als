abstract sig Process {
	first: lone T,
	last: lone T
}

one sig Alice extends Process {}
lone sig Bob extends Process {}
lone sig Carol extends Process {}

sig T {
	process: Process,
	prevt: lone T,
	next: lone T,
}

fact {
	prevt = ~next
	all t: T | t.next.process in t.process
	no t: T | t in t.^next  // no time loops
	first = ~process - ~process.next
	last = ~process - ~process.~next
}

assert ok {
	all t: T | some t.process.first and some t.process.last
	all t: T | t in t.process.first.*next and t.process.last in t.*next
	all p: Process | no p.first.prevt
	all p: Process | no p.last.next
	all p: Process | p.first.process in p
	all p: Process | p.last.process in p
}

check ok for 5

run {} for 9
