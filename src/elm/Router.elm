module Router exposing (Model, Msg(..), Route(..), init, parseRoute, update)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, fragment, s, string, top)


type alias Model =
    { navKey : Navigation.Key
    }



-- INIT


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { navKey = key }, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked req ->
            case req of
                Browser.Internal url ->
                    ( model, Navigation.pushUrl model.navKey <| Url.toString url )

                Browser.External href ->
                    ( model, Navigation.load href )



-- ROUTES


type Route
    = Dashboard
    | Closet String
    | Login
    | NotFound


parseRoute : Url -> Route
parseRoute url =
    replaceFragment url
        |> UrlParser.parse routeParser
        |> Maybe.withDefault NotFound


replaceFragment : Url -> Url
replaceFragment url =
    let
        path =
            Maybe.withDefault "" url.fragment
    in
    { url | path = path, fragment = Nothing }


routeParser : Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Dashboard top
        , UrlParser.map Login (s "login" </> top)
        , UrlParser.map Closet (s "closet" </> string)
        ]
