# License — AsianOdds88 Trading System

**AsianOdds88 Trading System** requires a valid license to run. When you start the system (locally or on a server), the license is checked; if it is missing or invalid, a message is shown with a link to get one.

## How to use your license

1. **Environment variable (recommended on a server):**
   ```bash
   export KETER_LICENSE_KEY="<your-jwt-token>"
   ```

2. **Local file (recommended for development):**
   - Create the file `local/.keter_license` in the project root (the directory where you extracted the package).
   - Put the JWT token on a single line (as provided by Rovidev).

The token is a signed JWT (RS256). Do not share it or commit it to public repositories.

## Where to get a license

If you don't have a license yet, when you try to run the system you will see the link to get one. You can also go directly to the product page: **[Get license and download](https://rovidev.com/asianodds88/)**.

The URL shown by the system is configurable via the `LICENSE_OBTAIN_URL` environment variable; if not set, the default product URL is used.

## Using the system

Once the license is set, follow the installation and run steps in [INSTALL.md](INSTALL.md) and the instructions included in your package.
