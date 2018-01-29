module Examples.Basic.Counter where

import Bonsai
import Bonsai.Html
import Bonsai.Html.Attributes
import Bonsai.Html.Events
import Data.Maybe
import Prelude

import Data.Tuple (Tuple(..))
import Partial.Unsafe (unsafePartial)

type Model = Int

data Msg
  = Inc
  | Dec

update :: forall eff. Msg -> Model -> Tuple (Cmd eff Msg) Model
update msg model = plainResult
  case msg of
    Inc ->
      model + 1
    Dec ->
      model - 1

view :: Model -> VNode Msg
view model =
  render $ div_ $ do
    text $ show model
    button ! onClick Inc $ text "+"
    button ! onClick Dec $ text "-"

main =
  (window >>= program (ElementId "examplesBasicCounter") update view 0) *> pure unit
