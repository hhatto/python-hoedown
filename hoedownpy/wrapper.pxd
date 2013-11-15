from _hoedown cimport hoedown_buffer, hoedown_autolink, hoedown_renderer


cdef extern from *:
    ctypedef char* const_char_ptr "const char *"
    ctypedef char* const_size_t "const size_t"

cdef struct _toc_data:
    int header_count
    int current_level
    int level_offset
    int nesting_level

cdef struct rndr_state:
    _toc_data toc_data
    unsigned int flags
    void (*link_attributes)(hoedown_buffer *ob, const hoedown_buffer *url, void *self)


cdef extern from 'wrapper.h':

    struct renderopt:
        rndr_state html
        void *self

    hoedown_renderer callback_funcs
    const_char_ptr method_names[]
    const_size_t method_count
