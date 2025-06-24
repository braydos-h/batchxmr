# Batch-XMR

This repository contains a Windows batch script that automates downloading and running the [XMRig](https://github.com/xmrig/xmrig) miner. The script was written to quickly set up mining on systems where administrative privileges are unavailable.

## Features

- Downloads the specified XMRig release using PowerShell or `certutil` as a fallback.
- Validates the download with a SHA256 checksum.
- Logs activity to `%LOCALAPPDATA%\xmrig\xmrig_setup.log`.
- Allows the wallet, pool and XMRig version to be supplied as command‑line arguments.
- Retries downloads and extraction if they fail.
- Cleans up the temporary ZIP file after extraction.

## Usage

1. Copy `loudminer.bat` to the Windows machine.
2. From a command prompt, run:
   ```
   loudminer.bat [WALLET] [POOL] [VERSION]
   ```
   - `WALLET` – your Monero wallet address.
   - `POOL` – mining pool in the form `host:port`.
   - `VERSION` – XMRig release version (default: `6.22.2`).
3. The miner will be extracted to `%LOCALAPPDATA%\xmrig` and started in the background.

> **Note**: Only run the miner on systems where you have permission to do so.

## Files

- `loudminer.bat` – batch script that handles download, verification and execution of XMRig.
- `README.md` – documentation for this repository.

## Disclaimer

This project is provided for educational purposes. Use it at your own risk and ensure it complies with local laws and the policies of the system on which it is executed.
