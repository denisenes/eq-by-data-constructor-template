{-# LANGUAGE TemplateHaskell #-}

import DeriveEqByDataConstr
import Language.Haskell.TH

data Figure = Circle Int | Square Int | Rectangle Int Int | Triangle Int Int Int
$(derivingEqByDataConstr ''Figure) -- this will make desired Eq instance 

shouldBeTrue = Square 123 == Square 123
shouldBeTrue' = Square 123 == Square 321

shouldBeFalse = Circle 123 == Square 123
shouldBeFalse' = Triangle 3 4 5 == Square 234
