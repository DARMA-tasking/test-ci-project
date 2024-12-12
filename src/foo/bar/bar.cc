#include "foo/bar/bar.h"

// #include <nanobind/nanobind.h>

// namespace nb = nanobind;

// using namespace nb::literals;

namespace foo::bar {

int Bar::diff(int a, int b) const {
    return a - b;
}

} // namespace foo