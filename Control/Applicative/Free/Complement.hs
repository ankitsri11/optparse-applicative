{-# LANGUAGE GADTs #-}
module Control.Applicative.Free.Complement
  ( Ap'(..)
  ) where

import Control.Applicative
import Control.Applicative.Free

-- | Unit complement of the monad 'Ap' on the category of endofunctors.
--
-- 'Ap'' is /almost/ an ideal monad.
--
-- See <http://arxiv-web3.library.cornell.edu/abs/14'9.38'4 Coproducts of Monads
-- on Set> for more details on the unit complement of a monad.
data Ap' f a where
  Pure' :: a -> Ap' f a
  Ap' :: f a -> f b -> Ap f (a -> b -> c) -> Ap' f c

ap'ToAp :: Ap' f a -> Ap f a
ap'ToAp (Pure' x) = pure x
ap'ToAp (Ap' a b u) = u <*> liftAp a <*> liftAp b

instance Functor (Ap' f) where
  fmap f (Pure' a) = Pure' (f a)
  fmap f (Ap' x y u) = Ap' x y (comp2 <$> u)
    where comp2 g a b = f (g a b)

instance Applicative (Ap' f) where
  pure = Pure'
  Pure' f <*> y = fmap f y
  Ap' x y u <*> z = Ap' x y (flip13 <$> u <*> ap'ToAp z)
    where flip13 f a b c = f b c a
