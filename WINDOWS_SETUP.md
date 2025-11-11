# Portfolio Tracker - Windows Development Setup

## Prerequisites

- Ruby 3.1.1 (installed at `C:\Ruby\Ruby31-x64`)
- rbenv for Windows (installed at `C:\Ruby\rbenv`) - for managing Ruby 3.3+ versions
- MSYS2 with UCRT development toolchain
- PostgreSQL database
- Node.js (for Tailwind CSS)

## Ruby Version Management

### Current Setup

This project uses **Ruby 3.1.1** which is installed directly at `C:\Ruby\Ruby31-x64`.

For projects requiring Ruby 3.3+, **rbenv** is installed and configured to manage those versions.

### PowerShell Profile Configuration

Your PowerShell profile (`$PROFILE`) is configured with:

```powershell
# rbenv for Windows - manages Ruby 3.3+ versions
$env:RBENV_ROOT = 'C:\Ruby\rbenv'
$env:PATH = 'C:\Ruby\rbenv\bin;C:\Ruby\rbenv\shims;' + $env:PATH

# Ruby 3.1.1 (fallback for projects that need it)
$env:PATH = 'C:\Ruby\Ruby31-x64\bin;' + $env:PATH

# MSYS2 UCRT bin for libcurl and other native dependencies
$env:PATH += ';C:\Ruby\Ruby31-x64\msys64\ucrt64\bin'

# SSL Certificate for Ruby HTTPS connections
$env:SSL_CERT_FILE = 'C:\Ruby\Ruby31-x64\msys64\ucrt64\etc\pki\ca-trust\extracted\pem\tls-ca-bundle.pem'
```

### Using rbenv for Other Projects

**List available Ruby versions:**
```powershell
rbenv install -l
```

**Install a Ruby version (e.g., 3.3.10):**
```powershell
rbenv install 3.3.10-1
```

**Set global Ruby version (all new terminals):**
```powershell
rbenv global 3.3.10-1
```

**Set project-specific Ruby version (recommended):**
```powershell
cd path\to\your-project
rbenv local 3.3.10-1
```

**Check current Ruby version:**
```powershell
ruby --version
rbenv version
```

**Switch back to Ruby 3.1.1:**
```powershell
rbenv global system
```

**List installed Ruby versions:**
```powershell
rbenv versions
```

## Environment Setup

The environment includes:
- Ruby 3.1.1 bin directory in PATH
- rbenv bin and shims directories in PATH
- MSYS2 UCRT bin directory in PATH (for libcurl and native gems)
- SSL_CERT_FILE pointing to MSYS2 CA certificates bundle

## Starting Development Servers

To start both Rails server and Tailwind CSS watcher together:

```powershell
.\bin\dev.ps1
```

This will start:
- Rails server on `http://localhost:3000`
- Tailwind CSS watcher (auto-rebuilds on file changes)

## Stopping Servers

Press `Ctrl+C` in the terminal running `dev.ps1`

## Individual Server Commands

If you need to run servers separately:

**Rails server only:**
```powershell
rails server
```

**Tailwind watcher only:**
```powershell
rails tailwindcss:watch
```

## Common Issues

### libcurl Error
If you see `Could not open library 'libcurl'`:
- Ensure `C:\Ruby\Ruby31-x64\msys64\ucrt64\bin` is in your PATH
- Verify `libcurl.dll` exists in that directory
- Restart PowerShell to reload profile

### SSL Certificate Verification Failed
If you see SSL errors when connecting to external services (Google OAuth, APIs):
- Ensure `SSL_CERT_FILE` environment variable is set
- Verify it points to: `C:\Ruby\Ruby31-x64\msys64\ucrt64\etc\pki\ca-trust\extracted\pem\tls-ca-bundle.pem`
- Restart PowerShell to reload profile

### Sprockets Cache Permission Error
If you encounter Sprockets file rename errors:
- The development config has been updated to disable file caching
- Clear cache manually: `Remove-Item -Recurse tmp\cache\assets`

### rbenv Not Recognizing Ruby Versions
If `rbenv versions` shows "No Ruby installed":
- Only Ruby 3.3+ versions are available via rbenv pre-compiled binaries
- Ruby 3.1.1 is installed directly and works as fallback when no rbenv version is set
- Use `rbenv install -l` to see available versions for rbenv

## Troubleshooting rbenv

**rbenv command not found:**
```powershell
# Reload your PowerShell profile
. $PROFILE
```

**Check rbenv configuration:**
```powershell
$env:RBENV_ROOT
rbenv --version
```

## Database Setup

```powershell
rails db:create
rails db:migrate
rails db:seed
```

## Running Tests

```powershell
bundle exec rspec
```

## Environment Variables

Create a `.env` file in the project root with:
```
FINNHUB_API_KEY=your_api_key_here
```

---

Last updated: November 11, 2025
