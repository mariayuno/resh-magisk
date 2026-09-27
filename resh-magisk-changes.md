<!--
LLM CONTEXT BLOCK — read this first, then skip to "Changes Log"
================================================================
REPO:       https://github.com/mariayuno/resh-magisk
WHAT:       Magisk/KSU module that installs a self-contained zsh environment
            (resh) on Android without Termux. Bins+libs bundled via CI from
            Termux .deb packages. OMZ + p10k + plugins included.
STATE:      commit 44c4a52 on main is the current tip. CI green. Latest release: rexshell.zip
AUTH:       PAT in repo secrets; remote set to PAT URL for push
INSTALL:    curl -Lo /tmp/rexshell.zip \
              https://github.com/mariayuno/resh-magisk/releases/latest/download/rexshell.zip \
              && /data/adb/ksud module install /tmp/rexshell.zip
KEY FILES:
  customize.sh              — flash-time installer (SKIPUNZIP=1, manual unzip of ALL targets)
  files/bin/resh            — shell wrapper (sets PATH/FPATH/LD_LIBRARY_PATH, execs bundled zsh)
  files/bin/{zsh,git,fzf,eza,bat,rg,ssh}  — bundled binaries (built by CI)
  files/lib/                — bundled .so deps
  files/share/zsh/functions/— zsh autoload functions (compinit etc) bundled from Termux zsh .deb
  files/oh-my-zsh/          — OMZ + powerlevel10k + plugins (cloned by CI)
  files/config/zsh/         — .zshrc .zshenv .p10k.zsh
  system/bin/resh           — Magisk overlay stub → exec files/bin/resh
  service.sh                — boot-time symlink repair
  uninstall.sh              — cleans /data/adb/ksu/bin/resh + /data/adb/ssh/root/.profile on remove
  .github/workflows/build.yml — CI: BFS dep resolver, bundles bins+libs+zsh-functions, releases
KNOWN GOOD STATE:
  - CI passes. /releases/latest resolves to rexshell.zip (fixed: dropped prerelease:true).
  - customize.sh extracts module.prop+service.sh+system/+files/ (fixed: SKIPUNZIP=1 was incomplete).
  - zsh fpath set to bundled share/zsh/functions/ (fixed: autoloads were all missing).
  - set -euo pipefail safe: xargs replaced with find+while, grep-q guards have || true.
  - uninstall.sh cleans dangling files outside $MODPATH.
  - Module is systemless (tmpfs overlay). Only /data/adb/ksu/bin/resh symlink + .profile written
    outside module dir (both cleaned by uninstall.sh).
TO RESUME: clone repo, set remote with PAT, edit, push. CI auto-releases on every push to main.
  git clone https://github.com/mariayuno/resh-magisk/
  git remote set-url origin https://<PAT>@github.com/mariayuno/resh-magisk.git
================================================================
-->

# resh-magisk — Changes Log

## 1. Fixed broken `update-binary` (root cause of unflashable zips)

**File:** `META-INF/com/google/android/update-binary`

The original was a hand-rolled installer with three fatal bugs:
- `$ZIPFILE` was never set from `$3` (the zip path arg), so `unzip` had no target
- `module.prop` was never copied into the module dir — Magisk never registered the module
- `service.sh` was never extracted, so boot-time symlink repair never ran

**Fix:** Replaced with the standard Magisk installer stub that sources
`/data/adb/magisk/util_functions.sh` and calls `install_module`, which handles
extraction, `module.prop`, permissions, SELinux contexts, and sources `customize.sh`.

---

## 2. Added `system/bin/resh` Magisk overlay

**File:** `system/bin/resh` *(new)*

```sh
#!/system/bin/sh
exec /data/adb/modules/rexshell/files/bin/resh "$@"
```

Magisk overlays this at boot so `resh` is in PATH on any root shell automatically.
KSU users get it immediately via the symlink in `customize.sh`.

---

## 3. Termux-free operation — bundled shared libraries

**File:** `files/bin/resh`

