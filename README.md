# Containerised TypeScript & Friends

**An alternative to Dev Containers and DevPod.**

---

&nbsp;

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
> Delete any `node_modules` via `podman unshare rm -rf node_modules`

&nbsp;

| Command | |
| --- | --- |
| `./tools build` | Build image with newest tools |
| `./tools link` | Symlink in `~/.local/bin` as per [`config`](./config) |
| `./tools link eslint prettier` | Link only these, drop other links |
| `./tools unlink` | Remove all links |
| `./tools sh` | Shell into container |
| `./tools prettier --check .` | Run prettier |
| `./tools help` | Docs |
| `eslint .` | Via symlink, same as `./tools eslint .` |
| `node script.js` | Node from image |
| `tsc --lsp --stdio` | Editor LSP command (Neovim, Helix etc.). Paths same as on host |

&nbsp;

## Notes

- No network, unless `TOOLS_NET=1`
- Mounts git root (or cwd), read-only unless `--write`/`-w`/`--fix` or `TOOLS_RW=1`, so `tsc --noEmit`. Refuses `/` and `~`.
  - Incremental projects (e.g. Next.js): add `--incremental false`, otherwise tsc fails writing `tsconfig.tsbuildinfo`.
- TypeScript 7: no `tsserver.js`, so no typescript-language-server. Editors use `tsc --lsp`.
- VS Code/VSCodium: built-in TypeScript and ESLint/Prettier extensions run on host, not here. Use tasks (`$tsc-watch`, `$eslint-stylish`) to run via container.
- Uses own versions, not project's: latest release older than `MIN_RELEASE_AGE` days. No lockfile, rebuild to update.
  - Except `PROJECT_TOOLS` (eslint): project's copy if installed, since plugins are tied to eslint version. Still runs in container.
- Install scripts are off.
- Settings are in `config`. New tools go in `package.json`, then rebuild.