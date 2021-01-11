open util/ordering[Crossing]

abstract sig Object {
  eats: set Object
}

one sig Wolf extends Object {}
one sig Goat extends Object {}
one sig Cabbages extends Object {}

abstract sig RiverBank {}
one sig Here extends RiverBank {}
one sig There extends RiverBank {}

fact howWeEat {
	eats = (Wolf -> Goat) + (Goat -> Cabbages)
}

sig Crossing {
	destination: RiverBank,
	thereBefore: set Object,
	cargo: lone Object,
	thereAfter: set Object
}

pred valid {
	// At the outset, everything is here, not there.
	no first.thereBefore

	// The first crossing goes over there.
	first.destination = There

	// No continuity errors! The end state of each crossing (except the last)
	// is the start state of the next crossing.
	all c: Crossing - last | c.thereAfter = c.next.thereBefore

	// The destination alternates between Here and There.
	all c: Crossing - last | c.destination != c.next.destination

	// When going over there...
	all c: Crossing | c.destination = There => {
		no c.cargo & c.thereBefore
		c.thereAfter = c.thereBefore + c.cargo
		no a: Object, b: a.eats | a not in c.thereAfter and b not in c.thereAfter
	}

	// On the return trip...
	all c: Crossing | c.destination = Here => {
		c.cargo in c.thereBefore
		c.thereAfter = c.thereBefore - c.cargo
		no a: Object, b: a.eats | a in c.thereAfter and b in c.thereAfter
	}

	// The last crossing goes over there.
	last.destination = There

	// At the end, everything is there, not here.
	last.thereAfter = Object
}

run valid for 7
