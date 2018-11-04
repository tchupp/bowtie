module Main exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Closet
import Page.Home
import Page.Login
import Page.NotFound
import TopBar
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, fragment, s, string, top)


type alias Model =
    { navKey : Navigation.Key
    , route : Route
    }



-- INIT


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( model, urlCmd ) =
            urlUpdate url { navKey = key, route = Home }

        ( topBarModel, topBarCmd ) =
            TopBar.init
    in
    ( model, Cmd.batch [ urlCmd, topBarCmd ] )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = UrlChanged Url
    | LinkClicked UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked req ->
            case req of
                Browser.Internal url ->
                    ( model, Navigation.pushUrl model.navKey <| Url.toString url )

                Browser.External href ->
                    ( model, Navigation.load href )

        UrlChanged url ->
            urlUpdate url model


urlUpdate : Url -> Model -> ( Model, Cmd Msg )
urlUpdate url model =
    ( { model | route = decode url }, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Bowtie"
    , body =
        [ mainContent model ]
    }


mainContent : Model -> Html Msg
mainContent model =
    case model.route of
        Home ->
            Page.Home.view ()

        Login ->
            Page.Login.view ()

        Closet _ ->
            Page.Closet.view ()

        NotFound ->
            Page.NotFound.pageNotFound ()



-- ROUTES


type Route
    = Home
    | Closet String
    | Login
    | NotFound


decode : Url -> Route
decode url =
    let
        path =
            Maybe.withDefault "" url.fragment
    in
    { url | path = url.path, fragment = Nothing }
        |> UrlParser.parse routeParser
        |> Maybe.withDefault NotFound


routeParser : Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Home top
        , UrlParser.map Login (s "login" </> top)
        , UrlParser.map Closet (s "closet" </> string)
        ]



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
