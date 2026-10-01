#include <common/math.hpp>

#include <iostream>

int main() {
  constexpr int limit = 50;

  for (int n = 0; n < limit; ++n) {
    if (common::is_prime(n)) {
      std::cout << n << ' ';
    }
  }

  std::cout << '\n';
}
