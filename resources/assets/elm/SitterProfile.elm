import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing ((:=))
import Task
import Http

main =
  Html.program
    { init = init
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
  , state : String
  , cities : List City
  , city : String
  , availableWeekDays : Int
  , availableWeekEnds : Int
  }

emptyModel : Model
emptyModel =
  {address = ""
  , zipCode = ""
  , mobilePhone = ""
  , state = ""
  , states = []
  , city = ""
  , cities = []
  , availableWeekDays = -1
  , availableWeekEnds = -1}

init : (Model, Cmd Msg)
init =
  ( emptyModel
  , fetchState
  )

-- update stuff
type Msg
  = Address String
  | ZipCode String
  | MobilePhone String
  | UpdateCity String
  | SelectedCity String
  | UpdateCitySuccess (List City)
  | UpdateCityFail Http.Error
  | FetchState
  | FetchStateSuccess (List State)
  | FetchStateFail Http.Error

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
      { model | state = state }
        ! [fetchCity state]

    SelectedCity city ->
      { model | city = city}
        ! []

    UpdateCitySuccess newCities ->
      { model | cities = newCities }
        ! [Cmd.none]

    UpdateCityFail _ ->
      (model, Cmd.none)

    FetchState ->
      (model, fetchState)

    FetchStateSuccess newStates ->
      { model | states = newStates}
        ! [Cmd.none]

    FetchStateFail _ ->
      (model, Cmd.none)

fetchCity : String -> Cmd Msg
fetchCity state =
  Task.perform UpdateCityFail UpdateCitySuccess (fetchCity' state)

fetchState : Cmd Msg
fetchState =
  let
    get = Http.get (Json.Decode.list decodeState) "/v0.1/api/states/"
  in
    Task.perform FetchStateFail FetchStateSuccess get

fetchCity' : String -> Task.Task Http.Error (List City)
fetchCity' state =
  let
    url = "/v0.1/api/cities/" ++ state
  in
    Http.get (Json.Decode.list decodeCity) url

decodeCity : Json.Decode.Decoder City
decodeCity =
  Json.Decode.object2 City
    ("code" := Json.Decode.string)
    ("name" := Json.Decode.string)

decodeState : Json.Decode.Decoder State
decodeState =
  Json.Decode.object2 State
    ("name" := Json.Decode.string)
    ("code" := Json.Decode.string)

-- utility for bootstrap styling
inputAttr =
  attribute "class" "form-control"

selectOption opt =
  option [ ] [ text opt.name ]

--
selectedAtribute =
  let
    targetId = Json.Decode.at ["target", "selectedIndex"] Json.Decode.string
  in
    on "change" targetId

-- view
view : Model -> Html Msg
view model =
  div []
    [ input [ type' "text", inputAttr, placeholder "Address", onInput Address ] []
    , input [ type' "text", inputAttr, placeholder "ZipCode", onInput ZipCode ] []
    , input [ type' "text", inputAttr, placeholder "MobilePhone", onInput MobilePhone ] []
    , select [ inputAttr, onInput UpdateCity] (List.map selectOption model.states)
    , select [ inputAttr, onInput UpdateCity] (List.map selectOption model.cities)
    ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
