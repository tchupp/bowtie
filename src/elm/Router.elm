module Router exposing (Model, Msg(..), Route(..), buildClosetRoute, init, parseRoute, update)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Url exposing (Url)
import Url.Builder
import Url.Parser as UrlParser exposing ((</>), (<?>), Parser, fragment, query, s, string, top)
import Url.Parser.Query as Query


type alias Model =
    { navKey : Navigation.Key }



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


replaceUrl : Model -> Route -> Cmd msg
replaceUrl model route =
    Navigation.replaceUrl model.navKey (routeToString route)


routeToString : Route -> String
routeToString route =
    case route of
        Dashboard ->
            Url.Builder.absolute
                [ "#/" ]
                []

        Closet id family selections ->
            Url.Builder.absolute
                [ "#/closet", id ]
                [ Url.Builder.string "family" <| Maybe.withDefault "" family
                , Url.Builder.string "selections" <| String.join "," selections
                ]

        Login ->
            Url.Builder.absolute
                [ "#/login" ]
                []

        NotFound ->
            Url.Builder.absolute
                [ "#/" ]
                []



-- ROUTES


type Route
    = Dashboard
    | Closet String (Maybe String) (List String)
    | Login
    | NotFound


parseRoute : Url -> Route
parseRoute url =
    urlFragmentToPath url
        |> UrlParser.parse routeParser
        |> Maybe.withDefault NotFound


urlFragmentToPath : Url -> Url
urlFragmentToPath url =
    { url
        | path = Maybe.withDefault "" url.fragment
        , fragment = Nothing
    }
        |> Url.toString
        |> Url.fromString
        |> Maybe.withDefault url


routeParser : Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Dashboard <| dashboardRoute
        , UrlParser.map Login <| loginRoute
        , UrlParser.map Closet <| closetRoute
        ]


queryList : String -> Query.Parser (List String)
queryList key =
    Query.custom key <| identity



-- ROUTE PARSING


dashboardRoute : Parser a a
dashboardRoute =
    top


loginRoute : Parser a a
loginRoute =
    s "login"


closetRoute : Parser (String -> Maybe String -> List String -> a) a
closetRoute =
    s "closet" </> string <?> Query.string "family" <?> queryList "selections"


buildClosetRoute : String -> Maybe String -> List String -> String
buildClosetRoute id family selections =
    Url.Builder.relative
        [ "#/closet", id ]
        [ Url.Builder.string "family" <| Maybe.withDefault "" family
        , Url.Builder.string "selections" <| String.join "," selections
        ]
