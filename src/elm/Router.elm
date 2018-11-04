module Router exposing (Model, Msg(..), Route(..), init, update)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, fragment, s, string, top)


type alias Model =
    { navKey : Navigation.Key
    , route : Route
    }



-- INIT


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    urlUpdate url { navKey = key, route = Home }



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
