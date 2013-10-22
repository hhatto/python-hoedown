python-hoedown
==============

.. image:: https://secure.travis-ci.org/hhatto/python-hoedown.png?branch=master
    :target: https://travis-ci.org/hhatto/python-hoedown

The Python binding for hoedown_, a markdown parsing library.
the original code of the misaka_ library by Frank Smit.

.. _hoedown: https://github.com/hoedown/hoedown
.. _misaka: https://github.com/FSX/misaka


Installation
------------

Cython is only needed to compile .pyx file.

With pip::

    pip install hoedown

Or manually::

    python setup.py install


Example
-------

Very simple example::

    from hoedown import Markdown, HtmlRenderer

    rndr = HtmlRenderer()
    md = Markdown(rndr)

    print md.render('some text')

Or::

    import hoedown as m
    print m.html('some other text')


Command Line Tool
-----------------

output from Markdown to HTML::

    hoedownpy MARKDOWNFILE.md

