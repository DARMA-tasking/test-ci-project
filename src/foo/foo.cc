#include "foo/foo.h"

// #include <nanobind/nanobind.h>

// namespace nb = nanobind;

// using namespace nb::literals;

namespace foo {

int Foo::sum(int a, int b) const {
    return a + b;
}

} // namespace foo