module Page.GettingStarted exposing (pageGettingStarted)

import Bootstrap.Button as Button
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


pageGettingStarted : () -> List (Html msg)
pageGettingStarted _ =
    [ h2 [] [ text "Getting started" ]
    , Button.button
        [ Button.success
        , Button.large
        , Button.block
        , Button.attrs []
        ]
        [ text "Click me" ]
    ]
