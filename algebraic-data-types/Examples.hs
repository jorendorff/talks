-- Make sure all the examples compile. Build with:
--   ghc -c Examples.hs

module Examples where
import Prelude hiding (Bool, False, True)

data Bool = False | True


data TimeUnit = Year | Month | Day | Hour | Minute | Second

unitToEnglish Year = "years"
unitToEnglish Month = "months"
unitToEnglish Day = "days"
unitToEnglish Hour = "hours"
unitToEnglish Minute = "minutes"
unitToEnglish Second = "seconds"


data RoughTime = InThePast Int TimeUnit
               | JustNow
               | InTheFuture Int TimeUnit

when = InThePast 27 Day

toEnglish :: RoughTime -> String
toEnglish JustNow = "just now"
toEnglish (InThePast num unit) =
  show num ++ " " ++ unitToEnglish unit ++ " ago"
toEnglish (InTheFuture num unit) =
  show num ++ " " ++ unitToEnglish unit ++ " from now"


data JSON = JNull
          | JBool Bool
          | JNum Float
          | JStr String
          | JArray [JSON]
          | JObject [(String, JSON)]


data Maybe a = Nothing | Just a


data Tree a = Empty | Node (Tree a, a, Tree a)


data Nat = Zero | Succ Nat
  deriving (Show, Eq, Ord)

infinity = Succ infinity
