#include <gtest/gtest.h>

#include "foo/foo.h"

// Demonstrate some basic assertions.
TEST(FooUnitTests, TestFooSum) {
  auto foo = foo::Foo();
  auto n = foo.sum(5, 3);
  EXPECT_EQ(n, 8);
}
