module Page.Dashboard exposing (Model, Msg, init, update, view)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, href)
import Http
import Json.Decode exposing (Decoder, field, list, map2, string)
import RemoteData exposing (WebData)
import Url.Builder as Url


type alias Model =
    { closets : WebData (List Closet)
    }


type alias Closet =
    { id : String
    , created : String
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { closets = RemoteData.Loading }, fetchClosets )



-- UPDATE


type Msg
    = RetrieveClosets (WebData (List Closet))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RetrieveClosets closets ->
            ( { model | closets = closets }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "dashboard" ]
        [ div [ class "dashboard-content" ] <| viewClosets model ]


viewClosets : Model -> List (Html Msg)
viewClosets model =
    case model.closets of
        RemoteData.NotAsked ->
            [ text "LOADING..." ]

        RemoteData.Failure err ->
            [ text <| errorMessage err ]

        RemoteData.Loading ->
            [ text "LOADING..." ]

        RemoteData.Success closets ->
            List.map viewCloset closets


viewCloset : Closet -> Html Msg
viewCloset closet =
    div [ class "dashboard-pipeline", class "dashboard-paused" ]
        [ div [ class "dashboard-pipeline-banner" ]
            []
        , div [ class "dashboard-pipeline-content" ]
            [ a [ href <| "#/closet/" ++ closet.id ]
                [ div [ class "dashboard-pipeline-name" ]
                    [ text closet.id ]
                ]
            ]
        ]



-- HTTP


fetchClosets : Cmd Msg
fetchClosets =
    closetsDecoder
        |> Http.get retrieveClosetsUrl
        |> RemoteData.sendRequest
        |> Cmd.map RetrieveClosets


retrieveClosetsUrl : String
retrieveClosetsUrl =
    Url.crossOrigin "https://ignition-app.xyz"
        [ "v1", "projects", "examples", "catalogs" ]
        []


closetDecoder : Decoder Closet
closetDecoder =
    map2 Closet
        (field "catalogId" string)
        (field "created" string)


closetsDecoder : Decoder (List Closet)
closetsDecoder =
    field "catalogs" (list closetDecoder)


errorMessage : Http.Error -> String
errorMessage error =
    case error of
        Http.BadUrl url ->
            "BadUrl " ++ url

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network Error"

        Http.BadPayload str res ->
            "BadPayload " ++ str ++ " body: " ++ res.body

        Http.BadStatus res ->
            "BadStatus " ++ res.body
