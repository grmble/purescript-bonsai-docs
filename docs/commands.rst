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

Let's look at an example:  you are asked if you want to
download some content.  If the button is pressed, a
progress bar is displayed.  Once the animation plays out,
the question is shown again.

.. raw:: html

    <p><b>Example</b>:</p>
    <div class="example" id="examplesBasicAnimation">
      <p>Loading ...</p>
    </div>


Lets start with the message type. There are 2 states we track:
if there is a download active, and the progress of that download.
::

    data Msg
      = Progress Number
      | InProgress Boolean


The model is simple as well, it holds the information from the commands::

    type Model =
      { progress :: Number
      , inProgress :: Boolean
      }


The update function applies the messages to the model.  This update functions
simply applies the incoming messages to the model.  But it could issue commands
as well::

    update :: forall eff. Model -> Msg -> UpdateResult eff Model Msg
    update model msg =
      plainResult case msg of
        Progress p ->
          model { progress = p }
        InProgress b ->
          model { inProgress = b }


So where are the commands and their messages coming from?
As I said, the update function could issue commands, it just does
not in this example.  In this example, the simulated download
is started when the user clicks a button.
::

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

We have seen examples with ``onClick``.  ``onClick`` is a convenience function
that takes a message and issues a command for it.

Here we see ``on "click"``.
``on`` is not a convenience function, ``on`` is the real deal.
It takes the name of an event ("click") and a ``CmdDecoder``.  This is
a type alias for a function that takes a DOM event and produces a
``Either Error (Cmd eff msg)``.  The ``Either Error`` bit is because
the decoding of DOM events can fail (in my experience, this is actually
the most brittle part about Bonsai programs - the type system can't help
you when you are decoding a javascript object).  And the ``Cmd eff msg``
bit means that it will produce a command of the given side effects and message
type.

``(const $ pure $ emittingTask simulateDownload)`` means: our function will
ignore the event (``const``) and always produce a ``pure`` (i.e. not an error)
``Cmd``.  ``emittingTask`` creates this command, and it takes a function::

    simulateDownload :: forall eff. TaskContext eff Msg -> Aff eff Unit
    simulateDownload ctx = do
      emitMessage ctx (InProgress true)
      for_ (range 1 100) \i -> do
        delay (Milliseconds 50.0)
        emitMessage ctx (Progress $ 0.01 * toNumber i)
      emitMessage ctx (InProgress false)
      pure unit


The source code for this example is at
https://github.com/grmble/purescript-bonsai-docs/blob/master/src/Examples/Basic/Animation.purs


.. raw:: html

    <script type="text/javascript" src="_static/examplesBasicAnimation.js"></script>
