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
it's content is echoed in a html element.  There are also 3 buttons,
one that paints the paragraph red, one that paints it green,
and one that starts an animation.

.. raw:: html

    <div>
      <div id="examplesBasicAnimation"/>
      <script type="text/javascript" src="_static/examplesBasicAnimation.js"></script>
    </div>

Lets start with the message type. There are 3 possible actions: the text
changes, the text background color is set, and the text default background color
is restored::

    newtype Color =
      Color String

    data Msg
      = SetText String
      | Animate Color
      | EndAnimation


The model is simple as well:  there is the current text, and the current background color.
The background-color is optional, if it's not present the default background color is
used::

    type Model =
      { text :: String
      , color :: Maybe Color
      }

The update function applies the messages to the model.  It does not
need to emit any commands, but it could if it wanted to::

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


So where are the commands and their messages coming from?
From event handlers, and those are defined in the view function::

    view :: Model -> VNode Msg
    view m =
      render $
        div_ $ do
          input ! onInput SetText ! value m.text
          p #!? (map (\(Color c) -> style "background-color" c) m.color) $
            text m.text
          button ! onClick (Animate (Color "#FF0000")) $ text "Red"

Let's start with a simplified version.  There are two event handlers here:
``onInput`` and ``onClick``.  Both are convenience functions.  ``onInput``
will extract the current value of an input field from the HTML ``input``
event, in this example it passes that String to the ``SetText`` constructor.
If the event fires, a pure ``SetText`` command will be emitted.  It will
bubble up Virtual Dom (maybe being mapped between message types) and
will finally show up as an argument to the update function.

``onClick`` is the same, except it just emits a pure command with the message
given, no decoding of the event is necessary.

So let's add the third button that does a little color animation::

          button ! on "click" (const $ pure $ readerTask animate) $ text "Animate"

So what is happening here? ``on`` is not a convenience function, ``on`` is the real deal.
It takes the name of an event ("click") and a ``CmdDecoder``.  This is
a type alias for a function that takes a DOM event and produces a
``Either Error (Cmd eff msg)``.  The ``Either Error`` bit is because
the decoding of DOM events can fail (in my experience, this is actually
the most brittle part about Bonsai programs - the type system can't help
you when you are decoding a javascript object).  And the ``Cmd eff msg``
bit means that it will produce a command of the given side effects and message
type.

So ``(const $ pure $ readerTask animate)`` means: our function will
ignore the event (``const``) and always produce a ``pure`` (i.e. not an error)
``Cmd``.  ``readerTask`` creates this command, and it takes a function::

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

So ``animate`` gets a ``TaskContext`` - this is what allows it to emit
messages any time it pleases.  It just loops through 8 different hues
of yellow and emits them with 200 milliseconds delay.

The source code for this example is at
https://github.com/grmble/purescript-bonsai-docs/blob/master/src/Examples/Basic/Animation.purs
