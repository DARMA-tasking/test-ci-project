#if !defined FOO_H
#define FOO_H

namespace foo {

/**
 * \struct Foo
 *
 * \brief A sample class for demo
 *
 */
struct Foo {
  Foo() {
  }

  /**
   * \brief Calculates the sum of two integers.
   */
  int sum(int a , int b) const;
};

}

#endif /*FOO_H*/
