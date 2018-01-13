module Main where

import Prelude

import Bonsai (ElementId(..), UpdateResult, mapResult, plainResult, program, pureCommand, window)
import Bonsai.Html (Property, VNode, a, div_, li, nav, onWithOptions, render, text, ul, vnode, (!), (#!))
import Bonsai.Html.Attributes (classList, cls, href, style)
import Bonsai.Html.Events (onClick, preventDefaultStopPropagation)
import Bonsai.VirtualDom as VD
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Debug.Trace (trace)
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
      vnode (VD.lazy viewMenu model.active)
      div_ ! cls "pure-u-11-12" $
        div_ #! style "margin-left" "2em" $
          case model.active of
            CounterExample ->
              vnode (map CounterMsg $ Counter.view model.counterModel)
            AnimationExample ->
              vnode (map AnimationMsg $ Animation.view model.animationModel)

viewMenu :: Example -> VNode MasterMsg
viewMenu active = trace "viewMenu evaluated" \_  ->
  render $
    nav ! cls "pure-u-1-12 pure-menu" $
      ul ! cls "pure-menu-list" $ do
        li ! menuItemClasses CounterExample $
          a ! cls "pure-menu-link" ! href "#"
            ! onClickPreventDefault (CurrentExample CounterExample)
            $ text "Counter"
        li ! menuItemClasses AnimationExample $
          a ! cls "pure-menu-link" ! href "#"
            ! onClick (CurrentExample AnimationExample)
            $ text "Animation"

  where
    menuItemClasses ex =
      classList
        [ Tuple "pure-menu-item" true
        , Tuple "pure-menu-selected" (ex == active) ]

onClickPreventDefault :: forall msg. msg -> Property msg
onClickPreventDefault msg =
  onWithOptions "click" preventDefaultStopPropagation (const $ pure $ pureCommand msg)

emptyModel :: MasterModel
emptyModel =
  { active: CounterExample
  , counterModel: 0
  , animationModel: Animation.emptyModel
  }

main =
  ( window >>=
    program (ElementId "main") update view emptyModel ) *>
  pure unit
