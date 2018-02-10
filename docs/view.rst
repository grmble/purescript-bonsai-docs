*****************
The View Function
*****************

The *view function* is responsible for displaying the model in the browser.
It always renders the whole model of the application. Because DOM
operations in the browser are moderately expensive, a *Virtual DOM*
is used.

A *Virtual DOM* is a representation of the DOM tree without any
interface to the browser.  This representation of the DOM tree
can be produced very fast.  The *Virtual DOM* also supports
computing a *diff* between two virtual DOM trees.  This diff
can then be applied to the real browser's DOM.  Only changed
DOM nodes will be touched by this patching operation.

Bonsai provides a Smolder-style syntax to produce virtual DOM nodes. [#f2]_
View code is expected to import ``Bonsai.Html``, ``Bonsai.Html.Attributes``
and ``Bonsai.Html.Events``.  These modules provide helper functions
for easily representing HTML content::

    view :: Model -> VNode Msg
    view model =
      render $ div_ $ do
        text $ show model
        button ! onClick Inc $ text "+"
        button ! onClick Dec $ text "-"

``render`` produces a virtual DOM node from the Smolder-style DSL.
``div_`` and ``button`` come from ``Bonsai.Html``, they produce
their corresponding HTML elements.  Child elements are simply nested
in a ``do`` block.  Attributes and event handlers are specified
with ``!`` (this is different from Smolder - Smolder uses different
syntax for event handlers).

If an attribute or event handler is not always needed, a ``Maybe (Property msg)``
can be put on the element with ``!?``.  Elm's virtual DOM has special
helpers for styles, and there is an unconditional and a conditional operator
for styles as well: ``#!`` and ``#!?`` - this is from
an old version of the animation example::

      p #!? (map (\(Color c) -> style "background-color" c) m.color) $
        text m.text

The styles helper just makes it possible to not provide a single style attribute,
but many different styles (some of them conditional).  The DSL takes care
of producing the final style attribute for you.

Note that with the conditional operators, you usually need ``map`` because
you have to lift over the structure of the ``Maybe``.

Also note that class properties (``cls``) are special - if multiple class properties
are present, the virtual DOM will join them (separated by a spaces).  With all
other properties/attributes, later ones overwrite earlier ones.

.. rubric:: Footnotes

.. [#f2] The HTML Api is optional, you can also work with the VirtualDom directly.
