module Syntax where

import Data.List
import Data.Maybe

{-

tree[a] = {
  root: a
  forest: forest[a]
}

forest[a] = array[tree[a]]

-}

data Decl = Decl [String] Name Body deriving (Eq)

instance Show Decl where
    show (Decl descs name body) = unlines (map ("# " ++) descs) ++ show name ++ " = " ++ show body

data Name = Name String [Name] deriving (Eq)

instance Show Name where
    show (Name constr []) = constr
    show (Name constr params) = constr ++ "[" ++ intercalate ", " (map show params) ++ "]"

data Body = Object [Field] | Choice [Choice] deriving (Eq)

instance Show Body where
    show (Object fields) = "{\n" ++ intercalate "\n" (map show fields) ++ "\n}"
    show (Choice choices) = showChoices choices

data Field = Field [String] String Name (Maybe String) deriving (Eq)

instance Show Field where
    show (Field descs key typ desc) = concat
        [ unlines (map ("  # " ++) descs)
        , "  " ++ key ++ ": " ++ show typ
        , maybe "" (" # " ++) desc
        ]

data Choice = TypeChoice [String] Name (Maybe String) deriving (Eq)

instance Show Choice where
    show (TypeChoice [] name Nothing) = show name
    show (TypeChoice descs name desc) = concat
        [ unlines (map ("  # " ++) descs)
        , "  | " ++ show name
        , maybe "" (" # " ++) desc
        ]

showChoices :: [Choice] -> String
showChoices choices
    | all (\(TypeChoice descs _ desc) -> null descs && isNothing desc) choices = intercalate " | " (map show choices)
    | otherwise = "\n" ++ unlines (map showChoiceWithDesc choices)
  where
    showChoiceWithDesc (TypeChoice [] name desc) = "  | " ++ show name ++ maybe "" (" # " ++) desc
    showChoiceWithDesc choice = show choice
