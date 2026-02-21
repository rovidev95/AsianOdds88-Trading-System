# Get started with AsianOdds88 Trading System

**The #1 system to win automatically.** For professionals and individuals: real-time execution, mathematical edge, and risk control. You only need your license and your configuration.

---

## Three steps

### 1. Get your license

The system **does not run without a license**. When you try to run it without one, you will see the link to get it. Or go directly here:

**[→ Get license and download AsianOdds88 Trading System](https://rovidev.com/asianodds88/)**

There you will receive your license and the download link for the ready-to-run package.

### 2. Install (one command)

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/rovidev95/AsianOdds88-Trading-System/main/install.ps1 | iex
```

**Linux / macOS:**
```bash
curl -sSL https://raw.githubusercontent.com/rovidev95/AsianOdds88-Trading-System/main/install.sh | bash
```

This downloads and extracts the latest package—**no source code**, no cloning. Alternatively, use the link from the license process or the [Releases](https://github.com/rovidev95/AsianOdds88-Trading-System/releases) page (`AsianOdds88-Windows.zip` or `AsianOdds88-Linux.tar.gz`).
- Set your **license** in `KETER_LICENSE_KEY` or in the file `local/.keter_license` (one line with the token).

### 3. Configure and run

- Copy the example configuration files (e.g. `.env.example` → `.env`) and fill in:
  - Your AsianOdds88 account credentials.
  - Redis connection (if not localhost:6379).
  - Stake, mode (DRY/LIVE), and other options as described in the package documentation.
- Start the system using the instructions included (local script or server deploy).
- Open the **dashboard** at `http://<your-IP>:8080` to see balance, PnL, and alerts.

---

## Why try it?

- **Serious automation:** Real-time ingest, liquidity and slippage validation, edge vs sharp bookies, execution with limits and dashboard.
- **Same level for everyone:** Whether you are a professional or want to automate without spending hours on code.
- **Control:** Daily loss limit, losing streak protection, configurable stake, live panel.

**Ready?** → **[Get license and download →](https://rovidev.com/asianodds88/)**

---

Support: **rovidev95@gmail.com** · Rovidev · 2026
