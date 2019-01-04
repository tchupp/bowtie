module Page.Closet exposing (Model, Msg, init, reinit, update, view)

import Dict exposing (Dict)
import Html exposing (Html, a, div, h1, text)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, dict, field, list, oneOf, string)
import RemoteData exposing (WebData)
import Router exposing (buildClosetRoute)
import TopBar
import Url.Builder as Url


type alias Model =
    { closetId : String
    , prevCloset : WebData Closet
    , closet : WebData Closet
    , selectedFamilyId : Maybe String
    , selections : List ItemId
    }


type alias Closet =
    { id : String
    , families : List Family
    , token : String
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
    item.state == "SELECTED"


selectedItems : List Family -> List Item
selectedItems families =
    families
        |> List.map .items
        |> List.concat
        |> List.filter isSelected



-- INIT


init : String -> Maybe String -> List ItemId -> ( Model, Cmd Msg )
init closetId selectedFamilyId selections =
    let
        model =
            { closetId = closetId
            , prevCloset = RemoteData.Loading
            , closet = RemoteData.Loading
            , selectedFamilyId = selectedFamilyId
            , selections = selections
            }
    in
    ( closetUpdated RemoteData.NotAsked selections selectedFamilyId model
    , fetchCloset closetId selections
    )


reinit : Model -> String -> Maybe String -> List ItemId -> ( Model, Cmd Msg )
reinit model closetId selectedFamilyId selections =
    let
        closetChanged =
            model.selections == selections && model.closetId == closetId

        ( closet, prevCloset, cmd ) =
            case closetChanged of
                True ->
                    ( model.closet, model.prevCloset, Cmd.none )

                False ->
                    ( RemoteData.Loading, model.closet, fetchCloset closetId selections )
    in
    ( { model
        | closetId = closetId
        , prevCloset = prevCloset
        , closet = closet
        , selectedFamilyId = selectedFamilyId
        , selections = selections
      }
    , cmd
    )



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
            ( closetUpdated closet model.selections model.selectedFamilyId model, Cmd.none )

        FamilySelected familyId ->
            ( { model | selectedFamilyId = Just familyId }, Cmd.none )

        ItemSelected id ->
            ( model, Cmd.none )

        ItemDeselected id ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


closetUpdated : WebData Closet -> List ItemId -> Maybe String -> Model -> Model
closetUpdated closet prevSelections selectedFamilyId model =
    let
        families =
            RemoteData.toMaybe closet
                |> Maybe.map .families

        selections =
            families
                |> Maybe.map selectedItems
                |> Maybe.map (List.map .id)
                |> Maybe.withDefault prevSelections

        selectedFamily =
            families
                |> Maybe.withDefault []
                |> List.filter (\f -> Just f.id == selectedFamilyId)
                |> List.head
    in
    { model | closet = closet, selections = selections, selectedFamilyId = selectedFamilyId }



-- VIEW


view : Model -> Html Msg
view model =
    case ( model.prevCloset, model.closet ) of
        ( _, RemoteData.NotAsked ) ->
            h1 [] [ text "LOADING..." ]

        ( _, RemoteData.Failure err ) ->
            h1 [] [ text <| errorMessage err ]

        ( RemoteData.Success closet, RemoteData.Loading ) ->
            viewCloset closet model.selectedFamilyId

        ( _, RemoteData.Loading ) ->
            h1 [] [ text "LOADING..." ]

        ( _, RemoteData.Success closet ) ->
            viewCloset closet model.selectedFamilyId


viewCloset : Closet -> Maybe String -> Html Msg
viewCloset closet selectedFamilyId =
    let
        selections =
            selectedItems closet.families
                |> List.map .id

        itemRoute : Item -> String
        itemRoute item =
            let
                apply : List ItemId -> List ItemId
                apply items =
                    case item.state of
                        "SELECTED" ->
                            List.filter (\i -> item.id /= i) items

                        "AVAILABLE" ->
                            List.append [ item.id ] items

                        "REQUIRED" ->
                            List.append [ item.id ] items

                        _ ->
                            items
            in
            buildClosetRoute closet.id selectedFamilyId (selections |> apply)

        familyRoute : Family -> String
        familyRoute family =
            buildClosetRoute closet.id (Just family.id) selections

        itemView : Item -> Html Msg
        itemView =
            viewItem <| itemRoute

        familyView : Maybe String -> Family -> Html Msg
        familyView =
            viewFamily <| familyRoute

        selectedFamily =
            closet.families
                |> List.filter (\f -> Just f.id == selectedFamilyId)
                |> List.head
    in
    div [ class "closet" ]
        [ div [ class "closet-content" ]
            [ viewFamilyPanel (familyView <| selectedFamilyId) closet.families
            , viewItemPanel itemView selectedFamily
            , viewOutfitPanel itemView closet.families
            ]
        ]



-- VIEW :: Family Panel


viewFamilyPanel : (Family -> Html Msg) -> List Family -> Html Msg
viewFamilyPanel familyView families =
    div [ class "closet-items-panel" ]
        (div [ class "closet-panel-name" ] [ text "Families" ]
            :: (List.map familyView <| families)
        )


viewFamily : (Family -> String) -> Maybe String -> Family -> Html Msg
viewFamily hrefBuilder selectedFamilyId family =
    a
        [ href (hrefBuilder family)
        , onClick (FamilySelected family.id)
        , classList
            [ ( "closet-family", True )
            , ( "selected", Just family.id == selectedFamilyId )
            ]
        ]
        [ div [ class "closet-item-banner" ] []
        , div [ class "closet-item-content" ]
            [ div [ class "closet-item-name" ]
                [ text family.id ]
            ]
        ]



-- VIEW :: Item Panel


viewItemPanel : (Item -> Html Msg) -> Maybe Family -> Html Msg
viewItemPanel itemView family =
    let
        items =
            Maybe.map .items family
                |> Maybe.withDefault []
    in
    div [ class "closet-items-panel" ] <|
        div [ class "closet-panel-name" ] [ text "Items" ]
            :: List.map itemView items


viewItem : (Item -> String) -> Item -> Html Msg
viewItem hrefBuilder item =
    a
        [ href (hrefBuilder item)
        , class "closet-item"
        , class (String.toLower item.state)
        ]
        [ div [ class "closet-item-banner" ] []
        , div [ class "closet-item-content" ]
            [ div [ class "closet-item-name" ]
                [ text item.id ]
            ]
        ]



-- VIEW :: Selected Items Panel


viewOutfitPanel : (Item -> Html Msg) -> List Family -> Html Msg
viewOutfitPanel itemView families =
    div [ class "closet-items-panel" ] <|
        div [ class "closet-panel-name" ] [ text "Outfit" ]
            :: (List.map itemView <| selectedItems families)



-- HTTP


fetchCloset : String -> List ItemId -> Cmd Msg
fetchCloset closetId selections =
    closetDecoder closetId
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
    Url.crossOrigin "https://ignition-app.xyz"
        [ "v1", "projects", "bowtie", "catalogs", closetId, "options" ]
        [ Url.string "selections" selectionsQuery ]


closetDecoder : String -> Decoder Closet
closetDecoder closetId =
    Json.Decode.map3 Closet
        (field "catalogId" string)
        (field "options" (Json.Decode.list familyDecoder))
        (field "token" string)


familyDecoder : Decoder Family
familyDecoder =
    Json.Decode.map2 Family
        (field "familyId" string)
        (field "options" (Json.Decode.list itemDecoder))


itemDecoder : Decoder Item
itemDecoder =
    Json.Decode.map2 Item
        (field "itemStatus" string)
        (field "itemId" string)


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
