from _hoedown cimport hoedown_buffer, mkd_autolink, hoedown_renderer


cdef extern from *:
    ctypedef char* const_char_ptr "const char *"
    ctypedef char* const_size_t "const size_t"


cdef extern from 'wrapper.h':
    #hoedown_renderer callback_funcs
    #const_char_ptr method_names[]
    const_size_t method_count
