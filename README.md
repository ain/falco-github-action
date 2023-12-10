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
| `target` | - | yes | VCL (or ACL) file to target, e.g. to lint |

## Tips and tricks

To run linter processes in parallel across multiple files, one can leverage a `matrix`, e.g.:

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

## Licence

Copyright © 2023 Ain Tohvri. Licenced under [MIT](LICENSE).
