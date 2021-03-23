abstract sig Person {}

sig Knight extends Person {}
sig Knave extends Person {}

pred Puzzle {
  #Person = 2
  some disj A, B :Person {
    A in Knight <=> (A + B) in Knave
  }
}

run Puzzle for 10
