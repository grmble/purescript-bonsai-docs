module Examples.Basic.Animation
where

import Prelude

import Bonsai (domElementById, emitMessages, plainResult, program, readerTask)
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
      button ! onClick (Animate (Color "#FF0000")) $ text "Red"
      button ! onClick (Animate (Color "#00FF00")) $ text "Green"
      button ! on "click" (const $ pure $ readerTask animate) $ text "Animate"

animate :: forall eff. TaskContext eff (Array Msg) -> Aff eff (Array Msg)
animate ctx = do
  for_ (range 8 0xF)
    animateColor
  pure [ EndAnimation ]

  where
    animateColor x = do
      let s = toStringAs hexadecimal x
      let css = "#FFFF" <> s <> "F"
      emitMessages ctx [ Animate (Color css) ]
      delay (Milliseconds 200.0)


update :: forall eff. Model -> Msg -> UpdateResult eff Model Msg
update model msg =
   plainResult $
    case msg of
      SetText str ->
        model { text = str }
      Animate col ->
        model { color = Just col }
      EndAnimation ->
        model { color = Nothing }

emptyModel :: Model
emptyModel =
  { text: "Hello, world!"
  , color: Nothing
  }

main = unsafePartial $ do
  Just elem <- domElementById (ElementId "examplesBasicAnimation")
  _ <- program elem update view emptyModel
  pure unit
