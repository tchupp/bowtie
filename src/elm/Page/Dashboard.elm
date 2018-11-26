module Page.Dashboard exposing (Model, Msg, init, update, view)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, href)
import Http
import Json.Decode exposing (Decoder, field, int, list, map3, string)
import RemoteData exposing (WebData)
import Router
import TopBar
import Url.Builder as Url


type alias Model =
    { closets : WebData (List Closet)
    }


type alias Closet =
    { id : Int
    , name : String
    , html_url : String
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { closets = RemoteData.Loading }, fetchRepos "tchupp" )



-- UPDATE


type Msg
    = UserRepos (WebData (List Closet))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserRepos closets ->
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
            [ a [ href <| "#/closet/" ++ closet.name ]
                [ div [ class "dashboard-pipeline-name" ]
                    [ text closet.name ]
                ]
            ]
        ]



-- HTTP


fetchRepos : String -> Cmd Msg
fetchRepos username =
    closetsDecoder
        |> Http.get (listRepoUrl username)
        |> RemoteData.sendRequest
        |> Cmd.map UserRepos


listRepoUrl : String -> String
listRepoUrl username =
    Url.crossOrigin "https://api.github.com"
        [ "users", username, "repos" ]
        [ Url.string "type" "owner"
        , Url.string "sort" "full_name"
        ]


closetDecoder : Decoder Closet
closetDecoder =
    map3 Closet
        (field "id" int)
        (field "name" string)
        (field "html_url" string)


closetsDecoder : Decoder (List Closet)
closetsDecoder =
    list closetDecoder


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
