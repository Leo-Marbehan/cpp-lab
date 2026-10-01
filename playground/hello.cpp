#include <format>
#include <iostream>

int main() {
  std::cout << std::format("Hello from cpp-lab (C++ {})\n", __cplusplus);
}
