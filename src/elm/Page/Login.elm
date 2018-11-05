module Page.Login exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class, type_)


view : () -> Html msg
view _ =
    Html.div [ class "login-container" ]
        [ Html.div [ class "login-panel" ]
            [ Html.div [ class "login-form" ]
                [ loginFormRow "text" <| "username"
                , loginFormRow "password" <| "password"
                , Html.button [ class "theme-btn", class "theme-btn-primary" ] [ Html.text "login" ]
                ]
            ]
        ]


loginFormRow : String -> String -> Html msg
loginFormRow t label =
    Html.div [ class "login-form-row" ]
        [ Html.div [ class "login-form-label" ] [ Html.label [] [ Html.text label ] ]
        , Html.input [ class "login-form-input", type_ t ] []
        ]
