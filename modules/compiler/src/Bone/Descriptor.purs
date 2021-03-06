module Bone.Descriptor (emptyElement, toElements, Element) where

import Prelude
import Data.String as String
import Data.Array as Array

type Element
  = { name :: String
    , id :: String
    , attributes :: String
    , htmlClass :: String
    , htmlId :: String
    , hasClosingTag :: Boolean
    }

data ElementProperty
  = Name
  | Id
  | Attributes
  | XClass
  | XId
  | HasClosingTag

emptyElement :: Element
emptyElement =
  { name: ""
  , id: ""
  , attributes: ""
  , htmlClass: ""
  , htmlId: ""
  , hasClosingTag: true
  }

type Model
  = { mode :: Mode
    , currentCharacter :: String
    , restOfCharacters :: String
    , currentElement :: Element
    , elements :: Array Element
    }

data CharacterType
  = StartOfAttributes
  | EndOfAttributes
  | StartOfXClass
  | StartOfXId
  | StartOfId
  | Whitespace
  | Null
  | Other

instance eqCharacterType :: Eq CharacterType where
  eq Whitespace Whitespace = true
  eq Null Null = true
  eq Other Other = true
  eq StartOfId StartOfId = true
  eq StartOfXId StartOfXId = true
  eq StartOfXClass StartOfXClass = true
  eq EndOfAttributes EndOfAttributes = true
  eq StartOfAttributes StartOfAttributes = true
  eq _ _ = false

data Mode
  = Append ElementProperty

getCharacterType :: String -> CharacterType
getCharacterType character = case character of
  "(" -> StartOfAttributes
  ")" -> EndOfAttributes
  "." -> StartOfXClass
  "#" -> StartOfXId
  "@" -> StartOfId
  "" -> Null
  _ ->
    if String.trim character # String.null then
      Whitespace
    else
      Other

toElements :: String -> Array Element
toElements descriptor =
  toElements'
    { mode: Append Name
    , currentCharacter: String.take 1 descriptor
    , restOfCharacters: String.drop 1 descriptor
    , currentElement: emptyElement
    , elements: []
    }

toElements' :: Model -> Array Element
toElements' model =
  if String.null model.currentCharacter then
    (endElement model).elements # Array.filter (\element -> element.name # String.null # not)
  else
    let
      characterType = getCharacterType model.currentCharacter

      newModel = case model.mode of
        Append Name ->
          if characterType == Other then
            appendElementProperty Name model
          else
            handleStartOfElement characterType model
        Append Attributes ->
          if characterType == EndOfAttributes then
            model { mode = Append Name }
          else
            appendElementProperty Attributes model
        Append XClass ->
          if characterType == Other then
            appendElementProperty XClass model
          else
            handleStartOfElement characterType model { currentElement = model.currentElement { htmlClass = model.currentElement.htmlClass <> " " } }
        Append XId ->
          if characterType == Other then
            appendElementProperty XId model
          else
            handleStartOfElement characterType model
        Append Id ->
          if characterType == Other then
            appendElementProperty Id model
          else
            handleStartOfElement characterType model
        _ -> model
    in
      toElements'
        ( newModel
            { currentCharacter = model.restOfCharacters # String.take 1
            , restOfCharacters = model.restOfCharacters # String.drop 1
            }
        )

handleStartOfElement :: CharacterType -> Model -> Model
handleStartOfElement characterType model = case characterType of
  StartOfAttributes -> model { mode = Append Attributes }
  StartOfXClass ->
    let
      nextCharacterType = getCharacterType $ model.restOfCharacters # String.take 1
    in
      if nextCharacterType == Whitespace || nextCharacterType == Null then
        model { currentElement = model.currentElement { hasClosingTag = false }, mode = Append Name }
      else
        model { mode = Append XClass }
  StartOfXId -> model { mode = Append XId }
  StartOfId -> model { mode = Append Id }
  Whitespace -> endElement model
  _ -> model

endElement :: Model -> Model
endElement model =
  model
    { elements =
      Array.snoc model.elements model.currentElement
    , mode = Append Name
    , currentElement = emptyElement
    }

appendElementProperty :: ElementProperty -> Model -> Model
appendElementProperty property model =
  let
    newElement = case property of
      Name -> model.currentElement { name = model.currentElement.name <> model.currentCharacter }
      Id -> model.currentElement { id = model.currentElement.id <> model.currentCharacter }
      XId -> model.currentElement { htmlId = model.currentElement.htmlId <> model.currentCharacter }
      XClass -> model.currentElement { htmlClass = model.currentElement.htmlClass <> model.currentCharacter }
      Attributes -> model.currentElement { attributes = model.currentElement.attributes <> model.currentCharacter }
      _ -> model.currentElement
  in
    model { currentElement = newElement }
