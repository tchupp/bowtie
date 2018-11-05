module Page.Closet exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import TopBar


view : () -> Html msg
view _ =
    div []
        [ h1 [] [ text "Closet!" ]
        ]
