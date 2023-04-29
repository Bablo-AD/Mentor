import time
import platform
import subprocess
import os

# Enter the path to the file that contains the list of websites
websites_file = "websites.txt"

# Enter the hours you want to block the websites for
start_hour = 15
end_hour = 21

# Get the path to the hosts file
system = platform.system()
if system == "Windows":
    hosts_path = r"C:\Windows\System32\drivers\etc\hosts"
elif system == "Linux" or system == "Darwin":
    hosts_path = "/etc/hosts"
else:
    raise Exception("Unsupported operating system")

# Read the list of websites from the file
with open(websites_file) as f:
    websites = f.read().splitlines()

# Block the websites during the specified hours
while True:
    current_hour = int(time.strftime('%H'))
    if current_hour >= start_hour or current_hour < end_hour:
        # Block the websites by adding them to the hosts file
        for website in websites:
            subprocess.run(["sudo", "sh", "-c", f"echo '127.0.0.1 {website}' >> {hosts_path}"])
    else:
        # Remove the websites from the hosts file if they're not within the blocked hours
        for website in websites:
            subprocess.run(["sudo", "sed", "-i", f"/{website}/d", hosts_path])
    time.sleep(60) # check the time every minute
