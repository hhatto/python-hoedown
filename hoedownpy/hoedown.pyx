cimport _hoedown
cimport wrapper

from libc.stdint cimport uint8_t


# Markdown extensions
EXT_TABLES = (1 << 0)
EXT_FENCED_CODE = (1 << 1)
EXT_FOOTNOTES = (1 << 2)

EXT_AUTOLINK = (1 << 3)
EXT_STRIKETHROUGH = (1 << 4)
EXT_UNDERLINE = (1 << 5)
EXT_HIGHLIGHT = (1 << 6)
EXT_QUOTE = (1 << 7)
EXT_SUPERSCRIPT = (1 << 8)
EXT_MATH = (1 << 9)

EXT_NO_INTRA_EMPHASIS = (1 << 11)
EXT_SPACE_HEADERS = (1 << 12)
EXT_MATH_EXPLICIT = (1 << 13)

EXT_DISABLE_INDENTED_CODE = (1 << 14)

HTML_SKIP_HTML = (1 << 0)
HTML_ESCAPE = (1 << 1)
HTML_HARD_WRAP = (1 << 2)
HTML_USE_XHTML = (1 << 3)

# Extra HTML render flags - these are not from Sundown
HTML_SMARTYPANTS = (1 << 10)  # An extra flag to enable Smartypants
HTML_TOC_TREE = (1 << 11)  # Only render a table of contents tree

# Other flags
TABLE_ALIGN_L = 1 # MKD_TABLE_ALIGN_L
TABLE_ALIGN_R = 2 # MKD_TABLE_ALIGN_R
TABLE_ALIGN_C = 3 # MKD_TABLE_ALIGN_CENTER
TABLE_ALIGNMASK = 3 # MKD_TABLE_ALIGNMASK
TABLE_HEADER = 4 # MKD_TABLE_HEADER


def html(object text, unsigned int extensions=0, unsigned int render_flags=0):
    """Convert markdown text to (X)HTML.

    Returns a unicode string.

    :param text: A byte or unicode string.
    :param extensions: Enable additional Markdown extensions with the ``EXT_*`` constants.
    :param render_flags: Adjust HTML rendering behaviour with the ``HTML_*`` constants.
    """

    if render_flags & HTML_TOC_TREE:
        renderer = HtmlTocRenderer(render_flags)
    else:
        renderer = HtmlRenderer(render_flags)

    markdown = Markdown(renderer, extensions)
    result = markdown.render(text)

    if render_flags & HTML_SMARTYPANTS:
        result = SmartyPants().postprocess(result)

    return result


cdef class SmartyPants:
    """Smartypants is a post-processor for (X)HTML renderers and can be used
    standalone or as a mixin. It adds a methode named ``postprocess`` to the
    renderer.

    ================================== ========
    Source                             Result
    ================================== ========
    `'s` (s, t, m, d, re, ll, ve) [1]_ &rsquo;s
    `--`                               &mdash;
    `-`                                &ndash;
    `...`                              &hellip;
    `. . .`                            &hellip;
    `(c)`                              &copy;
    `(r)`                              &reg;
    `(tm)`                             &trade;
    `3/4`                              &frac34;
    `1/2`                              &frac12;
    `1/4`                              &frac14;
    ================================== ========

    .. [1] A ``'`` followed by a ``s``, ``t``, ``m``, ``d``, ``re``, ``ll`` or
           ``ve`` will be turned into ``&rsquo;s``, ``&rsquo;t``, and so on.
    """
    def postprocess(self, object text):
        """Process the input text.

        Returns a unicode string.

        :param text: A byte or unicode string.
        """
        # Convert string
        cdef bytes py_string
        if hasattr(text, 'encode'):
            py_string = text.encode('UTF-8', 'strict')
        else:
            py_string = text
        cdef char *c_string = py_string

        cdef _hoedown.hoedown_buffer *ob = _hoedown.hoedown_buffer_new(128)
        _hoedown.hoedown_html_smartypants(ob,
            <uint8_t *> c_string, len(c_string))

        try:
            return (<char *> ob.data)[:ob.size].decode('UTF-8', 'strict')
        finally:
            _hoedown.hoedown_buffer_free(ob)


