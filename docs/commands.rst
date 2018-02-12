*********************
Messages and Commands
*********************

*Messages* are applied to the model.  The message type
defines the possible actions that can change the model.

*Commands* are a wrapper around these messages, they encode
how the messages are delivered.
There are pure commands and tasks.

*Commands* come from two sources: event handlers,
and the update function. [#f1]_

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

    update msg model =
      Tuple empty
        case msg of
          Progress p ->
            model { progress = p }
          InProgress b ->
            model { inProgress = b }


So where are the commands and their messages coming from?
As I said, the update function could issue commands, it just does
not in this example.  In this example, the simulated download
is started when the user clicks a button.
::

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
that takes a message and issues a command for it - a pure Command, meaning
it will emit that particular message and nothing else.

Here we we don't want to emit just one message, we want several, with
delays in between.  So we have to use ``on``.
It takes the name of an event ("click") and an event handling function.
This is a function that takes a DOM event and produces a
``F (Cmd eff msg)``. ``F`` is from ``Data.Foreign``, it handles
failures and gives you do-notation.

``(const $ pure $ emittingTask simulateDownload)`` means: our function will
ignore the event (``const``) and always produce a sucessful ``F``.
``emittingTask`` is the ``Cmd``:  it is an ``Aff`` (think of it
like a Thread in other programming languages) that can emit as many messages
as it wants because it has a ``TaskContext``::

    simulateDownload :: forall eff. TaskContext eff Msg -> Aff eff Unit
    simulateDownload ctx = do
      emitMessage ctx (InProgress true)
      for_ (range 1 100) \i -> do
        delay (Milliseconds 50.0)
        emitMessage ctx (Progress $ 0.01 * toNumber i)
      emitMessage ctx (InProgress false)


The other types of tasks are ``unitTask``(a task that will not emit any messages, it is
useful only because of its side effects) and ``simpleTask`` (can emit exactly
one message).


The source code for this example is at
https://github.com/grmble/purescript-bonsai-docs/blob/master/src/Examples/Basic/Animation.purs


.. rubric:: Footnotes

.. [#f1] You can also arrange for commands to be issued from outside via ``issueCommand``


.. raw:: html

    <script type="text/javascript" src="_static/examplesBasicAnimation.js"></script>
