#include <common/math.hpp>

#include <doctest/doctest.h>

#include <array>
#include <cstdint>
#include <limits>

TEST_CASE("is_prime: values below 2 are not prime") {
  constexpr std::array<std::int64_t, 3> values{-7, 0, 1};
  for (const std::int64_t n : values) {
    CAPTURE(n);
    CHECK_FALSE(common::is_prime(n));
  }
}

TEST_CASE("is_prime: small numbers") {
  constexpr std::array<std::int64_t, 5> primes{2, 3, 5, 7, 97};
  constexpr std::array<std::int64_t, 5> composites{4, 6, 9, 25, 91};
  for (const std::int64_t n : primes) {
    CAPTURE(n);
    CHECK(common::is_prime(n));
  }
  for (const std::int64_t n : composites) {
    CAPTURE(n);
    CHECK_FALSE(common::is_prime(n));
  }
}

TEST_CASE("is_prime: large numbers") {
  constexpr std::int64_t mersenne_prime_31 = 2'147'483'647;
  constexpr std::int64_t prime_1e9_plus_7 = 1'000'000'007;
  CHECK(common::is_prime(mersenne_prime_31));
  CHECK(common::is_prime(prime_1e9_plus_7));
  CHECK_FALSE(common::is_prime(prime_1e9_plus_7 * 3));
  CHECK_FALSE(common::is_prime(std::numeric_limits<std::int64_t>::max()));
}
