import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing ((:=))
import Task
import Http

main =
  Html.program
    { init = init "any"
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias State =
  {name : String
  ,code : String
  }

type alias City =
  {name : String
  , code : String
  }

-- our model for this form
type alias Model =
  {address : String
  , zipCode : String
  , mobilePhone : String
  , states : List State
  , cities : List City
  , availableWeekDays : Int
  , availableWeekEnds : Int
  }

emptyModel : Model
emptyModel =
  {address = ""
  , zipCode = ""
  , mobilePhone = ""
  , states = []
  , cities = []
  , availableWeekDays = -1
  , availableWeekEnds = -1}

init : String -> (Model, Cmd Msg)
init state =
  ( emptyModel
  , fetchCity state
  )

-- update stuff
type Msg
  = Address String
  | ZipCode String
  | MobilePhone String
  | UpdateCity String
  | UpdateCitySuccess (List City)
  | UpdateCityFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Address address ->
      { model | address = address }
        ! []

    ZipCode zipCode ->
      { model | zipCode = zipCode }
        ! []

    MobilePhone mobilePhone ->
      { model | mobilePhone = mobilePhone }
        ! []

    UpdateCity state ->
      (model, fetchCity state)

    UpdateCitySuccess newCities ->
      (model, Cmd.none)

    UpdateCityFail _ ->
      (emptyModel, Cmd.none)

fetchCity : String -> Cmd Msg
fetchCity state =
  Task.perform UpdateCityFail UpdateCitySuccess (fetchCity' state)

fetchCity' : String -> Task.Task Http.Error (List City)
fetchCity' state =
  let
    url = "/cities/" ++ state
  in
    Http.get (Json.Decode.list decodeCity) url

decodeCity : Json.Decode.Decoder City
decodeCity =
  Json.Decode.object2 City
    ("code" := Json.Decode.string)
    ("name" := Json.Decode.string)

-- view
view : Model -> Html Msg
view model =
  div []
    [ input [ type' "text", placeholder "Address", onInput Address ] []
    , input [ type' "text", placeholder "ZipCode", onInput ZipCode ] []
    , select [ onInput UpdateCity ] []
    ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
