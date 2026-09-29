#include <common/math.hpp>

#include <iostream>

int main() {
    std::cout << "Hello from projects/hello. Is 97 prime? " << std::boolalpha
              << common::is_prime(97) << '\n';
}
