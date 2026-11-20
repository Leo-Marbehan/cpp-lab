/**
 * https://codeforces.com/contest/2290/problem/B
 *
 * A pen can write in two colors red (R) or blue (B). Each time it writes a letter,
 * it changes color. We also may choose to switch the color manually.
 *
 * Our goal is, given a string s of `B` and `R` letters, to determine the minimum
 * number of times we need to switch the color manually in order to write the string s.
 *
 * The pen writes in red initially.
 *
 * Verdict: Accepted
 */

#include <iostream>

int main() {
  int t = 0;

  std::cin >> t;

  for (int test_case = 0; test_case < t; ++test_case) {
    int n = 0;
    std::string s;

    std::cin >> n >> s;

    int switches = 0;
    bool is_red = true;

    for (char letter : s) {
      bool is_next_letter_red = (letter == 'R');

      if (is_red != is_next_letter_red) {
        // If we switch manually, writing the letter switches again
        // so we don't need to update the is_red variable
        ++switches;
      } else {
        // However, if we don't switch manually, writing the letter switches the color
        is_red = !is_red;
      }
    }

    std::cout << switches << "\n";
  }

  return 0;
}
