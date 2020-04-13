# fivem-server-starter
File batch to easy start your fivem server and easy upgrade artifacts on Windows


## Usage
1. Download ZIP
2. Put `start.bat` in the server-data folder
3. Open file with notepad (or any text editor)
4. Replace `C:\change\this\folder\with\your\artifact\folder` with your artifact folder
5. Open the starter (double-click on `start.bat`)

## Advanced usage
You can change the config values
> **source**: The artifact location

> **starter**: The name of the artifact startert `default=FXServer.exe`

> **config**: The name of server configuration file `default=server.cfg`

> **configFolder**: The folder of the server data and configuration `default=%~dp0 (current folder)`

> **autoUpgrade**: actually doesn't work

> **autoSelect**: when 1 select the latest version the script found, when 0 let user select the version from the list
>if there is more than one version available

> **pauseBeforeStart**: when 1 use a `pause` command just before start the server to let you debug properly

### Best practice

To has a better server don't putt all files in the same folder, use something like the following tree
 - **FiveM**
   - **server**
     - **serverName** (this will contain server.cfg)
   - **source**
     - **2315** (this is an artifact with the version in the foldername)
     - **2108** (another artifact version)

In this way you can easy download the latest version and the starter (with `autoSelect=1`) will start your server
with the new version and in case this create you some troubles you can easy downgrade or debug

