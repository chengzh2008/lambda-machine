module Data.Syntax
  ( Definition(..)
  , defToSyntax
  , defToDoc
  , Syntax(..)
  ) where

import Prelude (class Show, map, otherwise, pure, show, (+), (<$>), (<>), (==))
import Control.Alt ((<|>))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Generic (class Generic, gShow)
import Data.List (List(..), foldr, intercalate)

import Data.PrettyPrint (class PrettyPrint, Doc, doc, parensIf, prettyPrint, raw, sugar)
import Data.Name (Name)

type Definition =
  { name   :: Name
  , args   :: Array Name
  , syntax :: Syntax
  }

defToSyntax :: Definition -> Syntax
defToSyntax def = foldr Lambda def.syntax def.args

defToDoc :: Definition -> Doc String
defToDoc def = pure (show def.name) <> prettyArgs def.args <> pure " = " <> prettyPrint def.syntax
 where
  prettyArgs [] = pure ""
  prettyArgs as = pure " " <> pure (intercalate " " (map show as))

data Syntax
  = Var Name
  | Lambda Name Syntax
  | Apply Syntax Syntax

derive instance genericSyntax :: Generic Syntax
instance showSyntax :: Show Syntax where
  show = gShow

isComposite :: Syntax -> Boolean
isComposite (Var _) = false
isComposite _       = true

isLambda :: Syntax -> Boolean
isLambda (Lambda _ _) = true
isLambda _            = false

tryFromChurch :: Syntax -> Maybe String
tryFromChurch (Lambda s (Lambda z body)) =
  show <$> walk body
 where
  walk (Apply (Var s') arg)
    | s' == s = (_ + 1) <$> walk arg
    | otherwise = Nothing
  walk (Var z')
    | z' == z = pure 0
    | otherwise = Nothing
  walk _ = Nothing
tryFromChurch _ = Nothing

tryFromList :: Syntax -> Maybe String
tryFromList (Lambda c (Lambda n body)) =
  listToString <$> walk body
 where
  walk (Apply (Apply (Var c') x) xs)
    | c' == c = Cons (sugar (prettySyntax x)) <$> walk xs
    | otherwise = Nothing
  walk (Var n')
    | n' == n = pure Nil
    | otherwise = Nothing
  walk _ = Nothing
tryFromList _ = Nothing

listToString :: List String -> String
listToString xs = "[" <> intercalate ", " xs <> "]"

prettySyntax :: Syntax -> Doc String
prettySyntax = walk false
 where
  walk inApp e =
    case e of
      Var v ->
        pure (show v)
      l@(Lambda n b) ->
        let
          simple = parensIf inApp (pure "λ" <> pure (show n) <> pure ". " <> walk false b)
          literal = tryFromChurch l <|> tryFromList l
        in
          doc {raw: raw simple, sugar: fromMaybe (sugar simple) literal}
      Apply f a ->
        parensIf inApp (walk (isLambda f) f <> pure " " <> walk (isComposite a) a)

instance prettyPrintSyntax :: PrettyPrint Syntax where
  prettyPrint = prettySyntax
