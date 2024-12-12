#include <gtest/gtest.h>

#include "foo/bar/bar.h"

// Demonstrate some basic assertions.
TEST(BarTest, BasicAssertions) {
  auto bar = foo::bar::Bar();
  auto n = bar.diff(5, 3);
  EXPECT_EQ(n, 2);
}
