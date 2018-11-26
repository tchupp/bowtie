module Page.NotFound exposing (pageNotFound)

import Html exposing (..)
import Html.Attributes exposing (class, href, src)


pageNotFound : () -> Html msg
pageNotFound _ =
    Html.div [ class "notfound" ]
        [ Html.div [ class "title" ] [ Html.text "404" ]
        , Html.div [ class "reason" ] [ Html.text "this page was not found" ]
        , Html.div [ class "help-message" ]
            [ Html.text "Not to worry, you can head"
            , Html.br [] []
            , Html.text "back to the "
            , Html.a [ href "#/" ] [ Html.text "home page" ]
            ]
        ]
