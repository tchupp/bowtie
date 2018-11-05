module TopBar exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (attribute, class, classList, href)
import Html.Events exposing (onClick)


type UserState
    = UserLoggingIn
    | UserLoggedIn
    | UserLoggedOut


type alias Model =
    { userState : UserState
    , userMenuVisible : Bool
    }



-- INIT


init : ( Model, Cmd msg )
init =
    ( { userState = UserLoggedOut, userMenuVisible = False }, Cmd.none )



-- UPDATE


type Msg
    = ToggleUserMenu
    | LogIn
    | LogOut


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        ToggleUserMenu ->
            ( { model | userMenuVisible = not model.userMenuVisible }, Cmd.none )

        LogIn ->
            ( { model | userState = UserLoggingIn }, Cmd.none )

        LogOut ->
            ( { model | userState = UserLoggedOut }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    Html.nav
        [ classList
            [ ( "module-topbar", True )
            , ( "top-bar", True )
            ]
        ]
        [ div
            [ class "topbar-logo" ]
            [ Html.a [ class "logo-image-link", href "#" ] [] ]
        , Html.ul [ class "groups" ] []
        , div [ class "topbar-login" ]
            [ div [ class "topbar-user-info" ]
                [ viewUserInfo model.userState model.userMenuVisible ]
            ]
        ]


viewUserInfo : UserState -> Bool -> Html Msg
viewUserInfo state userMenuVisible =
    case state of
        UserLoggingIn ->
            div [] []

        UserLoggedIn ->
            div [ class "user-info" ]
                [ div
                    [ onClick ToggleUserMenu, class "user-id" ]
                    [ text "<|  userDisplayName user" ]
                , div
                    [ onClick LogOut
                    , classList
                        [ ( "user-menu", True )
                        , ( "hidden", not userMenuVisible )
                        ]
                    ]
                    [ Html.a
                        []
                        [ text "logout" ]
                    ]
                ]

        UserLoggedOut ->
            div
                [ class "user-id", onClick LogIn ]
                [ Html.a
                    [ href "#login"
                    , class "login-button"
                    ]
                    [ text "login" ]
                ]
