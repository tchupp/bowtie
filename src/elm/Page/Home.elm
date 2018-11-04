module Page.Home exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import TopBar


view : () -> Html msg
view _ =
    let
        ( topBarModel, topBarCmd ) =
            TopBar.init
    in
    Html.div [ class "content-frame" ]
        [ Html.div [ id "top-bar-app" ]
            [ TopBar.view topBarModel ]
        , Html.div [ class "bottom" ]
            [ Html.div [ id "content" ]
                [ Html.div [ id "subpage" ]
                    [ Html.div [] [] ]
                ]
            ]
        ]
