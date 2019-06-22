{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RebindableSyntax #-}

module HotAir.Nat
  ( Nat
  , zero
  , succ
  , nat
  , pred
  , fromNum
  , toNum
  ) where

import GHC.Num (Num((+), (-), fromInteger))

import HotAir.Bool (Bool, ifThenElse)
import HotAir.Eq (Eq((==)))
import HotAir.Function ((.))
import HotAir.Maybe (Maybe, just, maybe, nothing)
import HotAir.Ord (Ord((<=)))

newtype Nat =
  Nat (forall c. c -> (Nat -> c) -> c)

zero :: Nat
zero = Nat (\z _ -> z)

succ :: Nat -> Nat
succ n = Nat (\_ s -> s n)

nat :: c -> (Nat -> c) -> Nat -> c
nat z s (Nat n) = n z s

pred :: Nat -> Nat
pred = nat zero (\n -> n)

foldNat :: c -> (c -> c) -> Nat -> c
foldNat z f = nat z (f . foldNat z f)

toNum :: Num n => Nat -> n
toNum = foldNat 0 (+ 1)

unfoldNat :: (c -> Maybe c) -> c -> Nat
unfoldNat f c = maybe zero (succ . unfoldNat f) (f c)

fromNum :: (Ord n, Num n) => n -> Nat
fromNum =
  unfoldNat
    (\n ->
       if n <= 0
         then nothing
         else just (n - 1))