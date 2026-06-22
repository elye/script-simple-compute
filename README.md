# Compute Script

This repository contains a small Bash script, `compute.sh`, that evaluates
arithmetic expressions.  It supports the four basic operators
(`+`, `-`, `x` for multiplication, and `/` for division) and
parentheses for grouping.  The script is intentionally lightweight so that
it can be used as an example in teaching materials, CI pipelines, or as a
quick utility.

## File layout

```
git-bisect/
├── compute.sh   # The script that evaluates an expression
└── README.md    # This documentation file
```

## Usage

```bash
# Make the script executable (if it isn't already)
chmod +x compute.sh

# Run the script with an expression as a single argument
./compute.sh "(2+3)x4"
# Output: 20
```

The script accepts **exactly one** argument: a string containing the
expression to evaluate.  It prints the result to standard output.  If the
expression is malformed or contains unsupported tokens, the script exits
with a non‑zero status and prints an error message to standard error.

### Supported syntax

* **Numbers** – integers or floating‑point values.
* **Operators** – `+`, `-`, `x` (multiplication), `/` (division).
* **Parentheses** – `(` and `)` for grouping.
* **Whitespace** – ignored between tokens.

### Example

```bash
$ ./compute.sh "(2+3)x4"
20

$ ./compute.sh "10/2+3"
8

$ ./compute.sh "(1+2)(3+4)"
21
```

## Development

The script is written in POSIX‑compatible Bash and contains minimal
dependencies.  It can be run on any Unix‑like system that provides a
`bash` interpreter.

### Extending the script

If you want to add more complex logic (e.g., support for exponentiation
or custom functions), simply edit `compute.sh` and update the test suite
accordingly.

## License

This project is released under the MIT License.  See the `LICENSE` file
for details.

## Contributing

Feel free to open issues or pull requests if you find bugs or want to add
features.  Please keep changes small and well‑documented.
```
