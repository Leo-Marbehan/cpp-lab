/**
 * // https://codeforces.com/problemset/problem/2284/B
 *
 * n planned donations with amounts a_1, a_2, ..., a_n
 *
 * a_i is "very pleasant" if greater than or equal to the sum of all previous donations (a_1 + a_2 + ... + a_{i-1}).
 * The first donation is always very pleasant.
 *
 * We want to know for a given k <= n if it's possible to rearrange the donations to have exactly k very pleasant
 * donations, and to find one such arrangement if possible.
 *
 * We can see that if we sort the donations in ascending order, all donations will be very pleasant. Similarly, if we
 * sort the donations in descending order, only the maximum donations will be very pleasant. We can also see that if we
 * have a very pleasant donation, a donation of the same amount directly after it will also be very pleasant.
 *
 * We can also state that a greater donation directly after a very pleasant donation will also be very pleasant, and a
 * smaller donation directly after a not very pleasant donation will not be very pleasant.
 *
 * We can see that if we have m donations of the maximum amount, we automatically have at least m very pleasant
 * donations. If k < m, we cannot satisfy the requirement of exactly k very pleasant donations.
 *
 * Now if k >= m, we can take the k maximum donations and sort them in ascending order, and then take the remaining
 * donations and sort them in descending order. This will give us exactly k very pleasant donations, and we can output
 * this arrangement.
 */

#include <iostream>
#include <limits>
#include <map>
#include <ranges>

namespace {
void get_donations(int n, std::map<int, int>& donations, int& max_donation, int& max_donation_count) {
  for (int i = 0; i < n; ++i) {
    int donation = 0;
    std::cin >> donation;

    ++donations[donation];

    if (donation > max_donation) {
      max_donation = donation;
      max_donation_count = 1;
    } else if (donation == max_donation) {
      ++max_donation_count;
    }
  }
}

void split_donations(int n, int k, const std::map<int, int>& donations, std::map<int, int>& very_pleasant_donations,
                     std::map<int, int>& not_very_pleasant_donations) {
  int i = 0;
  for (const auto& [donation, count] : donations) {
    if (i >= n - k) {
      very_pleasant_donations[donation] = count;
    } else if (i + count > n - k) {
      int very_pleasant_count = (i + count) - (n - k);
      very_pleasant_donations[donation] = very_pleasant_count;
      not_very_pleasant_donations[donation] = count - very_pleasant_count;
    } else {
      not_very_pleasant_donations[donation] = count;
    }

    i += count;
  }
}
} // namespace

int main() {
  int t = 0;

  std::cin >> t;

  for (int test_case = 0; test_case < t; ++test_case) {
    int n = 0;
    int k = 0;

    std::cin >> n >> k;

    // SortedIntList donations;
    std::map<int, int> donations; // key: donation amount, value: count of that amount
    int max_donation = std::numeric_limits<int>::min();
    int max_donation_count = 0;

    get_donations(n, donations, max_donation, max_donation_count);

    if (k < max_donation_count) {
      std::cout << "NO\n";
      continue;
    }

    std::cout << "YES\n";

    std::map<int, int> very_pleasant_donations;
    std::map<int, int> not_very_pleasant_donations;

    split_donations(n, k, donations, very_pleasant_donations, not_very_pleasant_donations);

    for (const auto& [donation, count] : very_pleasant_donations) {
      for (int j = 0; j < count; ++j) {
        std::cout << donation << ' ';
      }
    }

    for (const auto& [donation, count] : std::views::reverse(not_very_pleasant_donations)) {
      for (int j = 0; j < count; ++j) {
        std::cout << donation << ' ';
      }
    }

    std::cout << '\n';
  }

  return 0;
}
