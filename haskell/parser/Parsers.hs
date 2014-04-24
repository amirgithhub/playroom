module Parsers where

import Control.Applicative
import Data.Foldable
import Text.Parser.Char
import Text.Parser.Combinators
import Text.Parser.Token

import Syntax

parseDecls :: TokenParsing m => m [Decl]
parseDecls = many parseDecl

parseDecl :: TokenParsing m => m Decl
parseDecl = Decl <$> many parseDesc <*> (parseName <* symbol "=") <*> parseBody

parseDesc :: TokenParsing m => m String
parseDesc = token $ char '#' *> many (oneOf " \t") *> many (noneOf "\n") <* newline

parseName :: TokenParsing m => m Name
parseName = Name <$> parseIdent <*> (asum <$> optional parseParams)
  where
    parseParams = brackets $ parseName `sepBy` symbol ","

parseIdent :: TokenParsing m => m String
parseIdent = (:) <$> letter <*> many alphaNum <?> "identifier"

parseBody :: TokenParsing m => m Body
parseBody = parseObject <|> parseChoice

parseObject :: TokenParsing m => m Body
parseObject = braces $ Object <$> many parseField

parseField :: TokenParsing m => m Field
parseField = token $ Field <$> many parseDesc <*> (parseIdent <* symbol ":") <*> parseName

parseChoice :: TokenParsing m => m Body
parseChoice = Choice <$> parseName `sepBy1` symbol "|"