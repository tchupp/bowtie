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
    { routerModel : Router.Model
    , topBarModel : TopBar.Model
    }



-- INIT


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( routerModel, routerCmd ) =
            Router.init () url key

        ( topBarModel, topBarCmd ) =
            TopBar.init

        model =
            { routerModel = routerModel, topBarModel = topBarModel }
    in
    ( model
    , Cmd.batch
        [ Cmd.map RouterMsg routerCmd
        , topBarCmd
        ]
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = RouterMsg Router.Msg
    | TopBarMsg TopBar.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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
    case model.routerModel.route of
        Router.Home ->
            Page.Home.view ()

        Router.Login ->
            Page.Login.view ()

        Router.Closet _ ->
            Page.Closet.view ()

        Router.NotFound ->
            Page.NotFound.pageNotFound ()



-- MAIN


onUrlRequest : UrlRequest -> Msg
onUrlRequest urlRequest =
    Router.LinkClicked urlRequest
        |> RouterMsg


onUrlChange : Url -> Msg
onUrlChange url =
    Router.UrlChanged url
        |> RouterMsg


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
