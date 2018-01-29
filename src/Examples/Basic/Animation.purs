module Examples.Basic.Animation
where

import Prelude

import Bonsai (Cmd, ElementId(ElementId), emitMessage, emittingTask, plainResult, program, window)
import Bonsai.Html (VNode, button, div_, meter, p, render, text, (!))
import Bonsai.Html.Attributes (cls, disabled, typ, value)
import Bonsai.Html.Events (on)
import Bonsai.Types (TaskContext)
import Control.Monad.Aff (Aff, delay)
import Data.Array (range)
import Data.Foldable (for_)
import Data.Int (toNumber)
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple (Tuple)


data Msg
  = Progress Number
  | InProgress Boolean

type Model =
  { progress :: Number
  , inProgress :: Boolean
  }

view :: Model -> VNode Msg
view m =
  render $
    div_ $
      if m.inProgress
        then do
          p $ text "Downloading all the things!"
          meter ! cls "pure-u-1-2" ! value (show m.progress) $ text (show (100.0*m.progress) <> "%")
        else do
          p $ text "Would you like to download some cat pictures?"
          div_ $ button
            ! cls "pure-button"
            ! typ "button"
            ! disabled m.inProgress
            ! on "click" (const $ pure $ emittingTask simulateDownload)
            $ text "Start Download"

simulateDownload :: forall eff. TaskContext eff Msg -> Aff eff Unit
simulateDownload ctx = do
  emitMessage ctx (InProgress true)
  for_ (range 1 100) \i -> do
    delay (Milliseconds 50.0)
    emitMessage ctx (Progress $ 0.01 * toNumber i)
  emitMessage ctx (InProgress false)
  pure unit


update :: forall eff. Msg -> Model -> Tuple (Cmd eff Msg) Model
update msg model =
  plainResult case msg of
    Progress p ->
      model { progress = p }
    InProgress b ->
      model { inProgress = b }

emptyModel :: Model
emptyModel =
  { progress: 0.0
  , inProgress: false
  }

main = do
  _ <- window >>=
       program (ElementId "examplesBasicAnimation") update view emptyModel
  pure unit
