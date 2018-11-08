module Page.Closet exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import RemoteData exposing (WebData)
import TopBar


type alias Model =
    { closet : WebData Closet
    }


type alias Closet =
    { families : List Family
    }


type alias Family =
    { id : String
    , items : List String
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { closet = RemoteData.Success initialClosets }, Cmd.none )


initialClosets : Closet
initialClosets =
    { families =
        [ { id = "Pants", items = [] }
        , { id = "Shirts", items = [] }
        , { id = "Shoes", items = [] }
        , { id = "Socks", items = [] }
        ]
    }



-- UPDATE


type Msg
    = UserRepos (WebData Closet)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserRepos closet ->
            ( { model | closet = closet }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.closet of
        RemoteData.NotAsked ->
            h1 [] [ text "LOADING..." ]

        RemoteData.Failure err ->
            h1 [] [ text <| errorMessage err ]

        RemoteData.Loading ->
            h1 [] [ text "LOADING..." ]

        RemoteData.Success closet ->
            viewCloset closet


viewCloset : Closet -> Html Msg
viewCloset closet =
    div [ class "closet" ]
        [ div [ class "closet-content" ]
            [ div [ class "closet-families-panel" ]
                (div [ class "closet-team-name" ] [ text "Families" ]
                    :: (List.map viewFamily <| closet.families)
                )
            , div [ class "closet-items-panel" ]
                (div [ class "closet-team-name" ] [ text "Items" ]
                    :: (List.map viewItem <| [] {- closet.families -})
                )
            ]
        ]


viewFamily : Family -> Html Msg
viewFamily family =
    div [ class "closet-pipeline" ]
        [ div [ class "closet-pipeline-banner" ]
            []
        , div [ class "closet-pipeline-content" ]
            [ div [ class "closet-pipeline-name" ]
                [ text family.id ]
            ]
        ]


viewItem : String -> Html Msg
viewItem id =
    div [ class "closet-pipeline" ]
        [ div [ class "closet-pipeline-banner" ]
            []
        , div [ class "closet-pipeline-content" ]
            [ div [ class "closet-pipeline-name" ]
                [ text id ]
            ]
        ]


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
