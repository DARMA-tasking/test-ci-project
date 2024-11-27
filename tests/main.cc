
#include <gtest/gtest.h>

extern "C" {
void __ubsan_on_report() {
  FAIL() << "Encountered an undefined behavior sanitizer error";
}

void __asan_on_error() {
  FAIL() << "Encountered an address sanitizer error";
}
}

int main(int argc, char** argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
  ;
}