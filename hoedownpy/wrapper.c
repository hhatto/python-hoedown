#define PY_SSIZE_T_CLEAN
#include <Python.h>

#include "_hoedown/src/document.h"
#include "_hoedown/src/buffer.h"

#include "wrapper.h"


#define PROCESS_SPAN(method_name, ...) {\
    struct renderopt *opt = opaque;\
    PyObject *ret = PyObject_CallMethodObjArgs(\
        (PyObject *) opt->self, PyUnicode_FromString(method_name),\
        __VA_ARGS__);\
    if (ret == NULL || ret == Py_None) {\
        PyObject *r_ex = PyErr_Occurred();\
        if (r_ex != NULL)\
            PyErr_Print();\
        return 0;\
    }\
    if (PyUnicode_Check(ret)) {\
        PyObject *byte_string = PyUnicode_AsEncodedString(ret, "utf-8", "strict");\
        hoedown_buffer_puts(ob, PyBytes_AsString(byte_string));\
    } else {\
        hoedown_buffer_puts(ob, PyBytes_AsString(ret));\
    }\
    return 1;\
}


#define PROCESS_BLOCK(method_name, ...) {\
    struct renderopt *opt = opaque;\
    PyObject *ret = PyObject_CallMethodObjArgs(\
        (PyObject *) opt->self, PyUnicode_FromString(method_name),\
        __VA_ARGS__);\
    if (ret == NULL || ret == Py_None) {\
        PyObject *r_ex = PyErr_Occurred();\
        if (r_ex != NULL)\
            PyErr_Print();\
        return;\
    }\
    if (PyUnicode_Check(ret)) {\
        PyObject *byte_string = PyUnicode_AsEncodedString(ret, "utf-8", "strict");\
        hoedown_buffer_puts(ob, PyBytes_AsString(byte_string));\
    } else {\
        hoedown_buffer_puts(ob, PyBytes_AsString(ret));\
    }\
}


#define PY_STR(b) (b != NULL ? PyUnicode_FromStringAndSize((const char *) b->data, (int) b->size) : Py_None)

#if PY_MAJOR_VERSION >= 3
    #define PY_INT(i) PyLong_FromLong(i)
#else
    #define PY_INT(i) PyInt_FromLong(i)
#endif


/* Block level
   ----------- */


static void
rndr_blockcode(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_buffer *lang, const void *opaque)
{
    PROCESS_BLOCK("block_code", PY_STR(text), PY_STR(lang), NULL);
}


static void
rndr_blockquote(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_BLOCK("block_quote", PY_STR(text), NULL);
}


static void
rndr_raw_block(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_BLOCK("block_html", PY_STR(text), NULL);
}


static void
rndr_header(hoedown_buffer *ob, const hoedown_buffer *text, int level, const void *opaque)
{
    PROCESS_BLOCK("header", PY_STR(text), PY_INT(level), NULL);
}


static void
rndr_hrule(hoedown_buffer *ob, const void *opaque)
{
    PROCESS_BLOCK("hrule", NULL);
}


static void
rndr_list(hoedown_buffer *ob, const hoedown_buffer *text, int flags, const void *opaque)
{
    PyObject *is_ordered = Py_False;
    if (flags & HOEDOWN_LIST_ORDERED) {
        is_ordered = Py_True;
    }

    PROCESS_BLOCK("list", PY_STR(text), is_ordered, NULL);
}


static void
rndr_listitem(hoedown_buffer *ob, const hoedown_buffer *text, int flags, const void *opaque)
{
    PyObject *is_ordered = Py_False;
    if (flags & HOEDOWN_LIST_ORDERED) {
        is_ordered = Py_True;
    }

    PROCESS_BLOCK("list_item", PY_STR(text), is_ordered, NULL);
}


static void
rndr_paragraph(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_BLOCK("paragraph", PY_STR(text), NULL);
}


static void
rndr_table(hoedown_buffer *ob, const hoedown_buffer *header, const hoedown_buffer *body, const void *opaque)
{
    PROCESS_BLOCK("table", PY_STR(header), PY_STR(body), NULL);
}


static void
rndr_tablerow(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_BLOCK("table_row", PY_STR(text), NULL);
}


static void
rndr_tablecell(hoedown_buffer *ob, const hoedown_buffer *text, int flags, const void *opaque)
{
    PROCESS_BLOCK("table_cell", PY_STR(text), PY_INT(flags), NULL);
}


static void
rndr_footnotes(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_BLOCK("footnotes", PY_STR(text), NULL);
}


static void
rndr_footnote_def(hoedown_buffer *ob, const hoedown_buffer *text, unsigned int num, const void *opaque)
{
    PROCESS_BLOCK("footnote_def", PY_STR(text), PY_INT(num), NULL);
}


