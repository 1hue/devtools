# Containerised TypeScript & Friends

<p align="center">
Run intellisense tools like <code>tsc</code>, <code>eslint</code>, and <code>prettier</code> in a podman container.
</p>
<p align="center">⇓</p>
<p align="center">
IDE is happy.
</p>
<p align="center">⇓</p>
<p align="center">
Your host environment stays clean.
</p>
&nbsp;

---
&nbsp;

```sh
./tools build
./tools link # ~/.local/bin, needs to be in PATH
```
&nbsp;

> [!IMPORTANT]
>
> Each project must have `node_modules` - install via project's own container, with project mounted as `--userns=keep-id`

> [!TIP]
>
> Delete `node_modules` via `podman unshare rm -rf node_modules`


| Command | |
| --- | --- |
| `./tools build` | Build image with newest tools |
| `./tools link` | Symlink in `~/.local/bin` as per [`config`](./config) |
| `./tools link eslint prettier` | Link only these, drop other links |
| `./tools sh` | Shell into container |
| `./tools prettier --check .` | Run prettier |
| `./tools help` | Docs |
| `eslint .` | Via symlink, same as `./tools eslint .` |
| `typescript-language-server --stdio` | Editor LSP command (Neovim, Helix etc.; VS Code uses its own). Paths same as on host |

## Notes

- No network, unless `TOOLS_NET=1`
- Mounts git root (or cwd), read-only unless `--write`/`-w`/`--fix` or `TOOLS_RW=1`, so `tsc --noEmit`.
- Uses own versions, not project's: latest release older than `MIN_RELEASE_AGE` days. No lockfile, rebuild to update.
- Install scripts are off.
- Settings are in `config`. New tools go in `package.json`, then rebuild.