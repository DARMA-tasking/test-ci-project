#if !defined FOO_BAR_H
#define FOO_BAR_H

namespace foo::bar {

/**
 * \struct Foo
 *
 * \brief A sample class for demo
 *
 */
struct Bar {
  Bar() {
  }

  /**
   * \brief Calculates the difference of two integers.
   */
  int diff(int a , int b) const {
    return a - b;
  }

};

}

#endif /*FOO_BAR_H*/
