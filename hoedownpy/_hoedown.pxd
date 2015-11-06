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
    struct _toc_data:
        int header_count
        int current_level
        int level_offset
        int nesting_level

    struct hoedown_html_renderer_state:
        void *opaque
        _toc_data toc_data
        hoedown_html_flags flags
        void (*link_attributes)(hoedown_buffer *ob, const hoedown_buffer *url, const hoedown_renderer_data *data)

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

    struct hoedown_renderer_data:
        void *opaque

    struct hoedown_renderer:
        # state
        void *opaque

        # Block level callbacks - NULL skips the block
        void (*blockcode)(hoedown_buffer *ob, hoedown_buffer *text, hoedown_buffer *lang, const hoedown_renderer_data *data)
        void (*blockquote)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        void (*header)(hoedown_buffer *ob, hoedown_buffer *text, int level, const hoedown_renderer_data *data)
        void (*hrule)(hoedown_buffer *ob, const hoedown_renderer_data *data)
        void (*list)(hoedown_buffer *ob, hoedown_buffer *text, hoedown_list_flags flags, const hoedown_renderer_data *data)
        void (*listitem)(hoedown_buffer *ob, hoedown_buffer *text, hoedown_list_flags flags, const hoedown_renderer_data *data)
        void (*paragraph)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        void (*table)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        void (*table_header)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        void (*table_body)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        void (*table_row)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        void (*table_cell)(hoedown_buffer *ob, hoedown_buffer *text, hoedown_table_flags flags, const hoedown_renderer_data *data)
        void (*footnotes)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        void (*footnote_def)(hoedown_buffer *ob, hoedown_buffer *text, unsigned int num, const hoedown_renderer_data *data)
        void (*blockhtml)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)

        # Span level callbacks - NULL or return 0 prints the span verbatim
        int (*autolink)(hoedown_buffer *ob, hoedown_buffer *link, hoedown_autolink type, const hoedown_renderer_data *data)
        int (*codespan)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        int (*double_emphasis)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        int (*emphasis)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        int (*underline)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        int (*highlight)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        int (*quote)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        int (*image)(hoedown_buffer *ob, hoedown_buffer *link, hoedown_buffer *title, hoedown_buffer *alt, const hoedown_renderer_data *data)
        int (*linebreak)(hoedown_buffer *ob, const hoedown_renderer_data *data)
        int (*link)(hoedown_buffer *ob, hoedown_buffer *link, hoedown_buffer *title, hoedown_buffer *content, const hoedown_renderer_data *data)
        int (*triple_emphasis)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        int (*strikethrough)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        int (*superscript)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)
        int (*footnote_ref)(hoedown_buffer *ob, unsigned int num, const hoedown_renderer_data *data)
        int (*math)(hoedown_buffer *ob, hoedown_buffer *text, int displaymode, const hoedown_renderer_data *data)
        int (*raw_html)(hoedown_buffer *ob, hoedown_buffer *tag, const hoedown_renderer_data *data)

        # Low level callbacks - NULL copies input directly into the output
        void (*entity)(hoedown_buffer *ob, hoedown_buffer *entity, const hoedown_renderer_data *data)
        void (*normal_text)(hoedown_buffer *ob, hoedown_buffer *text, const hoedown_renderer_data *data)

        # Header and footer
        void (*doc_header)(hoedown_buffer *ob, int inline_render, const hoedown_renderer_data *data)
        void (*doc_footer)(hoedown_buffer *ob, int inline_render, const hoedown_renderer_data *data)

    enum hoedown_table_flags:
        pass

    enum hoedown_html_flags:
        pass

    enum hoedown_list_flags:
        pass

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
