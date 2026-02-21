# Public repo and first release

## What is on GitHub (public)

The repository **does not contain any source code or private data**. It only has:

- **README.md**, **GET_STARTED.md**, **SYSTEM_OVERVIEW.md** — documentation in English
- **install.ps1**, **install.sh** — one-command installers (download from Releases)
- **get-package.ps1**, **get-package.sh** — optional download-only scripts
- **.env.example** — example environment variables (no secrets)
- **docs/** — INSTALL.md, LICENSE_INFO.md, etc.
- **LICENSE**

So: **no `.py` files, no `src/`, no `scripts/` with code.** Users cannot see or access your code. They can only run the install command and get the **binary package** (system + dashboard) from Releases.

---

## How users get the system and dashboard

1. They run the **one command** (Windows or Linux) from the README.
2. The script downloads the latest **Release** asset (`AsianOdds88-Windows.zip` or `AsianOdds88-Linux.tar.gz`) and extracts it.
3. The package contains the **full system** (all modules) and the **dashboard** (dashboard_server). They set license, `.env`, Redis, and run `start.bat` or `./start.sh`. The dashboard is at `http://<their-IP>:8080`.

So: **yes, they can use the system and have the dashboard** — as long as there is at least one **Release** with those assets.

---

## Creating the first release (you do this once)

The install command will fail until there is a Release with the right assets. To create it:

### Option A: GitHub CLI (recommended)

1. Install [GitHub CLI](https://cli.github.com/) and run `gh auth login`.
2. Build the Windows package (from your project root):  
   `.\build\build_windows.ps1`  
   Output: `build\dist\AsianOdds88-Windows.zip`
3. Create the release and attach the zip:  
   `.\build\create_release.ps1 -Tag v1.0.0`  
   (For a draft first: `.\build\create_release.ps1 -Tag v1.0.0 -Draft`)

### Option B: Manual on GitHub

1. Build Windows: `.\build\build_windows.ps1` → `build\dist\AsianOdds88-Windows.zip`
2. On GitHub: **Releases** → **Create a new release** → choose tag (e.g. `v1.0.0`), title, publish.
3. **Attach** `AsianOdds88-Windows.zip` (and, if you have it, `AsianOdds88-Linux.tar.gz` from a Linux build).
4. The asset **names** must be exactly: `AsianOdds88-Windows.zip` and `AsianOdds88-Linux.tar.gz` so the install scripts find them.

After that, anyone running the install command will get the package and can use the system and dashboard.