cdef class BaseRenderer:
    """The ``BaseRenderer`` is boilerplate code for creating your own renderers by
    sublassing `BaseRenderer`. It takes care of setting the callbacks and flags.

    :param flags: Available as a read-only, integer type attribute named ``self.flags``.
    """

    cdef _hoedown.hoedown_renderer *callbacks
    cdef wrapper.renderopt *options

    #: Read-only render flags
    cdef readonly int flags

    def __init__(self, int flags=0):
        self.flags = flags
        self.setup()

        cdef _hoedown.hoedown_html_renderer_state *state
        if self.callbacks is not NULL:
            state = <_hoedown.hoedown_html_renderer_state *> self.callbacks.opaque
            state.opaque = <void *> self

        # Set callbacks
        cdef void **source = <void **> &wrapper.callback_funcs
        cdef void **dest = <void **> self.callbacks

        cdef unicode method_name
        for i from 0 <= i < <int> wrapper.method_count by 1:
            # In Python 3 ``wrapper.method_names[i]`` is a byte string.
            # This means hasattr can't find any method in the renderer, so
            # ``wrapper.method_names[i]`` is converted to a normal string first.
            method_name = wrapper.method_names[i].decode('utf-8')
            if hasattr(self, method_name):
                dest[i+1] = source[i+1]

    def setup(self):
        """A method that can be overridden by the renderer that sublasses ``BaseRenderer``.
        It's called everytime an instance of a renderer is created.
        """
        pass

    def __dealloc__(self):
        if self.callbacks is not NULL:
            _hoedown.hoedown_html_renderer_free(self.callbacks)


cdef class HtmlRenderer(BaseRenderer):
    """The HTML renderer that's included in Sundown.

    Do you override the ``setup`` method when subclassing ``HtmlRenderer``. If
    you do make sure to call parent class' ``setup`` method first.

    :param flags: Adjust HTML rendering behaviour with the ``HTML_*`` constants.
    """
    def setup(self):
        self.callbacks = _hoedown.hoedown_html_renderer_new(self.flags, 0)


cdef class HtmlTocRenderer(BaseRenderer):
    """The HTML table of contents renderer that's included in Sundown.

    Do you override the ``setup`` method when subclassing ``HtmlTocRenderer``.
    If you do make sure to call parent class' ``setup`` method first.

    :param flags: Adjust HTML rendering behaviour with the ``HTML_*`` constants.
    """
    def setup(self):
        self.callbacks = _hoedown.hoedown_html_toc_renderer_new(0)


cdef class Markdown:
    """The Markdown parser.

    :param renderer: An instance of ``BaseRenderer``.
    :param extensions: Enable additional Markdown extensions with the ``EXT_*`` constants.
    """

    cdef _hoedown.hoedown_document *document
    cdef BaseRenderer renderer

    def __cinit__(self, object renderer, _hoedown.hoedown_extensions extensions=<_hoedown.hoedown_extensions>0):
        if not isinstance(renderer, BaseRenderer):
            raise ValueError('expected instance of BaseRenderer, %s found' % \
                renderer.__class__.__name__)

        self.renderer = renderer
        self.document = _hoedown.hoedown_document_new(self.renderer.callbacks, extensions, 16)

    def render(self, object text):
        """Render the Markdon text.

        Returns a unicode string.

        :param text: A byte or unicode string.
        """
        if hasattr(self.renderer, 'preprocess'):
            text = self.renderer.preprocess(text)

        # Convert string
        cdef bytes py_string
        if hasattr(text, 'encode'):
            py_string = text.encode('UTF-8', 'strict')
        else:
            py_string = text  # If it's a byte string it's assumed it's UTF-8
        cdef char *c_string = py_string

        # Buffers
        cdef _hoedown.hoedown_buffer *ib = _hoedown.hoedown_buffer_new(1024)
        _hoedown.hoedown_buffer_puts(ib, c_string)

        cdef _hoedown.hoedown_buffer *ob = _hoedown.hoedown_buffer_new(128)
        _hoedown.hoedown_buffer_grow(ob, <size_t> (ib.size * 1.4))

        # Parse! And make a unicode string
        _hoedown.hoedown_document_render(self.document, ob, ib.data, ib.size)
        text = (<char *> ob.data)[:ob.size].decode('UTF-8', 'strict')

        if hasattr(self.renderer, 'postprocess'):
            text = self.renderer.postprocess(text)

        # Return a string and release buffers
        try:
            return text
        finally:
            _hoedown.hoedown_buffer_free(ob)
            _hoedown.hoedown_buffer_free(ib)

    def __dealloc__(self):
        if self.document is not NULL:
            _hoedown.hoedown_document_free(self.document)
