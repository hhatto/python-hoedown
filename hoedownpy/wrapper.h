#define PY_SSIZE_T_CLEAN
#include <Python.h>

struct rndr_state {
    struct {
        int header_count;
        int current_level;
        int level_offset;
        int nesting_level;
    } toc_data;

    unsigned int flags;

    /* extra callbacks */
    void (*link_attributes)(hoedown_buffer *ob, const hoedown_buffer *url, void *self);
};

struct renderopt {
    struct rndr_state html;
    void *self;
};

extern hoedown_renderer callback_funcs;
extern const char *method_names[];
extern const size_t method_count;
