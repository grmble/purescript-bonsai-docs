*******************
The Update Function
*******************

In Elm (or Bonsai), the *model* of an application contains the complete
state of the application at any point in time.  The model is immutable.
The *view function* displays the complete model in the browser.

This means that any observable change must be caused by a change in the
current model.  How does that work, given that the model is immutable?

Bonsai maintains two mutable references for the application:

* a queue of outstanding messages that should be applied to the current model
* the current model

When commands are emitted, their messages will be queued immediately, and
Bonsai will try to apply those messages to the current model as soon as possible.
It will call the applications *update function* with the then current model
and the next outstanding message.  The *update function* is responsible for
producing the next model state and, optionally, another command.

Updating the model state without issuing any new commands is the common case.
There is a helper function ``plainResult`` for this.  An example would
be the update function from our earlier counter example::

    update :: forall eff. Model -> Msg -> UpdateResult eff Model Msg
    update model msg = plainResult $
      case msg of
        Inc ->
          model + 1
        Dec ->
          model - 1

A ``Dec`` message will subtract 1 from the current counter, a ``Inc`` message
will add 1.  No additional commands have to be emitted, it's a plain ``UpdateResult``.

In the animation example, we saw an additional case:  the animation was cancelled
(or at least, it's effects prevented from being observed) when the text changed.
Sometimes it is convenient to not do all the model changes when applying the initial
message, but rather emit additional commands to handle common behaviour::

    case msg of
     SetText str ->
       { model: model { text = str }
       , cmd: pureCommand EndAnimation }

Every time a ``SetText`` messages is applied to the model, a command for
``EndAnimation`` will be emitted.

Bonsai tries hard to apply as many messages as possible between rendering.  Once
it has applied all queued messages (and all messages emitted by the updates),
and has received no additional messages in the mean time, it will schedule
a render via ``requestAnimationFrame``.  If there still are no unapplied messages
in that animation frame, Bonsai will render the model using the view function.
