module Page.Home exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import TopBar


view : () -> Html msg
view _ =
    div [ class "dashboard" ]
        [ div [ class "dashboard-content" ]
            [ div [ class "dashboard-pipeline", class "dashboard-paused" ]
                [ div [ class "dashboard-pipeline-banner" ]
                    []
                , div [ class "dashboard-pipeline-content" ]
                    [ a [ href "#closet/fdsa" ]
                        [ div [ class "dashboard-pipeline-name" ]
                            [ text "hello-world" ]
                        ]
                    , div [ class "pipeline-grid" ]
                        [ div [ class "parallel-grid" ]
                            [ div [ class "node no-builds" ]
                                []
                            ]
                        ]
                    ]
                ]
            ]
        ]
