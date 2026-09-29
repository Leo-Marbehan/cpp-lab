#include <common/math.hpp>

#include <iostream>

int main() {
    for (int n = 0; n < 50; ++n) {
        if (common::is_prime(n)) {
            std::cout << n << ' ';
        }
    }
    std::cout << '\n';
}
