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
| `make build` | Build image with newest tools |
| `make link` | Symlink in `~/.local/bin` as per `LINKS` in [`Makefile`](./Makefile) |
| `make link LINKS="eslint prettier"` | Link only these, drop other links |
| `make unlink` | Remove all links |
| `make sh` | Shell into container |
| `scripts/run.sh prettier --check .` | Run prettier |
| `scripts/run.sh --help` | Docs |
| `eslint .` | Via symlink, same as `scripts/run.sh eslint .` |
| `node script.js` | Node from image |
| `tsc --lsp --stdio` | Editor LSP command (Neovim, Helix etc.). Paths same as on host |

&nbsp;

## Notes

- Mounts git root of cwd
- `--write`/`-w`/`--fix` or `TOOLS_RW=1` to write files
- `TOOLS_NET=1` to enable network
- `make build` to update tools. Eslint comes from project if installed.
- Add tools to `image/package.json`
