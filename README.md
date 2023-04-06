
This Python script can block a list of websites during specific hours by modifying the hosts file on your system.

## Usage

1. Clone the repository to your local machine:

git clone https://github.com/yourusername/website-blocker.git

markdown


2. Edit the `websites.txt` file and add the list of websites you want to block, one per line.

3. Edit the `block_websites.py` file and set the hours you want to block the websites for by changing the values of `start_hour` and `end_hour`.

4. Run the script with root privileges:

```bash 
sudo python block_websites.py
```


The script will run in the background and block the specified websites during the specified hours.

Note that you may be prompted to enter your password when running the script.

## Running the Script at Startup

If you want the script to run at startup, you can add a shell script that runs the Python script to your system's startup programs. Here's an example shell script:

```bash
#!/bin/bash
python /path/to/block_websites.py &
```

Replace `"/path/to/block_websites.py"` with the path to the `block_websites.py` file. Make sure the shell script is executable by running `chmod +x /path/to/startup_script.sh`.

To add the shell script to your system's startup programs, you can follow these general steps:

- On Windows, press `Win + R` and type `shell:startup`. On Linux or macOS, go to your system's startup programs configuration and add a new entry with the path to the shell script.
- Copy the shell script to the folder that opens.
- Restart your system and the Python script should run at startup.

## Disclaimer

Be careful when modifying the hosts file as it can affect your system's functionality. Use this script at your own risk.
