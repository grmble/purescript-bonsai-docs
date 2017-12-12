module Examples.Basic.Animation
where

import Prelude

import Bonsai (domElementById, emitMessages, plainResult, program, pureCommand, emittingTask)
import Bonsai.Core (UpdateResult)
import Bonsai.Html (VNode, button, div_, input, p, render, text, (!), (#!?))
import Bonsai.Html.Attributes (style, value)
import Bonsai.Html.Events (on, onClick, onInput)
import Bonsai.Types (TaskContext)
import Control.Monad.Aff (Aff, delay)
import DOM.Node.Types (ElementId(..))
import Data.Array (range)
import Data.Foldable (for_)
import Data.Int (hexadecimal, toStringAs)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Partial.Unsafe (unsafePartial)

newtype Color =
  Color String

data Msg
  = SetText String
  | StartAnimation
  | Animate Color
  | EndAnimation

type Model =
  { text :: String
  , color :: Maybe Color
  }

view :: Model -> VNode Msg
view m =
  render $
    div_ $ do
      input ! onInput SetText ! value m.text
      p #!? (map (\(Color c) -> style "background-color" c) m.color) $
        text m.text
      button ! onClick EndAnimation $ text "Stop Animation"
      button ! on "click" (const $ pure $ emittingTask animate) $ text "Animation"

animate :: forall eff. TaskContext eff (Array Msg) -> Aff eff Unit
animate ctx = do
  emitMessages ctx [ StartAnimation ]
  for_ (range 8 0xF)
    animateColor
  pure unit

  where
    animateColor x = do
      let s = toStringAs hexadecimal x
      let css = "#FFFF" <> s <> "F"
      emitMessages ctx [ Animate (Color css) ]
      delay (Milliseconds 200.0)


update :: forall eff. Model -> Msg -> UpdateResult eff Model Msg
update model msg =
   case msg of
    SetText str ->
      { model: model { text = str }
      , cmd: pureCommand EndAnimation }
    StartAnimation ->
      plainResult $ model { color = Just (Color "#FFFFFF") }
    Animate col ->
      plainResult $ model { color = map (const col) model.color }
    EndAnimation ->
      plainResult $ model { color = Nothing }

emptyModel :: Model
emptyModel =
  { text: "Hello, world!"
  , color: Nothing
  }

main = unsafePartial $ do
  Just elem <- domElementById (ElementId "examplesBasicAnimation")
  _ <- program elem update view emptyModel
  pure unit