Added `LD_LIBRARY_PATH="$MOD/lib:/system/lib64:/vendor/lib64"` before `exec zsh`
so bundled `.so` files are found at runtime without Termux installed.

**File:** `.github/workflows/build.yml`

The build workflow now:
1. Downloads all requested Termux `.deb` packages + resolves their full transitive
   dependency tree via BFS over the Termux `Packages` index
2. Extracts every `.so` from all resolved packages into `files/lib/`
3. Skips Android Bionic libs already present on-device (`libc.so`, `libm.so`, etc.)

---

## 4. BFS dependency resolver — add any package in one line

**File:** `.github/workflows/build.yml`

To add a new tool, add its Termux package name to the `PKGS` list at the top of
the fetch step. All transitive library deps are pulled and bundled automatically.

```sh
PKGS="zsh eza bat fzf ripgrep git openssh"   # ← just add here

BIN_OVERRIDES="ripgrep=rg openssh=ssh"        # ← if binary name ≠ package name
```

`git` and `openssh` are included and fully self-contained (their `libssl`,
`libcurl`, `libpcre2`, etc. are all bundled in `files/lib/`).

---

## 5. Fixed GitHub Actions double-zip artifact issue

**Problem:** GitHub Actions `upload-artifact` always wraps downloads in an outer zip.
Flashing that outer zip gives `Error: specified file not found in archive` because
`module.prop` is one level too deep.

**Fix:** Flash from the **Release asset**, not the Artifacts tab.
The release asset is the raw module zip with `module.prop` at the root.

---

## 6. CI — publish prerelease on every push

**File:** `.github/workflows/build.yml`

- Every push to `main` triggers a build and publishes a GitHub prerelease
- Tag format: `build-YYYYMMDD-HHMM-<sha7>` (unique per push)
- `make_latest: true` so the one-liner always pulls the freshest build
- Release only fires if the Package step succeeds (no more empty releases)
- `set -euo pipefail` in the fetch step with per-package `|| true` so one
  missing package doesn't abort the whole build

---

## 7. Fixed release asset name

**File:** `.github/workflows/build.yml`

Old builds uploaded `rexshell-YYYYMMDD.zip` (date-stamped).
New builds upload `rexshell.zip` (fixed name), enabling a stable one-liner:

```sh
curl -Lo /tmp/rexshell.zip \
  https://github.com/mariayuno/resh-magisk/releases/latest/download/rexshell.zip \
  && /data/adb/ksud module install /tmp/rexshell.zip
```

---

## 8. Fixed `module.prop` not landing in `$MODPATH` (KSU flash error)

**File:** `customize.sh`  
**Commit:** `7baa405`

**Problem:** `customize.sh` sets `SKIPUNZIP=1`, which tells KSU/Magisk "I will extract
everything from the zip myself." But the unzip command only extracted `files/*`.
`module.prop`, `service.sh`, and `system/` were never written to `$MODPATH`.
KSU then tried to copy `module.prop` from a path where it didn't exist:

```
cp: can't stat '/data/adb/modules_update/rexshell/module.prop': No such file or directory
Error: No such file or directory (os error 2)
```

**Fix:**
```sh
# before
unzip -o "$ZIPFILE" 'files/*' -d "$MOD"
# after
unzip -o "$ZIPFILE" 'files/*' 'system/*' 'service.sh' 'module.prop' -d "$MOD"
```

---

## 9. Fixed zsh stdlib functions missing at runtime (compinit, add-zsh-hook, etc.)

**Files:** `.github/workflows/build.yml`, `files/bin/resh`  
**Commit:** `7baa405`

**Problem:** After reboot, every zsh autoload function failed:

```
compinit: function definition file not found
add-zsh-hook: function definition file not found
is-at-least: function definition file not found
colors: function definition file not found
compdef: command not found
vcs_info: function definition file not found
```

This broke OMZ, powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, and z.

