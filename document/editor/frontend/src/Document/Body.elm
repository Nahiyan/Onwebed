module Document.Body exposing (addElementAfterElement, addElementBeforeElement, addElementInsideElementAsFirstChild, addElementInsideElementAsLastChild, applyIndex, mapElements, markAlternateHierarchy, removeElement, replaceElement)

import Document.Element exposing (Element(..))
import Tree exposing (Tree)
import Tree.Zipper


applyIndex : Tree Element -> Tree Element
applyIndex tree =
    Tree.indexedMap
        (\index element ->
            case element of
                Bone bone ->
                    Bone { bone | id = index }

                Flesh flesh ->
                    Flesh { flesh | id = index }

                _ ->
                    element
        )
        tree


markAlternateHierarchy : Tree.Zipper.Zipper Element -> Tree Element
markAlternateHierarchy zipper =
    let
        newZipper =
            case Tree.Zipper.label zipper of
                Bone currentBone ->
                    case Tree.Zipper.parent zipper of
                        Just parentZipper ->
                            let
                                parent =
                                    parentZipper |> Tree.Zipper.label
                            in
                            case parent of
                                Bone parentBone ->
                                    zipper |> Tree.Zipper.replaceLabel (Bone { currentBone | alternateHierarchy = not parentBone.alternateHierarchy }) |> Tree.Zipper.forward

                                _ ->
                                    Tree.Zipper.forward zipper

                        _ ->
                            Tree.Zipper.forward zipper

                _ ->
                    Tree.Zipper.forward zipper
    in
    case newZipper of
        Nothing ->
            Tree.Zipper.toTree zipper

        Just justNewZipper ->
            markAlternateHierarchy justNewZipper


checkElementWithIndex : Int -> Element -> Bool
checkElementWithIndex index element =
    case element of
        Bone bone ->
            bone.id == index

        Flesh flesh ->
            flesh.id == index

        _ ->
            False


replaceElement : Int -> (Element -> Element) -> Tree Element -> Tree Element
replaceElement index replace tree =
    let
        zipper =
            Tree.Zipper.fromTree tree
    in
    case Tree.Zipper.findFromRoot (checkElementWithIndex index) zipper of
        Just newZipper ->
            let
                replacement =
                    replace (newZipper |> Tree.Zipper.label)
            in
            Tree.Zipper.replaceLabel replacement newZipper
                |> Tree.Zipper.toTree

        Nothing ->
            tree


removeElement : Int -> Tree Element -> Tree Element
removeElement index tree =
    let
        zipper =
            Tree.Zipper.fromTree tree
    in
    case Tree.Zipper.findFromRoot (checkElementWithIndex index) zipper of
        Just newZipper ->
            case Tree.Zipper.removeTree newZipper of
                Just newZipperAfterRemoval ->
                    newZipperAfterRemoval |> Tree.Zipper.toTree |> applyIndex

                Nothing ->
                    Tree.tree Root []

        Nothing ->
            tree


mapElements : (Element -> Element) -> Tree Element -> Tree Element
mapElements map tree =
    Tree.map map tree


addElementBeforeElement : Int -> Element -> Tree Element -> Tree Element
addElementBeforeElement index element tree =
    let
        zipper =
            Tree.Zipper.fromTree tree
    in
    case Tree.Zipper.findFromRoot (checkElementWithIndex index) zipper of
        Just newZipper ->
            let
                newTree =
                    Tree.tree element []
            in
            Tree.Zipper.prepend newTree newZipper
                |> Tree.Zipper.toTree
                |> applyIndex

        Nothing ->
            tree


addElementAfterElement : Int -> Element -> Tree Element -> Tree Element
addElementAfterElement index element tree =
    let
        zipper =
            Tree.Zipper.fromTree tree
    in
    case Tree.Zipper.findFromRoot (checkElementWithIndex index) zipper of
        Just newZipper ->
            let
                newTree =
                    Tree.tree element []
            in
            Tree.Zipper.append newTree newZipper
                |> Tree.Zipper.toTree
                |> applyIndex

        Nothing ->
            tree


addElementInsideElementAsFirstChild : Int -> Element -> Tree Element -> Tree Element
addElementInsideElementAsFirstChild index element tree =
    let
        zipper =
            Tree.Zipper.fromTree tree
    in
    case Tree.Zipper.findFromRoot (checkElementWithIndex index) zipper of
        Just newZipper ->
            let
                newTree =
                    Tree.tree element []

                newChildren =
                    newTree :: (newZipper |> Tree.Zipper.children)

                currentElement =
                    newZipper |> Tree.Zipper.label

                replacement =
                    Tree.tree currentElement newChildren
            in
            Tree.Zipper.replaceTree replacement newZipper
                |> Tree.Zipper.toTree
                |> applyIndex

        Nothing ->
            tree


addElementInsideElementAsLastChild : Int -> Element -> Tree Element -> Tree Element
addElementInsideElementAsLastChild index element tree =
    let
        zipper =
            Tree.Zipper.fromTree tree
    in
    case Tree.Zipper.findFromRoot (checkElementWithIndex index) zipper of
        Just newZipper ->
            let
                newTree =
                    Tree.tree element []

                newChildren =
                    List.append (newZipper |> Tree.Zipper.children) [ newTree ]

                currentElement =
                    newZipper |> Tree.Zipper.label

                replacement =
                    Tree.tree currentElement newChildren
            in
            Tree.Zipper.replaceTree replacement newZipper
                |> Tree.Zipper.toTree
                |> applyIndex

        Nothing ->
            tree