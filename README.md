# Containerised TypeScript & Friends

An alternative to Dev Containers. Keep your host environment clean.

```sh
make build
make link # ~/.local/bin, needs to be in PATH
```
&nbsp;

> [!IMPORTANT]
>
> `tsc` and `eslint` need project's `node_modules` - install via project's own container, with project mounted as `--userns=keep-id`

> [!TIP]
>
> Delete `node_modules` installed without keep-id via `podman unshare rm -rf node_modules`

&nbsp;

| Command | |
| --- | --- |
| `make build` | Build all images with newest tools |
| `make build-ruff` | Build one image |
| `make link` | Symlink every image's tools in `~/.local/bin` |
| `make link LINKS="eslint prettier"` | Link only these, drop other links |
| `make unlink` | Remove all links |
| `make sh IMAGE=node` | Shell into container |
| `scripts/run.sh prettier --check .` | Run prettier |
| `scripts/run.sh --list` | List tools |
| `scripts/run.sh --help` | Docs |
| `eslint .` | Via symlink, same as `scripts/run.sh eslint .` |
| `node script.js` | Node from image |
| `TOOLS_RW=1 ruff format .` | Format Python in place |
| `ruff format --stdin-filename ${file} -` | Editor formatter command, formats stdin to stdout |
| `tsc --lsp --stdio` | Editor LSP command (Neovim, Helix etc.). Paths same as on host |

&nbsp;

## Notes

- Mounts git root of cwd
- `WRITE_ARGS` from image's `config` (`--write`, `--fix` etc.) or `TOOLS_RW=1` to write files
- `TOOLS_NET=1` to enable network
- `make build` to update tools. Eslint comes from project if installed.
- One folder per image in `image/`, with a `Containerfile` and a `config` listing its `TOOLS`
- Add Node tools to `image/node/package.json` and `TOOLS` in `image/node/config`
