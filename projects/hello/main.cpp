#include <common/math.hpp>
#include <common/run_main.hpp>

#include <cstdint>
#include <iostream>

int main() {
  return common::run_main([] {
    constexpr std::int64_t candidate = 97;
    std::cout << "Hello from projects/hello. Is " << candidate << " prime? " << std::boolalpha
              << common::is_prime(candidate) << '\n';
  });
}
