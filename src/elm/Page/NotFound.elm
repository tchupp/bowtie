module Page.NotFound exposing (pageNotFound)

import Html exposing (..)


pageNotFound : List (Html msg)
pageNotFound =
    [ h1 [] [ text "Not found" ]
    , text "Sorry couldn't find that page"
    ]
