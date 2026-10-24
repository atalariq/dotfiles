# cpp

Core packages: `gcc`, `gdb`.

Run `nix develop`, or review `.envrc` and run `direnv allow` once. Entering the directory then loads the cached environment; leaving restores the previous environment.

Project dependencies and build commands remain explicit.

Update `flake.lock` deliberately. Without Nix, install the same package versions listed in [VERSIONS.md](VERSIONS.md).

Compile one competitive-programming solution with:

```sh
g++ -std=c++20 -O2 -pipe -Wall -Wextra main.cpp -o main
./main < input.txt
```

For local debugging, replace `-O2` with `-g -O0 -fsanitize=address,undefined`
and use GDB. No CMake, framework or project generator is required.
