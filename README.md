# falco-github-action

GitHub Action for Fastly VCL parsing and validation.

Based on [Falco](https://github.com/ysugimoto/falco).

## Usage

```yaml
- name: Lint VCL
  uses: ain/falco-github-action@v1
  with:
    subcommand: lint
    options: "-v -I test/vcl/includes"
    target: test/vcl/valid_with_include.vcl
```

## Inputs

| Input | Default | Required | Description |
| ----- | ------- | -------- | ----------- |
| `subcommand` | `lint` | yes | Run linter on VCL (or ACL) |
| `options` | - | no | Optional flags, see [Common Flags of Falco](https://github.com/ysugimoto/falco#usage) |
| `target` | - | yes | VCL (or ACL) file to target, e.g. to lint. Accepts a wildcard, see [Wildcard targets](#wildcard-targets) |

## Wildcard targets

`target` accepts a glob, in which case every matching file is linted:

```yaml
- name: Lint all VCL
  uses: ain/falco-github-action@v1
  with:
    subcommand: lint
    options: "-I path/to/includes"
    target: "path/to/*.vcl"
```

`**` recurses into subdirectories, e.g. `path/to/**/*.vcl`. Quote the value so that YAML passes the pattern through intact.

Matches are linted one after another and a failure does not stop the run, so a single broken file cannot hide the state of the rest. The step fails if any match failed, and the log closes with a `N targets checked, M failed` summary.

Two things worth knowing:

- **Keep include fragments out of the pattern.** Files pulled in via `include "..."` are not standalone VCL, so linting them on their own reports errors. Keep them in a directory the pattern does not reach and point `-I` at it — which is what `path/to/*.vcl` does above, leaving `path/to/includes/` alone.
- **A pattern matching nothing fails the step.** This is deliberate: a mistyped glob should not quietly pass.

## Tips and tricks

### Parallel linting with a matrix

A wildcard `target` lints its matches sequentially in one job. To run linter processes in parallel instead, one can leverage a `matrix`, e.g.:

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        target:
          - path/to/first.vcl
          - path/to/second.vcl
    steps:
      - uses: actions/checkout@v4
      - name: Lint
        uses: ain/falco-github-action@v1
        with:
          subcommand: lint
          target: ${{ matrix.target }}
```

### Parallelising a wildcard

A `matrix` needs its values up front, so to spread a glob across parallel jobs the pattern has to be expanded into a list *before* the matrix runs. Discover the files in one job, publish them as JSON, and fan out in the next:

```yaml
jobs:
  discover:
    runs-on: ubuntu-latest
    outputs:
      targets: ${{ steps.find.outputs.targets }}
    steps:
      - uses: actions/checkout@v4
      - id: find
        run: |
          targets=$(find path/to -name '*.vcl' -not -path '*/includes/*' \
            | jq -R -c . | jq -s -c .)
          echo "targets=$targets" >> "$GITHUB_OUTPUT"
          echo "Discovered: $targets"

  lint:
    needs: discover
    if: needs.discover.outputs.targets != '[]'
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        target: ${{ fromJson(needs.discover.outputs.targets) }}
    steps:
      - uses: actions/checkout@v4
      - name: Lint
        uses: ain/falco-github-action@v1
        with:
          subcommand: lint
          options: "-I path/to/includes"
          target: ${{ matrix.target }}
```

The double `jq` builds the JSON array without needing shell escapes: the first pass turns each path into a JSON string, the second slurps them into an array. An empty result yields `[]`.

Things to watch:

- **Prune your include fragments** from the `find` (above: `-not -path '*/includes/*'`) and point `-I` at their directory instead, for the same reason as with a wildcard `target`.
- **An empty match is a hard error, not a skip.** `fromJson('[]')` produces a matrix with zero combinations, which GitHub reports as a failed job — hence the `if:` guard.

`fail-fast: false` keeps one bad file from cancelling the lint of every other file.

## Testing the action

1. GitHub Actions is configured to run tests using ACL/VCL fixtures in the `test/` folder
2. Local tests can be run using the `./test.sh` script in the project root

## Licence

Copyright © 2023-2026 Ain Tohvri and [contributors](https://github.com/ain/falco-github-action/graphs/contributors). Licenced under [MIT](LICENSE).
