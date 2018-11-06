module Main exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Closet
import Page.Home
import Page.Login
import Page.NotFound
import Router
import TopBar
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, fragment, s, string, top)


type alias Model =
    { route : Router.Route
    , routerModel : Router.Model
    , topBarModel : TopBar.Model
    , pageModel : PageModel
    }


type PageModel
    = HomeModel Page.Home.Model
    | LoginModel ()
    | NotFoundModel ()
    | ClosetModel ()



-- INIT


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        route =
            Router.parseRoute url

        ( pageModel, pageCmd ) =
            initPageModel () route

        ( routerModel, routerCmd ) =
            Router.init () url navKey

        ( topBarModel, topBarCmd ) =
            TopBar.init

        model =
            { route = route
            , routerModel = routerModel
            , topBarModel = topBarModel
            , pageModel = pageModel
            }

        cmd =
            Cmd.batch
                [ Cmd.map RouterMsg routerCmd
                , topBarCmd
                , pageCmd
                ]
    in
    ( model, cmd )


initPageModel : () -> Router.Route -> ( PageModel, Cmd Msg )
initPageModel _ route =
    case route of
        Router.Home ->
            let
                ( model, cmd ) =
                    Page.Home.init

                homeCmd =
                    Cmd.map HomeMsg cmd
            in
            ( HomeModel model, Cmd.map PageMsg homeCmd )

        Router.Login ->
            ( LoginModel (), Cmd.none )

        Router.Closet _ ->
            ( ClosetModel (), Cmd.none )

        Router.NotFound ->
            ( NotFoundModel (), Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = RouterMsg Router.Msg
    | TopBarMsg TopBar.Msg
    | PageMsg PageMsg
    | RouteChanged Router.Route


type PageMsg
    = HomeMsg Page.Home.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouteChanged route ->
            updateRoute route model

        PageMsg submsg ->
            updatePage submsg model

        RouterMsg submsg ->
            let
                ( routerModel, routerCmd ) =
                    Router.update submsg model.routerModel
            in
            ( { model | routerModel = routerModel }, Cmd.map RouterMsg routerCmd )

        TopBarMsg submsg ->
            let
                ( topBarModel, topBarCmd ) =
                    TopBar.update submsg model.topBarModel
            in
            ( { model | topBarModel = topBarModel }, Cmd.map TopBarMsg topBarCmd )


updateRoute : Router.Route -> Model -> ( Model, Cmd Msg )
updateRoute route model =
    let
        ( pageModel, pageCmd ) =
            initPageModel () route
    in
    ( { model | route = route, pageModel = pageModel }, pageCmd )


updatePage : PageMsg -> Model -> ( Model, Cmd Msg )
updatePage msg model =
    case ( msg, model.pageModel ) of
        ( HomeMsg homeMsg, HomeModel homeModel ) ->
            let
                ( m1, m2 ) =
                    Page.Home.update homeMsg homeModel
            in
            ( { model | pageModel = HomeModel m1 }, Cmd.map PageMsg <| Cmd.map HomeMsg m2 )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Bowtie"
    , body =
        [ div [ class "content-frame" ]
            [ div [ id "top-bar-app" ]
                [ Html.map TopBarMsg <| TopBar.view model.topBarModel ]
            , div [ class "bottom" ]
                [ div [ id "content" ]
                    [ div [ id "subpage" ]
                        [ mainContent model ]
                    ]
                ]
            ]
        ]
    }


mainContent : Model -> Html Msg
mainContent model =
    case model.pageModel of
        HomeModel homeModel ->
            Html.map PageMsg <| Html.map HomeMsg <| Page.Home.view homeModel

        LoginModel loginModel ->
            Page.Login.view loginModel

        ClosetModel closetModel ->
            Page.Closet.view closetModel

        NotFoundModel notFoundModel ->
            Page.NotFound.pageNotFound notFoundModel



-- MAIN


onUrlRequest : UrlRequest -> Msg
onUrlRequest =
    RouterMsg << Router.LinkClicked


onUrlChange : Url -> Msg
onUrlChange =
    RouteChanged << Router.parseRoute


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }
