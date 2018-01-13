*********************
Messages and Commands
*********************

*Messages* are applied to the model.  The message type
defines the possible actions that can change the model.

*Commands* are a wrapper around these messages, they encode
how these messages are delivered.  Basically, there are
pure commands and tasks.

*Commands* come from two sources: event handlers,
and the update function.

Let's look at an example:  there is a text input field,
it's content is echoed in a html element.  One that starts
the animation and one that stops it. Changing the text will also stop an Animation
if it's running.

.. raw:: html

    <div id="examplesBasicAnimation">
    </div>

Lets start with the message type. There are 3 possible actions: the text
changes, the text background color is set, and the text default background color
is restored::

    newtype Color =
      Color String

    data Msg
      = SetText String
      | StartAnimation
      | Animate Color
      | EndAnimation

The model is simple as well:  there is the current text, and the current background color.
The background-color is optional, if it's not present the default background color is
used::

    type Model =
      { text :: String
      , color :: Maybe Color
      }

The update function applies the messages to the model.  If the text is changed,
the update function emits a StopAnimation command, otherwise it just applies
the messages to the model::

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


So where are the commands and their messages coming from?
From event handlers, and those are defined in the view function::

    view :: Model -> VNode Msg
    view m =
      render $
        div_ $ do
          input ! onInput SetText ! value m.text
          p #!? (map (\(Color c) -> style "background-color" c) m.color) $
            text m.text
          button ! onClick EndAnimation $ text "Stop Animation"

Let's start with a simplified version.  There are two event handlers here:
``onInput`` and ``onClick``.  Both are convenience functions.  ``onInput``
will extract the current value of an input field from the HTML ``input``
event, in this example it passes that String to the ``SetText`` constructor.
If the event fires, a pure ``SetText`` command will be emitted.  It will
bubble up Virtual Dom (maybe being mapped between message types) and
will finally show up as an argument to the update function.

``onClick`` is the same, except it just emits a pure command with the message
given, no decoding of the event is necessary.

Let's add the second button that does a little color animation::

    button ! on "click" (const $ pure $ emittingTask animate) $ text "Animation"

What is happening here? ``on`` is not a convenience function, ``on`` is the real deal.
It takes the name of an event ("click") and a ``CmdDecoder``.  This is
a type alias for a function that takes a DOM event and produces a
``Either Error (Cmd eff msg)``.  The ``Either Error`` bit is because
the decoding of DOM events can fail (in my experience, this is actually
the most brittle part about Bonsai programs - the type system can't help
you when you are decoding a javascript object).  And the ``Cmd eff msg``
bit means that it will produce a command of the given side effects and message
type.

``(const $ pure $ emittingTask animate)`` means: our function will
ignore the event (``const``) and always produce a ``pure`` (i.e. not an error)
``Cmd``.  ``emittingTask`` creates this command, and it takes a function::

    animate :: forall eff. TaskContext eff Msg -> Aff eff Unit
    animate ctx = do
      emitMessage ctx StartAnimation
      for_ (range 0 0xF)
        animateColor
      pure [ EndAnimation ]

      where
        animateColor x = do
          let s = toStringAs hexadecimal x
          let css = "#FFFF" <> s <> "F"
          emitMessages ctx $ Animate (Color css)
          delay (Milliseconds 400.0)

``animate`` gets a ``TaskContext`` - this is what allows it to emit
messages any time it pleases.  It just loops through 8 different hues
of yellow and emits them with 200 milliseconds delay.

The source code for this example is at
https://github.com/grmble/purescript-bonsai-docs/blob/master/src/Examples/Basic/Animation.purs


.. raw:: html

    <script type="text/javascript" src="_static/examplesBasicAnimation.js"></script>
