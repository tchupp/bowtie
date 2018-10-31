module Main exposing (main)

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Modal as Modal
import Bootstrap.Navbar as Navbar
import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.GettingStarted exposing (pageGettingStarted)
import Page.Home exposing (pageHome)
import Page.Modules exposing (pageModules)
import Page.NotFound exposing (pageNotFound)
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, s, top)


type alias Model =
    { navKey : Navigation.Key
    , route : Route
    , navState : Navbar.State
    }


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = UrlChange
        }



-- INIT


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( navState, navCmd ) =
            Navbar.initialState NavMsg

        ( model, urlCmd ) =
            urlUpdate url { navKey = key, navState = navState, route = Home }
    in
    ( model, Cmd.batch [ urlCmd, navCmd ] )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg



-- UPDATE


type Msg
    = UrlChange Url
    | ClickedLink UrlRequest
    | NavMsg Navbar.State


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink req ->
            case req of
                Browser.Internal url ->
                    ( model, Navigation.pushUrl model.navKey <| Url.toString url )

                Browser.External href ->
                    ( model, Navigation.load href )

        UrlChange url ->
            urlUpdate url model

        NavMsg state ->
            ( { model | navState = state }
            , Cmd.none
            )


urlUpdate : Url -> Model -> ( Model, Cmd Msg )
urlUpdate url model =
    let
        route =
            decode url
    in
    ( { model | route = route }, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Bowtie"
    , body =
        [ div []
            [ menu NavMsg <| model.navState
            , mainContent model
            ]
        ]
    }


menu : (Navbar.State -> msg) -> Navbar.State -> Html msg
menu toMsg state =
    Navbar.config toMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [ href "#" ] [ text "Bowtie" ]
        |> Navbar.view state


mainContent : Model -> Html Msg
mainContent model =
    Grid.container [] <|
        case model.route of
            Home ->
                pageHome ()

            GettingStarted ->
                pageGettingStarted ()

            Modules ->
                pageModules ()

            NotFound ->
                pageNotFound



-- ROUTES


type Route
    = Home
    | GettingStarted
    | Modules
    | NotFound


decode : Url -> Route
decode url =
    let
        path =
            Maybe.withDefault "" url.fragment
    in
    { url | path = path, fragment = Nothing }
        |> UrlParser.parse routeParser
        |> Maybe.withDefault NotFound


routeParser : Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Home top
        , UrlParser.map GettingStarted (s "getting-started")
        , UrlParser.map Modules (s "modules")
        ]
