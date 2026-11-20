/**
 * https://codeforces.com/contest/2290/problem/D
 *
 * We are given a string s of length n consisting of lowercase letters.
 *
 * We can perform the following operation any number of times: choose a
 * character c that is not 'a', and replace all occurrences of c in s with'
 * the character that comes before c in the alphabet.
 *
 * Our goal is to determine the minimum number of operations needed to convert
 * the string s into a palindrome.
 *
 * We can already say that the letter at index i is tied to the letter at index
 * n - 1 - i. If they are the same, we don't need to do anything. If they are
 * different, we need to perform the amount of operations equal to the difference
 * between the two letters in the alphabet.
 *
 * The issue is that we should not count the same operation twice. For example, if
 * a h needs to be converted to a c, and a e to a d, e will already be converted
 * to d when we convert h to c.
 *
 * We can think of keeping track of which letter need to be converted to which letter,
 * and merging overlapping operations.
 *
 * Verdict: Accepted
 */

#include <cstdint>
#include <iostream>

int main() {
  constexpr char a = 'a';
  constexpr int alphabet_size = 26;

  int t = 0;

  std::cin >> t;

  for (int test_case = 0; test_case < t; ++test_case) {
    size_t n = 0;
    std::string s;

    std::cin >> n >> s;

    // Keep track of which letters need to be converted to which letters
    // using 25 booleans stored in a 32-bit integer. The i-th bit of the
    // integer represents whether the letter 'a' + i + 1 needs to be converted
    // to the letter 'a' + i.
    int32_t operations = 0;

    for (size_t i = 0; i < n / 2; ++i) {
      char left = s[i];
      char right = s[n - 1 - i];

      char larger = std::max(left, right);
      char smaller = std::min(left, right);

      if (larger != smaller) {
        // Mark all letters between larger and smaller as needing to be converted
        for (char c = larger; c > smaller; --c) {
          operations |= 1 << (c - a - 1);
        }
      }
    }

    int total = 0;

    for (int i = 0; i < alphabet_size - 1; ++i) {
      if ((operations & (1 << i)) != 0) {
        ++total;
      }
    }

    std::cout << total << "\n";
  }

  return 0;
}