**Root cause:** The bundled `zsh` binary is from Termux and was compiled with
`--prefix=/data/data/com.termux/files/usr`. Its default `fpath` points to that
prefix — a path that doesn't exist on a real Android device. The CI workflow only
bundled `.so` files from the `.deb` packages; it never extracted the zsh *function
files* (`compinit`, `add-zsh-hook`, `is-at-least`, etc.) that live in
`share/zsh/<ver>/functions/` inside the zsh `.deb`. Without those files, every
`autoload` call silently fails.

**Fix — `build.yml`:** Extract the functions directory from the `zsh` `.deb` into
`files/share/zsh/functions/` during CI:

```sh
ZSH_SHARE=$(find "$TMP/pkgs/zsh" -type d -name "functions" | head -1)
mkdir -p files/share/zsh
cp -r "$ZSH_SHARE" files/share/zsh/functions
```

**Fix — `files/bin/resh`:** Export `FPATH` pointing at the bundled functions
*before* exec-ing zsh, so they're available before any `.zshrc` runs:

```sh
export FPATH="$MOD/share/zsh/functions${FPATH:+:$FPATH}"
```

---

## Commit history

| Commit | Summary |
|--------|---------|
| `dc7d304` | fix: replace broken update-binary with standard Magisk installer stub |
| `4062388` | feat: Termux-free lib bundling, system/bin/resh overlay, drop git/ssh |
| `9af52e7` | feat: BFS dep resolver — git+ssh back, add any package in 1 line |
| `2ae97e0` | docs: warn about artifact double-zip; add release body with install instructions |
| `f00e3d5` | ci: publish prerelease on every push with unique SHA tag |
| `ee378c5` | ci: fixed zip name, release always fires, drop set -e from fetch |
| `b43d5a8` | ci: rewrite workflow — release only on success, set -euo pipefail, fixed asset name |
| `7baa405` | fix: extract module.prop in customize.sh; bundle zsh functions; set FPATH |

---

## Session transcript — 2026-09-27

### User

> From now on append it in the md, infact append everything, all our chat there, without processing
>
> also add how to setup the env, at the top of md so I can upload to any llm and it gets the env running and chat from where we dropped it, make it zero token costly
>
> also give me the curl command, and is it systemless, or leaves dangling files all over the place?

### Claude

**Curl command (stable, always latest build):**

```sh
curl -Lo /tmp/rexshell.zip \
  https://github.com/mariayuno/resh-magisk/releases/latest/download/rexshell.zip \
  && /data/adb/ksud module install /tmp/rexshell.zip
```

**Is it systemless?**

Yes, mostly — but with two small caveats:

The module itself is fully systemless. Magisk/KSU mounts `system/bin/resh` over
`/system/bin/resh` at boot using a tmpfs overlay. The real `/system` partition is
never touched. All module files live under `/data/adb/modules/rexshell/`.

The two files `customize.sh` writes outside the module dir:

| Path | What | Dangling after uninstall? |
|------|------|--------------------------|
| `/data/adb/ksu/bin/resh` | symlink → `files/bin/resh` | Yes — broken symlink left behind |
| `/data/adb/ssh/root/.profile` | SSH auto-launch hook | Yes — file left behind |

Neither is harmful (broken symlink is inert; `.profile` just tries to exec a path
that no longer exists and exits). But they are not cleaned up by Magisk/KSU
`module remove`. To clean manually after uninstall:

```sh
rm -f /data/adb/ksu/bin/resh /data/adb/ssh/root/.profile
```

To make uninstall fully clean, add an `uninstall.sh` to the module:

```sh
# uninstall.sh — Magisk/KSU runs this on module removal
rm -f /data/adb/ksu/bin/resh
rm -f /data/adb/ssh/root/.profile
```

---

## 10. Fixed CI aborting under `set -euo pipefail` (all builds failing since b43d5a8)

**File:** `.github/workflows/build.yml`
**Commit:** `1126cf1`

**Problem:** Every push since `b43d5a8` failed at "Fetch Termux packages + bundle libs". Three patterns all kill the script under `set -euo pipefail`:

