module Main where

import Prelude

import Bonsai (UpdateResult, domElementById, mapResult, plainResult, program, pureCommand)
import Bonsai.Html (Property, VNode, a, div_, li, nav, onWithOptions, render, text, ul, vnode, (!), (!?))
import Bonsai.Html.Attributes (cls, href)
import Bonsai.Html.Events (onClick, preventDefaultStopPropagation)
import DOM.Node.Types (ElementId(..))
import Data.Maybe (Maybe(..))
import Examples.Basic.Animation as Animation
import Examples.Basic.Counter as Counter
import Partial.Unsafe (unsafePartial)

data Example
  = CounterExample
  | AnimationExample

derive instance eqExample :: Eq Example

type MasterModel =
  { active :: Example
  , counterModel :: Counter.Model
  , animationModel :: Animation.Model
  }

data MasterMsg
  = CurrentExample Example
  | CounterMsg Counter.Msg
  | AnimationMsg Animation.Msg

update :: forall eff. MasterModel -> MasterMsg -> UpdateResult eff MasterModel MasterMsg
update model msg =
  case msg of
    CurrentExample example ->
      plainResult $ model { active = example }
    CounterMsg counterMsg ->
      mapResult ( model { counterModel = _ } ) CounterMsg
        (Counter.update model.counterModel counterMsg)
    AnimationMsg animationMsg ->
      mapResult ( model { animationModel = _ } ) AnimationMsg
        (Animation.update model.animationModel animationMsg)

view :: MasterModel -> VNode MasterMsg
view model =
  render $
    div_ ! cls "pure-grid" $ do
      nav ! cls "pure-u-1-6 pure-menu" $
        ul ! cls "pure-menu-list" $ do
          li ! cls "pure-menu-item" !? selected CounterExample model $
            a ! cls "pure-menu-link" ! href "#"
              ! onClickPreventDefault (CurrentExample CounterExample)
              $ text "Counter"
          li ! cls "pure-menu-item" !? selected AnimationExample model $
            a ! cls "pure-menu-link" ! href "#"
              ! onClick (CurrentExample AnimationExample)
              $ text "Animation"
      div_ ! cls "pure-u-5-6" $ do
        case model.active of
          CounterExample ->
            vnode (map CounterMsg $ Counter.view model.counterModel)
          AnimationExample ->
            vnode (map AnimationMsg $ Animation.view model.animationModel)

selected :: Example -> MasterModel -> Maybe (Property MasterMsg)
selected ex model =
  if ex == model.active
    then Just (cls "pure-menu-selected")
    else Nothing


onClickPreventDefault :: forall msg. msg -> Property msg
onClickPreventDefault msg =
  onWithOptions "click" preventDefaultStopPropagation (const $ pure $ pureCommand msg)

emptyModel :: MasterModel
emptyModel =
  { active: CounterExample
  , counterModel: 0
  , animationModel: Animation.emptyModel
  }

main = unsafePartial $ do
  Just mainDiv  <- domElementById (ElementId "main")
  _ <- program mainDiv update view emptyModel
  pure unit
