/**
 * https://codeforces.com/contest/2290/problem/C
 *
 * We are given n books of height h[i]. We want to arrange them on a shelf in such a way
 * that maximizes the number of books that are visible from at least one side.
 *
 * We can see that if 2 or more books are of the same height, then at most two of them
 * can be visible from the sides : the leftmost and the rightmost book of that height.
 * All intermediate books of the same height will be hidden by the leftmost and rightmost
 * books.
 *
 * This way, by arranging the books in ascending order first, without any duplicates, and
 * then adding the duplicates in descending order, we can maximize the number of visible books.
 *
 * Verdict: Accepted
 */

#include <iostream>
#include <map>
#include <ranges>

int main() {
  int t = 0;

  std::cin >> t;

  for (int test_case = 0; test_case < t; ++test_case) {
    int n = 0;
    std::map<int, int> book_heights;

    std::cin >> n;

    for (int i = 0; i < n; ++i) {
      int h = 0;
      std::cin >> h;

      ++book_heights[h];
    }

    int visible_books = 0;

    for (const auto& [height, count] : book_heights) {
      if (count == 1) {
        ++visible_books;
      } else {
        visible_books += 2;
      }
    }

    std::cout << visible_books << "\n";

    for (const auto& [height, count] : book_heights) {
      std::cout << height << " ";
    }

    for (const auto& [height, count] : std::views::reverse(book_heights)) {
      for (int i = 1; i < count; ++i) {
        std::cout << height << " ";
      }
    }

    std::cout << "\n";
  }

  return 0;
}