1. `xargs -I{} sh -c 'file {} | grep -q ELF && echo {}' | head -1` — `xargs` exits 123 whenever any sub-process returns non-zero. `grep -q ELF` returns 1 for every non-ELF file (scripts, symlinks, data files). With `set -o pipefail`, the pipeline exit code is 123, and `found=$(...)` aborts.

2. `echo ... | grep -q " $pkg " && continue` — when grep returns 1 (not in set), the `&&` expression exits 1; `set -e` aborts.

3. Same pattern in `.so` bundling loop.

**Fix:**
```sh
# before (aborts when any file fails the ELF check)
found=$(find ... | xargs -I{} sh -c 'file {} | grep -q ELF && echo {}' | head -1)

# after (find+while, grep failure explicitly swallowed)
found=""
while IFS= read -r f; do
  file "$f" | grep -q ELF && found="$f" && break || true
done < <(find "$TMP/pkgs/$pkg" -name "$bin" -type f)
```

All `grep -q ... && continue` patterns also got `|| true` appended.

---

## 11. Fixed `/releases/latest` returning stale release

**File:** `.github/workflows/build.yml`
**Commit:** `44c4a52`

**Problem:** The workflow set `prerelease: true`. GitHub's `/releases/latest` API endpoint **excludes prereleases entirely** — it only returns the most recent non-prerelease, non-draft release. So even though every build published a new release with `rexshell.zip`, the stable one-liner URL always resolved to the old `build-20260927` release from before the rename.

**Fix:** Remove `prerelease: true`. Every build now publishes as a regular release and `/releases/latest` always points at the freshest build.

---

## Commit history (updated)

| Commit | Summary |
|--------|---------|
| `dc7d304` | fix: replace broken update-binary with standard Magisk installer stub |
| `4062388` | feat: Termux-free lib bundling, system/bin/resh overlay, drop git/ssh |
| `9af52e7` | feat: BFS dep resolver — git+ssh back, add any package in 1 line |
| `2ae97e0` | docs: warn about artifact double-zip; add release body with install instructions |
| `f00e3d5` | ci: publish prerelease on every push with unique SHA tag |
| `ee378c5` | ci: fixed zip name, release always fires, drop set -e from fetch |
| `b43d5a8` | ci: rewrite workflow — release only on success, set -euo pipefail, fixed asset name |
| `7baa405` | fix: extract module.prop in customize.sh; bundle zsh functions; set FPATH |
| `8647af4` | docs: add LLM context block + full session log to md; add uninstall.sh |
| `1126cf1` | fix: CI fetch step aborting under set -euo pipefail |
| `44c4a52` | fix: drop prerelease:true so /releases/latest resolves correctly |

---

## Session transcript — 2026-09-27 (continued)

### User

> okay, I see no new release in github though and the release is likely not called rexshell.zip, it may be easier though

### Claude

Checked GitHub Actions API. All three runs since `b43d5a8` failed at "Fetch Termux packages + bundle libs". Azure blob (CI log storage) blocked, but the failure pattern was clear from the step name + timing. Root cause: `set -euo pipefail` introduced in `b43d5a8` + `xargs|grep -q ELF` exits 123 on non-ELF files → pipefail propagates → `found=$(...)` aborts. Fixed with `find+while` loop (commit `1126cf1`). Build passed.

Then found the release was there (`build-20260927-0606-1126cf1`, asset `rexshell.zip`) but `/releases/latest` was returning the old `build-20260927` release — because `prerelease: true` excludes releases from that endpoint. Dropped `prerelease: true` (commit `44c4a52`). Build passed, `/releases/latest` now resolves correctly.

**Working install one-liner:**
```sh
curl -Lo /tmp/rexshell.zip \
  https://github.com/mariayuno/resh-magisk/releases/latest/download/rexshell.zip \
  && /data/adb/ksud module install /tmp/rexshell.zip
```

---

## Session transcript — 2026-09-27 (continued)

### User

> output that chatlog.md I told you to make after each output

### Claude

Updated context block to reflect current tip (`44c4a52`), appended full session exchanges above, committed and pushed.

