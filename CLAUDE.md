# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Docker-based GitHub Action that wraps [Falco](https://github.com/ysugimoto/falco), a Fastly VCL parser/linter. There is no application code — the entire action is `action.yml` + `Dockerfile` + `entrypoint.sh`, plus VCL/ACL fixtures used as tests.

## Commands

```bash
./test.sh                      # build the image (if missing) and run the full local suite
docker rmi falco-github-action-test   # force a rebuild; test.sh skips build when the image exists
```

`test.sh` has no filter flag — to run a single case, comment out the other `run_test` calls or invoke the container directly:

```bash
docker run --rm -v "$PWD:/workspace" -w /workspace falco-github-action-test \
  lint "-I test/vcl/includes" test/vcl/valid_with_include.vcl
```

Container args are positional and must match `action.yml`'s order: `<subcommand> <options> <target>`.

## How the pieces connect

`action.yml` passes three inputs as three positional args to `entrypoint.sh`. `options` is expanded **unquoted** when calling `falco`; that word-splitting is load-bearing, letting `options` carry multiple flags in one input string (`"-v -I test/vcl/includes"`) and letting an empty `options` disappear rather than become an empty argument. Quoting it would break both.

`target` is resolved before the call: an existing path is used verbatim (so spaces survive), anything else is expanded unquoted under `globstar`+`nullglob` into an array of matches. Each match is linted in its own `falco` invocation, failures do not stop the loop, and the last non-zero exit code becomes the script's — so a single target still passes falco's own code through unchanged. A pattern matching nothing exits 1 rather than reaching falco raw.

The `Dockerfile` pins both halves of the build — the `golang` base image and the Falco tag installed from source — so every build of the image produces the same linter on the same toolchain. The base image has to stay at or above the Go version Falco's `go.mod` requires (`v1.21.1` needs `go 1.24.3`), which is the thing to check when bumping either pin. Upstream tags `v2.x`, but its `go.mod` still declares the unsuffixed module path `github.com/ysugimoto/falco`, so `go install` cannot resolve v2 at all — `@latest` used to resolve to the newest `v1.x` and a `@v2.x.y` pin fails outright. `v1.21.1` is therefore the newest installable version, and bumping it means checking whether upstream has adopted a `/v2` module path.

## Tests

Two independent suites cover different things:

- **`test.sh`** (local) — runs all fixtures including the negative ones, asserting non-zero exit for the `invalid_*` files.
- **`.github/workflows/test.yml`** (CI) — only positive cases; each step uses `uses: ./`, which rebuilds the image from the Dockerfile. The negative cases are commented out there on purpose: a failing lint fails the job, so they can only be asserted from `test.sh`.

Adding a fixture means adding it to both places if it's a positive case, and to `test.sh` only if it's negative.

The `discover` + `wildcard` job pair in CI is the live proof of the discover-then-fan-out matrix documented in the README (still the only way to lint files as *parallel* jobs), and it doubles as coverage: it globs `test/vcl/valid*.vcl`, so a new fixture matching that name is picked up by CI with no workflow edit. The `vcl` job's own wildcard steps use the same `valid*.vcl` pattern. Naming a *failing* fixture `valid*.vcl` would therefore break CI in three places.

## Releasing

Bumping the pinned Falco version is a release in its own right, since consumers on the floating `v1` tag get the new linter with no change on their side.

`Dockerfile`'s `org.opencontainers.image.version` label is the version of record — bump it alongside a new `vX.Y.Z` tag. The floating `v1` tag is what README tells consumers to use, so it needs to be moved to the new release commit.
