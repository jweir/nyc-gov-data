module Main exposing (..)

import Html
import Html.Attributes as A
import Html.Events as E
import Html.App
import Http
import Json.Decode as Json exposing ((:=))
import Task
import String
import Set


main =
    Html.App.program
        { init = init
        , view = view
        , update = controller
        , subscriptions = subscriptions
        }


type alias Model =
    { filter : String
    , items : List Item
    }


type alias ItemDesc =
    { description : String
    , url : String
    }


type alias ItemAttr =
    { description : String
    }


type alias Item =
    { category : String
    , keywords : String
    , description : String
    , name : ItemDesc
    , owner : ItemDesc
    , systemid : String
    , createdat : Int
    , tableid : String
    , attribution : ItemAttr
    }


init : ( Model, Cmd Action )
init =
    ( { filter = "", items = [] }
    , loadData
    )


loadData : Cmd Action
loadData =
    let
        url =
            "data/nyc-open-data.json"
    in
        Task.perform FetchFail FetchSucceed (Http.get decodeRaw url)


decodeRaw : Json.Decoder (List Item)
decodeRaw =
    Json.list decodeModel


decodeModel : Json.Decoder Item
decodeModel =
    let
        apply func value =
            Json.object2 (<|) func value

        decodeDesc =
            Json.object2 ItemDesc
                ("description" := Json.string)
                ("url" := Json.string)

        decodeAttr =
            Json.object1 ItemAttr
                ("description" := Json.string)
    in
        Json.map Item ("category" := Json.string)
            `apply` ("keywords" := Json.string)
            `apply` ("description" := Json.string)
            `apply` ("name" := decodeDesc)
            `apply` ("owner" := decodeDesc)
            `apply` ("system_id" := Json.string)
            `apply` ("created_at" := Json.int)
            `apply` ("table_id" := Json.string)
            `apply` ("attribution" := decodeAttr)


type Action
    = FetchSucceed (List Item)
    | FetchFail Http.Error
    | Filter String


controller : Action -> Model -> ( Model, Cmd Action )
controller action model =
    case action of
        Filter str ->
            ( { model | filter = str }, Cmd.none )

        FetchSucceed newItems ->
            ( { filter = "", items = newItems }, Cmd.none )

        FetchFail m ->
            ( model, Cmd.none )


filter : Model -> List Item
filter model =
    let
        contains item =
            (item.description ++ " " ++ item.category) |> String.toLower |> String.contains (String.toLower model.filter)
    in
        List.filter contains model.items


view : Model -> Html.Html Action
view model =
    let
        items =
            filter model

        categories =
            List.map (\i -> i.category) model.items |> Set.fromList
    in
        Html.body [ A.class "container" ]
            [ Html.node "link" [ A.rel "stylesheet", A.href "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.2/css/bootstrap.min.css" ] []
            , Html.h1 [] [ Html.text "Hello NYC" ]
            , Html.input [ A.type' "text", E.onInput Filter, A.value model.filter ] [ Html.text "Hello NYC" ]
            , Html.div [ A.class "row" ]
                [ paneCategories categories
                , paneBody model
                ]
            ]


paneCategories categories =
    let
        x c =
            Html.div []
                [ Html.a [ E.onClick (Filter c), A.href "#" ] [ Html.text c ]
                ]
    in
        Html.div [ A.class "col-sm-3"] 
            (List.map x (Set.toList categories |> List.sort))


paneBody model =
    let
        items =
            filter model |> List.sortBy (\x -> x.name.description)
    in
        Html.div [ A.class "col-sm-8"]
            (List.map itemView items)

itemView item =
  Html.div []
    [ Html.strong [] [Html.text item.attribution.description]
    , Html.a [A.href ("https://data.cityofnewyork.us/" ++ item.name.url), A.target "blank"] [ Html.text item.name.description ]
    , Html.div [A.style [("color","#AAA")]] [Html.text item.description]

      ]

subscriptions _ =
    Sub.none
