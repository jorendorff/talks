sig Person {
	loves: set Person
}

one sig Balin extends Person {}
one sig Dwalin extends Person {}
one sig Óin extends Person {}
one sig Glóin extends Person {}
one sig Bombur extends Person {}

fact {
	loves = Balin -> Dwalin
	        + Óin -> Glóin
	        + Bombur -> Balin
	        + Bombur -> Glóin
	        + Bombur -> Bombur
}

run {} for 3
