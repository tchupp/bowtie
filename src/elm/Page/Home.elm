module Page.Home exposing (pageHome)

import Html exposing (..)
import Html.Attributes exposing (..)


pageHome : () -> List (Html msg)
pageHome _ =
    [ h1 [] [ text "Home" ] ]
