*******************
The Update Function
*******************

In Elm (or Bonsai), the *model* of an application contains the complete
state of the application at any point in time.  The model is immutable.
The *view function* displays the complete model in the browser.

This means that any observable change must be caused by a change in the
current model.  How does that work, given that the model is immutable?

Bonsai maintains mutable references for the application:

* a queue of outstanding messages that should be applied to the current model
* the current model

When commands are emitted, their messages will be queued immediately, and
Bonsai will try to apply those messages to the current model as soon as possible.
It will call the applications *update function* with the then current model
and the next outstanding message.  The *update function* is responsible for
producing the next model state and, optionally, another command.

Updating the model state without issuing any new commands is the common case.
The idiom here is ``Tuple empty``.  An example would
be the update function from our earlier counter example::

    update msg model = Tuple empty $
      case msg of
        Inc ->
          model + 1
        Dec ->
          model - 1

A ``Dec`` message will subtract 1 from the current counter, a ``Inc`` message
will add 1.  No additional commands have to be emitted, so it wraps
the new model in ``Tuple empty``.

In an old version of the animation example, we saw an additional case:
a command was issued from the update function.  This is accomplished
by not returning a plain result, but a real one containing the new model
and a (possibly empty) command::

    case msg of
     SetText str ->
       Tuple (pureCommand EndAnimation) (model { text = str } )

Bonsai tries hard to apply as many messages as possible between rendering.  Once
it has applied all queued messages (and all messages emitted by the updates),
and has received no additional messages in the mean time, it will schedule
a render via ``requestAnimationFrame``.  If there still are no unapplied messages
in that animation frame, Bonsai will render the model using the view function.
