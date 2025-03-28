# MDB Auto Server Setup Script (Public)

Bash Script Automating The Setup Of A Website Server.

> **Note:** This is the *public version* of a private repository by the same organization (*2MServer*).
> 

## Overview

> (...To do... )
> 

## Features

> (...To do...)
> 

## Usage

> **Important:** This script has no (takes no) parameters — no arguments, options, or flags — and never parses/handles any.
Never call/execute/run the script with any kind of parameters. 
Just execute it using the 'slash' style call (for example, on the command-line or in the terminal: `./PATH/TO/DIRECTORY/the_script_name.sh`).
> 

---

### Step-by-step Instructions

1. **Obtain the script:** Save/place the script somewhere on local machine (user's home directory is probably a good place), by any *one* of the following methods:
    - Online, open/view the script file (`mdb_auto_server_script.sh`), then save/download the file.
    - Online, open/view the script file (`mdb_auto_server_script.sh`), copy all of the file's contents and then paste into a newly created file on your local machine.
    - Clone the repository using either the GitHub Desktop (GUI-style) app.
    - Clone the repository: on the command-line or in at the terminal by running **ONE** of the following commands...
    - **Via HTTPS:**
        
        ```bash
        git clone https://github.com/2MServer/MDB-Auto-Server-Setup-Script-Public.git
        ```
        
    - **Via SSH:**
        
        ```bash
        git clone git@github.com:2MServer/MDB-Auto-Server-Setup-Script-Public.git
        ```
        
    - **Via the GitHub CLI (must be installed):**
        
        ```bash
        gh repo clone 2MServer/MDB-Auto-Server-Setup-Script-Public
        ```
        
    
    In the case of cloning the repository on the command line (terminal), be sure to then **change into the newly-cloned directory**, using the following command:
    
    ```bash
    cd MDB-Auto-Server-Setup-Script-Public
    ```
    

3. Run the following commands from whatever directory the script is saved in:

```bash
### ...Assuming you are already in the directory containing the script,
### (which, when cloning the repo, is the root of the cloned
### directory, i.e., 'MDB-Auto-Server-Setup-Script-Public').

# Make the script executable
chmod +x mdb_auto_server_setup.sh

# Execute script with Sudo permissions...
sudo ./mdb_auto_server_setup.sh
```

...Then, follow the steps the script walks you through.
