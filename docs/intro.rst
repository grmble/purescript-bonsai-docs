************
Introduction
************

*purescript-bonsai* is a functional web programming framework
for *purescript*.  It uses
Elm's VirtualDom implementation (the part written in javascript, anyway)
and adds the necessary plumbing to make it work with purescript.

The Elm Virtual Dom is tied pretty tightly to how Elm works,
so Bonsai follows Elm in a lot of basic design decisions.
In particular, the general structure of an application is the same:
*TEA* as in "The Elm Architecture".

There is a *Message* type that defines what actions are
possible on the *Model*.  The *Model* is another type
that defines the whole state of the application.
All changes to this *Model* go through an *update function*.
The *update function* applies messages to the current model
and produces a new model.

When the model changes, a *view function* will be called
that produces a tree of *Virtual Dom nodes*.
This *Virtual Dom tree* is then rendered in the browser.

A classical example for a functional web app is a *Counter*.
It displays a number, a "+" button and a "-" button.
Clicking the buttons changes the number that is displayed.

.. raw:: html

    <p><b>Example</b>:</p>
    <div class="example" id="examplesBasicCounter">
      <p>Loading ...</p>
    </div>

In this case, the *Model* is simply an ``Int``.  The messages can be
``Inc`` or ``Dec``::

    type Model = Int

    data Msg
      = Inc
      | Dec

The *update function* applies these messages to the current count.
It returns a *Tuple* of command and model.  Here the command is
empty, but it could also return commands to apply more messages::

    update msg model = Tuple empty $
      case msg of
        Inc ->
          model + 1
        Dec ->
          model - 1

The *view function* produces a tree of *Virtual DOM nodes*.
Note that the model never changes, rather a new model
(in this case a new number) is produced.  The view function
always paints the whole state of the application::

    view model =
      render $ div_ $ do
        text $ show model
        button ! onClick Inc $ text "+"
        button ! onClick Dec $ text "-"

I've glossed over some things like imports or types
or how the application is started.  These will be discussed
later on, but you can also look at the complete
source code of the counter example:

https://github.com/grmble/purescript-bonsai-docs/blob/master/src/Examples/Basic/Counter.purs


.. raw:: html

    <script type="text/javascript" src="_static/examplesBasicCounter.js"></script>
