/**
 * https://codeforces.com/contest/2290/problem/A
 *
 * Three piles of stones A, B, and C that contain a, b, and c stones respectively.
 *
 * We must make exactly one move. A move consists of taking one stone from one of
 * the piles and putting it into another pile.
 *
 * Our goal is to make the number of stones in all three piles equal.
 *
 * Verdict: Accepted
 */

#include <iostream>

int main() {
  int t = 0;

  std::cin >> t;

  for (int test_case = 0; test_case < t; ++test_case) {
    int a = 0;
    int b = 0;
    int c = 0;

    // We are guaranteed that a <= b <= c

    std::cin >> a >> b >> c;

    if (c == b + 1 && b == a + 1) {
      std::cout << "YES\n";
    } else {
      std::cout << "NO\n";
    }
  }

  return 0;
}
