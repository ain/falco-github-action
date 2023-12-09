# falco-github-action

Falco GitHub Action for VCL validation.

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

| Input | Default | Description |
| ----- | ------- | ----------- |
| `subdommand` | `lint` | Run linting on VCL (or ACL) |
| `options` | - | Optional flags, see [Common Flags of Falco](https://github.com/ysugimoto/falco#usage) |
| `target` | - | VCL (or ACL) to targeted, e.g. lint |

## Licence

Copyright © 2023 Ain Tohvri. Licenced under [MIT](LICENSE).
