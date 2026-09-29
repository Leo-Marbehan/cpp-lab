#include <common/math.hpp>

namespace common {

bool is_prime(std::int64_t n) {
    if (n < 2) {
        return false;
    }
    if (n % 2 == 0) {
        return n == 2;
    }
    // d <= n / d instead of d * d <= n: d * d overflows for n close to INT64_MAX.
    for (std::int64_t d = 3; d <= n / d; d += 2) {
        if (n % d == 0) {
            return false;
        }
    }
    return true;
}

} // namespace common
