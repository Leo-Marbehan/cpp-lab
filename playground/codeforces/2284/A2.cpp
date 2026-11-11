/**
 * // https://codeforces.com/problemset/problem/2284/A2
 *
 * Three points A, B and C are placed at the origin.
 *
 * An array of n powers of 2 is given.
 *
 * Repeat n times:
 * 1. Choose a point.
 * 2. Increase or decrease its x or y coordinate by the given value.
 *
 * We want to find the maximum doubled area of the triangle formed by points A, B and C at the end.
 *
 * Since the A1 example targets a rectangular isosceles triangle, we tried to use the same approach
 * here, by approaching a rectangular isosceles triangle with the given powers of 2 as much as possible.
 *
 * To do this, we sort the powers of 2 in descending order and then apply them to only two points to move them
 * away from the origin on the x and y axes. Each time we add the next power to the point that is currently closer
 * to the origin.
 */

#include <array>
#include <iostream>

int main() {
  int t = 0;

  std::cin >> t;

  // We're guaranteed that the powers of 2 are between 2^0 and 2^24 inclusive
  constexpr int min_power = 0;
  constexpr int max_power = 24;
  constexpr int span = max_power - min_power + 1;

  for (int test_case = 0; test_case < t; ++test_case) {
    int n = 0;

    std::cin >> n;

    // Fixed size array in reverse order (at index 0, count of powers at max_power)
    std::array<int, span> powers{};

    for (int i = 0; i < n; ++i) {
      size_t power = 0;
      std::cin >> power;

      if (power < min_power || power > max_power) {
        std::cerr << "Power is out of the expected range: " << power << " (expected: " << min_power << " to "
                  << max_power << ")\n";
        throw std::out_of_range("Power is out of the expected range");
      }

      ++powers[max_power - power]; // NOLINT(cppcoreguidelines-pro-bounds-constant-array-index)
    }

    long long int a_x = 0;
    long long int b_y = 0;

    int current_increment = 1 << max_power; // Start with the largest power of 2

    for (const int count : powers) {
      for (int i = 0; i < count; ++i) {
        if (a_x < b_y) {
          a_x += current_increment;
        } else {
          b_y += current_increment;
        }
      }
      current_increment >>= 1; // Move to the next smaller power of 2
    }

    std::cout << a_x * b_y << '\n';
  }

  return 0;
}
