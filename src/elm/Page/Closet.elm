module Page.Closet exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Http
import RemoteData exposing (WebData)
import TopBar


type alias Model =
    { closet : WebData Closet
    , selectedItems : List String
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
    { id : String, selected : Bool }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { closet = RemoteData.Success initialCloset, selectedItems = [] }, Cmd.none )


initialCloset : Closet
initialCloset =
    { families =
        [ initializeFamily "Pants" [ "Jeans", "Slacks", "Khakis" ]
        , initializeFamily "Shirts" [ "Red Flannel", "Purple striped button-up", "Black Led Zeppelin T-shirt" ]
        , initializeFamily "Shoes" [ "Flip flops", "Brown leather Docs" ]
        , initializeFamily "Socks" [ "Grey", "Black", "Blue/Grey striped" ]
        , initializeFamily "WWWWWWWWWWWWWWWWW" [ "WWWWWWWWWWWWWWWWW" ]
        ]
    , selectedFamily = Nothing
    }


initializeFamily : String -> List String -> Family
initializeFamily id items =
    { selected = False, id = id, items = List.map initializeItem items }


initializeItem : String -> Item
initializeItem id =
    { selected = False, id = id }



-- UPDATE


type Msg
    = UserRepos (WebData Closet)
    | FamilySelected String
    | ItemSelected String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserRepos closet ->
            ( { model | closet = closet }, Cmd.none )

        FamilySelected familyId ->
            let
                selectedFamily =
                    RemoteData.toMaybe model.closet
                        |> Maybe.map .families
                        |> Maybe.withDefault []
                        |> List.filter (\f -> f.id == familyId)
                        |> List.head
                        |> Maybe.map (\f -> { f | items = List.map (selectItem model.selectedItems) f.items })

                families =
                    RemoteData.toMaybe model.closet
                        |> Maybe.map .families
                        |> Maybe.withDefault []
                        |> List.map (\f -> { f | selected = f.id == familyId })

                closet =
                    RemoteData.map (\c -> { c | selectedFamily = selectedFamily, families = families }) model.closet
            in
            ( { model | closet = closet }, Cmd.none )

        ItemSelected itemId ->
            let
                selectedItems =
                    itemId :: model.selectedItems

                selectedFamily =
                    RemoteData.toMaybe model.closet
                        |> Maybe.andThen .selectedFamily
                        |> Maybe.map (\f -> { f | items = List.map (selectItem selectedItems) f.items })

                closet =
                    RemoteData.map (\c -> { c | selectedFamily = selectedFamily }) model.closet
            in
            ( { model | closet = closet, selectedItems = selectedItems }, Cmd.none )


selectItem : List String -> Item -> Item
selectItem selected item =
    { item | selected = List.member item.id selected }



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
            Maybe.map .items family
                |> Maybe.withDefault []
    in
    div [ class "closet-items-panel" ]
        (div [ class "closet-panel-name" ] [ text "Items" ]
            :: (List.map viewItem <| items)
        )


viewItem : Item -> Html Msg
viewItem item =
    div
        [ onClick (ItemSelected item.id)
        , classList
            [ ( "closet-item", True )
            , ( "selected", item.selected )
            ]
        ]
        [ div [ class "closet-item-banner" ]
            []
        , div [ class "closet-item-content" ]
            [ div [ class "closet-item-name" ]
                [ text item.id ]
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
