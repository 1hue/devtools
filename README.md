# Containerised TypeScript & Friends

An alternative to Dev Containers. Keep your host environment clean.

```sh
make build
make link # ~/.local/bin, needs to be in PATH
```
&nbsp;

> [!IMPORTANT]
>
> Each project must have `node_modules` - install via project's own container, with project mounted as `--userns=keep-id`

> [!TIP]
>
> Delete any `node_modules` via `podman unshare rm -rf node_modules`

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

- Mounts only git root of cwd. Read-only unless `--write`/`-w`/`--fix` or `TOOLS_RW=1`.
- No network unless `TOOLS_NET=1`.
- Tools come from image, not project. Rebuild to update. Except eslint, which uses project's copy.
- VS Code extensions run on host. Use tasks to run via container.
- New tools go in `image/package.json`.
