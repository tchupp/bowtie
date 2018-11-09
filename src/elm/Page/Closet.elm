module Page.Closet exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import RemoteData exposing (WebData)
import TopBar


type alias Model =
    { closet : WebData Closet
    }


type alias Closet =
    { families : List Family
    , selectedFamily : Maybe Family
    }


type alias Family =
    { id : String
    , items : List Item
    , selected : Bool
    }


type alias Item =
    String



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { closet = RemoteData.Success initialClosets }, Cmd.none )


initialClosets : Closet
initialClosets =
    { families =
        [ { selected = False, id = "Pants", items = [ "Jeans", "Slacks", "Khakis" ] }
        , { selected = False, id = "Shirts", items = [ "Red Flannel", "Purple striped button-up", "Black Led Zeppelin T-shirt" ] }
        , { selected = False, id = "Shoes", items = [ "Flip flops", "Brown leather Docs" ] }
        , { selected = False, id = "Socks", items = [ "Grey", "Black", "Blue/Grey striped" ] }
        ]
    , selectedFamily = Nothing
    }



-- UPDATE


type Msg
    = UserRepos (WebData Closet)
    | FamilySelected String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserRepos closet ->
            ( { model | closet = closet }, Cmd.none )

        FamilySelected familyId ->
            let
                selectedFamily =
                    RemoteData.toMaybe model.closet
                        |> Maybe.map (\c -> c.families)
                        |> Maybe.withDefault []
                        |> List.filter (\f -> f.id == familyId)
                        |> List.head

                families =
                    RemoteData.toMaybe model.closet
                        |> Maybe.map (\c -> c.families)
                        |> Maybe.withDefault []
                        |> List.map (\f -> { f | selected = f.id == familyId })

                closet =
                    RemoteData.map (\c -> { c | selectedFamily = selectedFamily, families = families }) model.closet
            in
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
            [ viewFamilyPanel closet.families
            , viewItemPanel closet.selectedFamily
            ]
        ]


viewFamilyPanel : List Family -> Html Msg
viewFamilyPanel families =
    div [ class "closet-items-panel" ]
        (div [ class "closet-panel-name" ] [ text "Families" ]
            :: (List.map viewFamily <| families)
        )


viewFamily : Family -> Html Msg
viewFamily family =
    div
        [ onClick (FamilySelected family.id)
        , classList
            [ ( "closet-family", True )
            , ( "selected", family.selected )
            ]
        ]
        [ div [ class "closet-item-banner" ]
            []
        , div [ class "closet-item-content" ]
            [ div [ class "closet-item-name" ]
                [ text family.id ]
            ]
        ]


viewItemPanel : Maybe Family -> Html Msg
viewItemPanel family =
    let
        items =
            Maybe.map (\f -> f.items) family
                |> Maybe.withDefault []
    in
    div [ class "closet-items-panel" ]
        (div [ class "closet-panel-name" ] [ text "Items" ]
            :: (List.map viewItem <| items)
        )


viewItem : Item -> Html Msg
viewItem itemId =
    div [ class "closet-item" ]
        [ div [ class "closet-item-banner" ]
            []
        , div [ class "closet-item-content" ]
            [ div [ class "closet-item-name" ]
                [ text itemId ]
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
