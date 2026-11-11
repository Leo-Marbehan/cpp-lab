/**
 * // https://codeforces.com/problemset/problem/2284/A1
 *
 * Three points A, B and C are placed at the origin.
 *
 * Repeat n times:
 * 1. Choose a point.
 * 2. Increase or decrease its x or y coordinate by 1.
 *
 * We want to find the maximum doubled area of the triangle formed by points A, B and C after n moves.
 *
 * Using a loop that checks all possible moves, calculates the area of the triangle, and make the move that maximizes
 * the area, we get the following results:
 * - After 2r moves, the maximum area is r^2 by placing the points at (0, 0), (0, r), and (r, 0).
 * - After 2r + 1 moves, the maximum area is r * (r + 1) by placing the points at (0, 0), (0, r + 1), and (r, 0).
 *
 * We choose to implement this approach and submit it, and it passed.
 *
 * Verdict: Accepted
 */

#include <iostream>

int main() {
  int t = 0;

  std::cin >> t;

  for (int test_case = 0; test_case < t; ++test_case) {
    int n = 0;

    std::cin >> n;

    if (n < 2) {
      std::cout << "0\n";
    } else if (n % 2 == 0) {
      std::cout << (n * n) / 4 << '\n';
    } else {
      int r = n / 2;
      std::cout << r * (r + 1) << '\n';
    }
  }

  return 0;
}
