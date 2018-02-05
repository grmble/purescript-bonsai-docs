module Main where

import Prelude

import Bonsai (Cmd, ElementId(..), program, window)
import Bonsai.Html (VNode, a, div_, li, nav, render, text, ul, vnode, (!), (#!))
import Bonsai.Html.Attributes (classList, cls, href, style)
import Bonsai.Html.Events (onClickPreventDefault)
import Bonsai.VirtualDom as VD
import Control.Plus (empty)
import Data.Bifunctor (bimap)
import Data.Tuple (Tuple(..))
import Debug.Trace (trace)
import Examples.Basic.Animation as Animation
import Examples.Basic.Counter as Counter

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

update :: forall eff. MasterMsg -> MasterModel -> Tuple (Cmd eff MasterMsg) MasterModel
update msg model =
  case msg of
    CurrentExample example ->
      Tuple empty $ model { active = example }
    CounterMsg counterMsg ->
      bimap (map CounterMsg) ( model { counterModel = _ } )
        (Counter.update counterMsg model.counterModel)
    AnimationMsg animationMsg ->
      bimap (map AnimationMsg) ( model { animationModel = _ } )
        (Animation.update animationMsg model.animationModel)

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
            ! onClickPreventDefault (CurrentExample AnimationExample)
            $ text "Animation"

  where
    menuItemClasses ex =
      classList
        [ Tuple "pure-menu-item" true
        , Tuple "pure-menu-selected" (ex == active) ]

emptyModel :: MasterModel
emptyModel =
  { active: CounterExample
  , counterModel: 0
  , animationModel: Animation.emptyModel
  }

main =
  ( window #
    program (ElementId "main") update view emptyModel ) *>
  pure unit
