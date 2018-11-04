module Page.Search exposing (Entries(..))

import Bootstrap.ListGroup as Listgroup
import Browser exposing (UrlRequest)
import Html exposing (..)
import Http
import Json.Decode exposing (Decoder, field, int, list, map3, string)
import Url.Builder as Url


type alias Closet =
    { id : Int
    , name : String
    , html_url : String
    }


type Entries
    = Failure Http.Error
    | Loading
    | Success (List Closet)


type Msg
    = FindRepos String
    | UserRepos (Result Http.Error (List Closet))



-- INIT


init : () -> ( Entries, Cmd Msg )
init _ =
    ( Loading, getReposForUser "tchupp" )



-- UPDATE


update : Msg -> Entries -> ( Entries, Cmd Msg )
update cmd entries =
    case cmd of
        FindRepos username ->
            ( entries, getReposForUser "tchupp" )

        UserRepos result ->
            case result of
                Ok closets ->
                    ( Success closets, Cmd.none )

                Err err ->
                    ( Failure err, Cmd.none )



-- VIEW


view : Entries -> Html Msg
view entries =
    case entries of
        Failure error ->
            div [] [ h1 [] [ text (errorMessage error) ] ]

        Loading ->
            div [] [ h1 [] [ text "loading..." ] ]

        Success closets ->
            closetToListItem closets


closetToListItem : List Closet -> Html Msg
closetToListItem closets =
    div []
        [ h1 [] [ text "Modules" ]
        , Listgroup.ul <|
            List.map (\n -> Listgroup.li [] [ text n.name ]) closets
        ]



-- SUBSCRIPTIONS


subscriptions : Entries -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getReposForUser : String -> Cmd Msg
getReposForUser username =
    closetsDecoder
        |> Http.get (buildGitHubUserRepoSearchUrl username)
        |> Http.send UserRepos


buildGitHubUserRepoSearchUrl : String -> String
buildGitHubUserRepoSearchUrl username =
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



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