/* Span level
   ---------- */


static int
rndr_autolink(hoedown_buffer *ob, const hoedown_buffer *link, hoedown_autolink_type type, const void *opaque)
{
    PyObject *is_email = Py_False;
    if (type == HOEDOWN_AUTOLINK_EMAIL) {
        is_email = Py_True;
    }

    PROCESS_SPAN("autolink", PY_STR(link), is_email, NULL);
}


static int
rndr_codespan(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_SPAN("codespan", PY_STR(text), NULL);
}


static int
rndr_double_emphasis(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_SPAN("double_emphasis", PY_STR(text), NULL);
}


static int
rndr_emphasis(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_SPAN("emphasis", PY_STR(text), NULL);
}


static int
rndr_underline(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_SPAN("underline", PY_STR(text), NULL);
}


static int
rndr_highlight(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_SPAN("highlight", PY_STR(text), NULL);
}


static int
rndr_quote(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_SPAN("quote", PY_STR(text), NULL);
}


static int
rndr_image(hoedown_buffer *ob, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_buffer *alt, const void *opaque)
{
    PROCESS_SPAN("image", PY_STR(link), PY_STR(title), PY_STR(alt), NULL);
}


static int
rndr_linebreak(hoedown_buffer *ob, const void *opaque)
{
    PROCESS_SPAN("linebreak", NULL);
}


static int
rndr_link(hoedown_buffer *ob, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_buffer *content, const void *opaque)
{
    PROCESS_SPAN("link", PY_STR(link), PY_STR(title), PY_STR(content), NULL);
}


static int
rndr_raw_html(hoedown_buffer *ob, const hoedown_buffer *text, const void *opaque)
{
    PROCESS_SPAN("raw_html", PY_STR(text), NULL);
}


static int
rndr_triple_emphasis(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque)
{
    PROCESS_SPAN("triple_emphasis", PY_STR(text), NULL);
}


static int
rndr_strikethrough(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque)
{
    PROCESS_SPAN("strikethrough", PY_STR(text), NULL);
}


static int
rndr_superscript(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque)
{
    PROCESS_SPAN("superscript", PY_STR(text), NULL);
}


static int
rndr_footnote_ref(hoedown_buffer *ob, unsigned int num, void *opaque)
{
    PROCESS_SPAN("footnote_ref", PY_INT(num), NULL);
}


/* Direct writes
   ------------- */


static void
rndr_entity(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque)
{
    PROCESS_BLOCK("entity", PY_STR(text), NULL);
}


static void
rndr_normal_text(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque)
{
    PROCESS_BLOCK("normal_text", PY_STR(text), NULL);
}


static void
rndr_doc_header(hoedown_buffer *ob, void *opaque)
{
    PROCESS_BLOCK("doc_header", NULL);
}


static void
rndr_doc_footer(hoedown_buffer *ob, void *opaque)
{
    PROCESS_BLOCK("doc_footer", NULL);
}


struct hoedown_renderer callback_funcs = {
    /* block level callbacks */
    rndr_blockcode,
    rndr_blockquote,
    rndr_raw_block,
    rndr_header,
    rndr_hrule,
    rndr_list,
    rndr_listitem,
    rndr_paragraph,
    rndr_table,
    rndr_tablerow,
    rndr_tablecell,
    rndr_footnotes,
    rndr_footnote_def,

    /* span level callbacks */
    rndr_autolink,
    rndr_codespan,
    rndr_double_emphasis,
    rndr_emphasis,
    rndr_underline,
    rndr_highlight,
    rndr_quote,
    rndr_image,
    rndr_linebreak,
    rndr_link,
    rndr_raw_html,
    rndr_triple_emphasis,
    rndr_strikethrough,
    rndr_superscript,
    rndr_footnote_ref,

    /* low level callbacks */
    rndr_entity,
    rndr_normal_text,

    /* header and footer */
    rndr_doc_header,
    rndr_doc_footer,

    /* state object */
    NULL,
};


const char *method_names[] = {
    /* block level */
    "block_code",
    "block_quote",
    "block_html",
    "header",
    "hrule",
    "list",
    "list_item",
    "paragraph",
    "table",
    "table_row",
    "table_cell",
    "footnotes",
    "footnote_def",

    /* span level */
    "autolink",
    "codespan",
    "double_emphasis",
    "emphasis",
    "underline",
    "highlight",
    "quote",
    "image",
    "linebreak",
    "link",
    "raw_html",
    "triple_emphasis",
    "strikethrough",
    "superscript",
    "footnote_ref",

    /* low level */
    "entity",
    "normal_text",

    /* header and footer */
    "doc_header",
    "doc_footer"
};


const size_t method_count = sizeof(
    method_names)/sizeof(char *);
