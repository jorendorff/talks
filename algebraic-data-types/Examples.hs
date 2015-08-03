-- Make sure all the examples compile. Build with:
--   ghc -c Examples.hs

module Examples where
import Prelude hiding (Bool, False, True)


-- Example: Bool
data Bool = False | True


-- Example: TimeUnit
data TimeUnit = Year | Month | Day | Hour | Minute | Second

unitToEnglish Year = "years"
unitToEnglish Month = "months"
unitToEnglish Day = "days"
unitToEnglish Hour = "hours"
unitToEnglish Minute = "minutes"
unitToEnglish Second = "seconds"


-- Example: RoughTime
data RoughTime = InThePast Int TimeUnit
               | JustNow
               | InTheFuture Int TimeUnit

when = InThePast 27 Day      -- "27 days ago"

toEnglish :: RoughTime -> String
toEnglish JustNow = "just now"
toEnglish (InThePast num unit) =
  show num ++ " " ++ unitToEnglish unit ++ " ago"
toEnglish (InTheFuture num unit) =
  show num ++ " " ++ unitToEnglish unit ++ " from now"


-- Example: JSON
data JSON = JNull
          | JBool Bool
          | JNum Float
          | JStr String
          | JArray [JSON]
          | JObject [(String, JSON)]


-- Example: Maybe
data Maybe a = Nothing | Just a


-- Example: Tree
data Tree a = Empty | Node (Tree a, a, Tree a)


-- Product type example: LunchSpecial
data Curry = Red | Green | Panang | Massaman  --  4 curries
data Stuff = Chicken | Pork | Tofu            --  3 "meats"

type LunchSpecial = (Curry, Stuff)            -- 12 combinations


-- Infinity!
data Nat = Zero | Succ Nat
  deriving (Show, Eq, Ord)

infinity = Succ infinity
