===========================================================================
XMRig Monero Miner Setup Script (Admin-Free) 
===========================================================================

ABOUT
-----
This batch script automates the setup and execution of the XMRig Monero miner
on Windows systems without requiring administrative privileges. It is designed
to simplify the process by handling download, checksum verification, extraction,
and execution steps with robust error handling.

WHAT IT DOES
-------------
1. **Configuration and Parameter Overrides**
   - The script uses default values for the wallet address, pool URL, and
     XMRig version, which can be overridden by passing command-line arguments.
   - Usage:
       setup_script.bat [WALLET] [POOL] [XMRIG_VERSION]
     
2. **Target Directory and Logging**
   - Creates a dedicated target directory in the local app data folder.
   - Logs all actions and errors to a log file for troubleshooting.

3. **Tool Availability Checks**
   - Verifies that PowerShell and certutil are available on the system before proceeding.

4. **Downloading XMRig**
   - Downloads the specified version of the XMRig zip file from GitHub.
   - Uses PowerShell as the primary download method with a fallback to certutil.
   - Implements dynamic retry logic with exponential backoff for reliability.

5. **Checksum Verification**
   - Validates the integrity of the downloaded file by comparing its SHA256 hash against
     the expected checksum.

6. **Extraction and Cleanup**
   - Extracts the downloaded zip file using PowerShell.
   - Identifies the correct extracted folder and cleans up the zip file after extraction.
   - Uses retry logic for extraction to ensure the process completes successfully.

7. **Miner Execution**
   - Validates the existence of `xmrig.exe` in the extracted folder.
   - Starts the XMRig miner in the background with the provided parameters (pool, wallet, TLS, and donation level).
   - The script notifies the user of successful startup and logs the event.

WHY IT'S GOOD
--------------
- **Admin-Free Operation:** Runs without requiring elevated privileges.
- **Reliability:** Incorporates multiple fallback mechanisms and retry logic to handle download/extraction failures.
- **Security:** Validates downloads using SHA256 checksums to prevent tampering.
- **Ease of Use:** Simple configuration through command-line parameters and clear logging for troubleshooting.
- **Automation:** Seamlessly handles the complete setup process from download to miner execution.

HOW TO USE
----------
1. **Preparation**
   - Ensure your system has PowerShell and certutil available.
   - Save the script as a `.bat` file (e.g., `setup_script.bat`).

2. **Running the Script**
   - Open a Command Prompt.
   - Navigate to the directory containing the script.
   - Execute the script with optional parameters:
       ```
       setup_script.bat [YOUR_WALLET_ADDRESS] [POOL_URL] [XMRIG_VERSION]
       ```
     - If no parameters are provided, the script will use the default values.

3. **Monitoring**
   - The script creates a log file (`xmrig_setup.log`) in the target directory.
   - You can review this file for details on each step of the setup process.

4. **Post-Setup**
   - Once executed, the script will start the miner in the background.
   - Verify that `xmrig.exe` is running via Task Manager.

LICENSE / DISCLAIMER
----------------------
This script is provided for educational and personal use only.
Use it at your own risk. The author is not responsible for any damage or
misuse of this tool. Ensure compliance with local laws and regulations regarding
cryptocurrency mining.

===========================================================================
