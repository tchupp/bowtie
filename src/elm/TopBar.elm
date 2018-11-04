module TopBar exposing (Model, UserState(..), init, view)

import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    { userState : UserState
    , userMenuVisible : Bool
    }


init : ( Model, Cmd msg )
init =
    ( { userState = UserLoggedOut, userMenuVisible = False }, Cmd.none )


view : Model -> Html msg
view model =
    Html.nav
        [ classList
            [ ( "module-topbar", True )
            , ( "top-bar", True )
            ]
        ]
        [ Html.div
            [ classList [ ( "topbar-logo", True ) ] ]
            [ Html.a [ class "logo-image-link", href "/" ] [] ]
        , Html.ul [ class "groups" ] []
        , Html.div [ class "topbar-login" ]
            [ Html.div [ class "topbar-user-info" ]
                [ viewUserInfo model.userState False ]
            ]
        ]


type UserState
    = UserLoggingIn
    | UserLoggedIn
    | UserLoggedOut


viewUserInfo : UserState -> Bool -> Html msg
viewUserInfo state userMenuVisible =
    case state of
        UserLoggingIn ->
            Html.div [] []

        UserLoggedIn ->
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

        UserLoggedOut ->
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
