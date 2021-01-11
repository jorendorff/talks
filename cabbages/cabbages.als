open util/ordering[Snapshot]

abstract sig Object {
  eats: set Object
}

one sig Wolf extends Object {}
one sig Goat extends Object {}
one sig Cabbages extends Object {}
one sig Boat extends Object {}

fact foodWeb {
	eats = (Wolf -> Goat) + (Goat -> Cabbages)
}

sig Riverbank {}

fact twoSidesToEveryRiver {
	#Riverbank = 2
}

sig Snapshot {
	location: Object -> one Riverbank
}

fact goals {
	one first.location[Object]  // all together at first
	one last.location[Object]  // and at the end
	first.location[Boat] != last.location[Boat]  // we got across
}

fact safety {
	no t: Snapshot |
		some a: Object, b: a.eats |
			t.location[a] = t.location[b] and
			t.location[Boat] != t.location[b]
}

fact movement {
	all t: Snapshot - last |
		some here, there: Riverbank, cargo: Object | {
			t.location[Boat] = here
			here != there
			t.next.location = t.location - (Boat -> here) - (cargo -> here)
				+ (Boat -> there) + (cargo -> there)
		}
}

assert boatAlwaysMoves {
	all t: Snapshot - last | t.location[Boat] != t.next.location[Boat]
}

run {} for 8

check boatAlwaysMoves for 10
