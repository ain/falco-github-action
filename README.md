# falco-github-action

GitHub Action for Fastly VCL parsing and validation.

Based on [Falco](https://github.com/ysugimoto/falco).

## Usage

```yaml
- name: Lint VCL
  uses: ain/falco-github-action@latest
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

## Licence

Copyright © 2023 Ain Tohvri. Licenced under [MIT](LICENSE).
