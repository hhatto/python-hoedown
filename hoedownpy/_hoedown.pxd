from libc.stdint cimport uint8_t


cdef extern from '_hoedown/src/buffer.h':
    struct hoedown_buffer:
        uint8_t *data
        size_t size
        size_t asize
        size_t unit

    hoedown_buffer* hoedown_buffer_new(size_t)
    int hoedown_buffer_grow(hoedown_buffer *, size_t)
    void hoedown_buffer_cstr(hoedown_buffer *)
    void hoedown_buffer_free(hoedown_buffer *)
    void hoedown_buffer_puts(hoedown_buffer *, char *)


cdef extern from '_hoedown/src/html.h':
    hoedown_renderer *hoedown_html_renderer_new(
        unsigned int render_flags,
        int nesting_level)
    hoedown_renderer *hoedown_html_toc_renderer_new(
        int nesting_level)
    void hoedown_html_renderer_free(hoedown_renderer *renderer)
    void hoedown_html_smartypants(
        hoedown_buffer *ob,
        uint8_t *text,
        size_t size)


cdef extern from '_hoedown/src/document.h':

    struct hoedown_renderer:
        # state
        void *opaque

        # Block level callbacks - NULL skips the block
        void (*blockcode)(hoedown_buffer *ob, hoedown_buffer *text, hoedown_buffer *lang, const void *opaque)
        void (*blockquote)(hoedown_buffer *ob, hoedown_buffer *text, const void *opaque)
        void (*header)(hoedown_buffer *ob, hoedown_buffer *text, int level, void *opaque)
        void (*hrule)(hoedown_buffer *ob, void *opaque)
        void (*list)(hoedown_buffer *ob, hoedown_buffer *text, int flags, void *opaque)
        void (*listitem)(hoedown_buffer *ob, hoedown_buffer *text, int flags, void *opaque)
        void (*paragraph)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        void (*table)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        void (*table_header)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        void (*table_body)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        void (*table_row)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        void (*table_cell)(hoedown_buffer *ob, hoedown_buffer *text, int flags, void *opaque)
        void (*footnotes)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        void (*footnote_def)(hoedown_buffer *ob, hoedown_buffer *text, unsigned int num, void *opaque)
        void (*blockhtml)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)

        # Span level callbacks - NULL or return 0 prints the span verbatim
        int (*autolink)(hoedown_buffer *ob, hoedown_buffer *link, hoedown_autolink type, void *opaque)
        int (*codespan)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        int (*double_emphasis)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        int (*emphasis)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        int (*underline)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        int (*highlight)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        int (*quote)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        int (*image)(hoedown_buffer *ob, hoedown_buffer *link, hoedown_buffer *title, hoedown_buffer *alt, void *opaque)
        int (*linebreak)(hoedown_buffer *ob, void *opaque)
        int (*link)(hoedown_buffer *ob, hoedown_buffer *link, hoedown_buffer *title, hoedown_buffer *content, void *opaque)
        int (*triple_emphasis)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        int (*strikethrough)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        int (*superscript)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)
        int (*footnote_ref)(hoedown_buffer *ob, unsigned int num, void *opaque)
        int (*math)(hoedown_buffer *ob, hoedown_buffer *text, int displaymode, void *opaque)
        int (*raw_html_tag)(hoedown_buffer *ob, hoedown_buffer *tag, void *opaque)

        # Low level callbacks - NULL copies input directly into the output
        void (*entity)(hoedown_buffer *ob, hoedown_buffer *entity, void *opaque)
        void (*normal_text)(hoedown_buffer *ob, hoedown_buffer *text, void *opaque)

        # Header and footer
        void (*doc_header)(hoedown_buffer *ob, int inline_render, void *opaque)
        void (*doc_footer)(hoedown_buffer *ob, int inline_render, void *opaque)

    enum hoedown_autolink:
        pass

    enum hoedown_extensions:
        pass

    struct hoedown_document:
        pass

    hoedown_document *hoedown_document_new(
        hoedown_renderer *callbacks,
        hoedown_extensions extensions,
        size_t max_nesting)
    void hoedown_document_render(
        hoedown_document *doc,
        hoedown_buffer *ob,
        const uint8_t *data,
        size_t doc_size)
    void hoedown_document_free(hoedown_document *doc)
    void hoedown_version(int *major, int *minor, int *revision)
