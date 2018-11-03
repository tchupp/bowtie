module Page.Home exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : () -> Html msg
view _ =
    Html.div [ class "content-frame" ]
        [ Html.div [ id "top-bar-app" ]
            [ topBarView () ]
        , Html.div [ class "bottom" ]
            [ Html.div [ id "content" ]
                [ Html.div [ id "subpage" ]
                    [ Html.div [] [] ]
                ]
            ]
        ]


topBarView : () -> Html msg
topBarView _ =
    Html.nav
        [ classList
            [ ( "module-topbar", True )
            , ( "top-bar", True )
            , ( "test", True )
            , ( "paused", False )
            ]
        ]
        [ Html.div
            [ classList [ ( "topbar-logo", True ) ] ]
            [ Html.a [ class "logo-image-link", href "/" ] [] ]
        , Html.ul [ class "groups" ] []
        , Html.div [ class "topbar-login" ]
            [ Html.div [ class "topbar-user-info" ]
                [ viewUserInfo LoggedOut False ]
            ]
        ]


type UserState
    = LoggedIn
    | LoggedOut


viewUserInfo : UserState -> Bool -> Html msg
viewUserInfo state userMenuVisible =
    case state of
        LoggedIn ->
            Html.div [ class "user-info" ]
                [ Html.div
                    [ class "user-id"

                    {- , onClick ToggleUserMenu -}
                    ]
                    [ Html.text "<|  userDisplayName user"
                    ]
                , Html.div
                    [ classList [ ( "user-menu", True ), ( "hidden", not userMenuVisible ) ]

                    {- , onClick LogOut -}
                    ]
                    [ Html.a
                        [ Html.Attributes.attribute "aria-label" "Log Out"
                        ]
                        [ Html.text "logout"
                        ]
                    ]
                ]

        LoggedOut ->
            Html.div
                [ class "user-id"

                {- , onClick LogIn -}
                ]
                [ Html.a
                    [ href "/login"
                    , Html.Attributes.attribute "aria-label" "Log In"
                    , class "login-button"
                    ]
                    [ Html.text "login"
                    ]
                ]
