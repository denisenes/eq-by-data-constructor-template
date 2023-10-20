{-# LANGUAGE TemplateHaskell #-}

{-
    Suppose you have some data type

    data Test = A Int | B Double | C String String | D Int

    and you have the greatest desire to determine if
    values of that type are equal by data constructor
    without taking into account field values.

    For example we are expecting such behavior:

    ghci> (A 123) == (C "a" "b")
    False
    ghci> (A 123) == (A 312) -- !!!
    True

    In such situation deriving Eq can't help us because it
    determines equality with respect to internal values:

    ghci> (A 123) == (A 312) -- !!!
    False

    This template is considered to solve described problem. 
    Usage:

    import DeriveEqByDataConstr

    data Test = A Int | B Double | C String String | D Int
    $(derivingEqByDataConstr ''Test)
-}

module DeriveEqByDataConstr
    (derivingEqByDataConstr)
    where

import Language.Haskell.TH
import Control.Monad
import Data.List
import GHC.Types

generateConP :: Con -> Pat
generateConP (NormalC cname bangTypes) =
    let typesN = length bangTypes in
    ConP cname [] (replicate typesN WildP)

generateEqDecls :: [Con] -> Q [Clause]
generateEqDecls constrs = do
    return (map (\constr -> Clause
        [generateConP constr, generateConP constr]
        (NormalB $ ConE 'True) []) constrs)

derivingEqByDataConstr :: Name -> Q [Dec]
derivingEqByDataConstr t = do
    TyConI (DataD _ _ _ _ constrs _) <- reify t

    initD <- 
        [d|
        instance Eq $(conT t) where
            _ == _ = False 
        |]

    decls <- generateEqDecls constrs

    let [InstanceD mbOvlp [] app [FunD eqf [finalClause]]] = initD in
        return [InstanceD mbOvlp [] app [FunD eqf (decls ++ [finalClause])]]
