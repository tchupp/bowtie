module Page.Modules exposing (pageModules)

import Bootstrap.ListGroup as Listgroup
import Html exposing (..)


pageModules : () -> List (Html msg)
pageModules _ =
    [ h1 [] [ text "Modules" ]
    , Listgroup.ul
        [ Listgroup.li [] [ text "Alert" ]
        , Listgroup.li [] [ text "Badge" ]
        , Listgroup.li [] [ text "Card" ]
        ]
    ]
