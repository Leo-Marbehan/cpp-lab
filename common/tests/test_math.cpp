#include <common/math.hpp>

#include <doctest/doctest.h>

#include <cstdint>
#include <limits>

TEST_CASE("is_prime: values below 2 are not prime") {
    CHECK_FALSE(common::is_prime(-7));
    CHECK_FALSE(common::is_prime(0));
    CHECK_FALSE(common::is_prime(1));
}

TEST_CASE("is_prime: small numbers") {
    CHECK(common::is_prime(2));
    CHECK(common::is_prime(3));
    CHECK_FALSE(common::is_prime(4));
    CHECK(common::is_prime(5));
    CHECK_FALSE(common::is_prime(9));
    CHECK_FALSE(common::is_prime(25));
    CHECK(common::is_prime(97));
}

TEST_CASE("is_prime: large numbers") {
    CHECK(common::is_prime(2'147'483'647));
    CHECK(common::is_prime(1'000'000'007));
    CHECK_FALSE(common::is_prime(1'000'000'007LL * 3));
    CHECK_FALSE(common::is_prime(std::numeric_limits<std::int64_t>::max()));
}
