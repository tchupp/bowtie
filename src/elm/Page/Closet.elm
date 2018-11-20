module Page.Closet exposing (Model, Msg, init, update, view)

import Dict exposing (Dict)
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class, classList, disabled)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, decodeString, dict, field, int, keyValuePairs, list, map3, oneOf, string)
import RemoteData exposing (WebData)
import TopBar
import Url.Builder as Url


type alias Model =
    { closetId : String
    , closet : WebData Closet
    , selectedFamily : Maybe Family
    , selections : List ItemId
    }


type alias Closet =
    { families : List Family
    }


type alias Family =
    { id : String
    , items : List Item
    }


type alias Item =
    { state : String, id : ItemId }


type alias ItemId =
    String


isSelected : Item -> Bool
isSelected item =
    item.state == "selected"


selectedItems : List Family -> List Item
selectedItems families =
    families
        |> List.map .items
        |> List.concat
        |> List.filter isSelected



-- INIT


init : String -> ( Model, Cmd Msg )
init closetId =
    let
        model =
            { closetId = closetId
            , closet = RemoteData.Loading
            , selectedFamily = Nothing
            , selections = []
            }
    in
    ( model, fetchCloset model.closetId model.selections )



-- UPDATE


type Msg
    = ClosetUpdated (WebData Closet)
    | FamilySelected String
    | ItemSelected String
    | ItemDeselected String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClosetUpdated closet ->
            let
                families =
                    RemoteData.toMaybe closet
                        |> Maybe.map .families

                selections =
                    families
                        |> Maybe.map selectedItems
                        |> Maybe.map (List.map .id)
                        |> Maybe.withDefault model.selections

                selectedFamilyId =
                    model.selectedFamily
                        |> Maybe.map .id
                        |> Maybe.withDefault ""

                selectedFamily =
                    families
                        |> Maybe.withDefault []
                        |> List.filter (\f -> f.id == selectedFamilyId)
                        |> List.head
            in
            ( { model | closet = closet, selections = selections, selectedFamily = selectedFamily }, Cmd.none )

        FamilySelected familyId ->
            let
                selectedFamily =
                    RemoteData.toMaybe model.closet
                        |> Maybe.map .families
                        |> Maybe.withDefault []
                        |> List.filter (\f -> f.id == familyId)
                        |> List.head
            in
            ( { model | selectedFamily = selectedFamily }, Cmd.none )

        ItemSelected itemId ->
            ( model, fetchCloset model.closetId <| itemId :: model.selections )

        ItemDeselected itemId ->
            let
                selections =
                    model.selections
                        |> List.filter ((/=) itemId)
            in
            ( model, fetchCloset model.closetId <| selections )

        NoOp ->
            ( model, Cmd.none )



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
            viewCloset closet model.selectedFamily


viewCloset : Closet -> Maybe Family -> Html Msg
viewCloset closet selectedFamily =
    div [ class "closet" ]
        [ div [ class "closet-content" ]
            [ viewFamilyPanel closet.families selectedFamily
            , viewItemPanel selectedFamily
            , viewOutfitPanel closet.families
            ]
        ]



-- VIEW :: Family Panel


viewFamilyPanel : List Family -> Maybe Family -> Html Msg
viewFamilyPanel families selectedFamily =
    let
        selectedFamilyId =
            selectedFamily
                |> Maybe.map .id
                |> Maybe.withDefault ""
    in
    div [ class "closet-items-panel" ]
        (div [ class "closet-panel-name" ] [ text "Families" ]
            :: (List.map (viewFamily selectedFamilyId) <| families)
        )


viewFamily : String -> Family -> Html Msg
viewFamily selectedFamilyId family =
    div
        [ onClick (FamilySelected family.id)
        , classList
            [ ( "closet-family", True )
            , ( "selected", family.id == selectedFamilyId )
            ]
        ]
        [ div [ class "closet-item-banner" ]
            []
        , div [ class "closet-item-content" ]
            [ div [ class "closet-item-name" ]
                [ text family.id ]
            ]
        ]



-- VIEW :: Item Panel


viewItemPanel : Maybe Family -> Html Msg
viewItemPanel family =
    let
        items =
            Maybe.map .items family
                |> Maybe.withDefault []
    in
    div [ class "closet-items-panel" ] <|
        div [ class "closet-panel-name" ] [ text "Items" ]
            :: List.map viewItem items


viewItem : Item -> Html Msg
viewItem { id, state } =
    let
        action =
            case state of
                "selected" ->
                    ItemDeselected id

                "available" ->
                    ItemSelected id

                "required" ->
                    ItemSelected id

                _ ->
                    NoOp

        attributes =
            [ onClick <| action
            , class "closet-item"
            , class state
            ]
    in
    div
        attributes
        [ div [ class "closet-item-banner" ]
            []
        , div [ class "closet-item-content" ]
            [ div [ class "closet-item-name" ]
                [ text id ]
            ]
        ]



-- VIEW :: Selected Items Panel


viewOutfitPanel : List Family -> Html Msg
viewOutfitPanel families =
    div [ class "closet-items-panel" ] <|
        div [ class "closet-panel-name" ] [ text "Outfit" ]
            :: (List.map viewItem <| selectedItems families)



-- HTTP


fetchCloset : String -> List ItemId -> Cmd Msg
fetchCloset closetId selections =
    closetDecoder
        |> Http.get (retrieveClosetUrl closetId selections)
        |> RemoteData.sendRequest
        |> Cmd.map ClosetUpdated


retrieveClosetUrl : String -> List ItemId -> String
retrieveClosetUrl closetId selections =
    let
        selectionsQuery =
            selections
                |> String.join ","
    in
    Url.crossOrigin "https://us-central1-bowtie-samurai-prod.cloudfunctions.net/api"
        [ "closets", closetId ]
        [ Url.string "selections" selectionsQuery ]


closetDecoder : Decoder Closet
closetDecoder =
    Json.Decode.map Closet
        (field "options" familiesDecoder)


familiesDecoder : Decoder (List Family)
familiesDecoder =
    list itemDecoder
        |> Json.Decode.map (List.sortBy .id)
        |> dict
        |> Json.Decode.map (Dict.map Family)
        |> Json.Decode.map Dict.values


itemDecoder : Decoder Item
itemDecoder =
    oneOf
        [ Json.Decode.map (Item "available") <| field "Available" string
        , Json.Decode.map (Item "excluded") <| field "Excluded" string
        , Json.Decode.map (Item "selected") <| field "Selected" string
        , Json.Decode.map (Item "required") <| field "Required" string
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
