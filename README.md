# SSH Honeypot

This is a simple SSH honeypot made using Python and Bash. This honeypot is made to run on a Linux machine.

## Sections
[Design](#design)

[How to Use](#how-to-use)

[References](#references)

## Design
### Log Format
#### Password Authentication Logs
Label Format: username(first 10) ip_address timestamp

Log Format: label:str,ip_address:str,latitude:int,longitude:int,country:str,username:str,password:str,timestamp:str/time

#### Public Key Authentication Logs
Label Format: username(first 10) ip_address timestamp

Log Format: label:str,ip_address:str,latitude:int,longitude:int,country:str,username:str,key_type:str,fingerprint:str,base64:str,bits:int,timestamp:str/time

## How to Use
Clone this repository onto your machine:

```bash
git clone https://github.com/ManuelDogbatse/ssh_honeypot.git
cd ssh_honeypot
```

Run the 'setup_environment.sh' script and follow the instructions:

> NOTE - To get an app.ipgeolocation.io API key for getting the geolocation of honeypot attackers, go to [ipgeolocation's website](https://app.ipgeolocation.io) and sign up. Then on the dashboard, create a new API key.

```bash
chmod 755 ./setup_environment.sh
./setup_environment.sh
```

Start the honeypot server (see [Docker Engine installation](https://docs.docker.com/engine/install/) to download Docker):

```bash
docker compose up -d --build
```

Your logs will appear in the ```logs``` directory, named ```ssh_password_logins.log``` and ```ssh_public_key_logins.log```.

If you have warning connecting to the SSH server like this:

<p align="center">
<img src="./remote_host_warning.jpg" alt="Remote Host Warning" height=120px/>
</p>

Make sure you are connecting to the correct IP address, and type this in your SSH client console to reset the known_host key stored for the honeypot SSH server:

```bash
ssh-keygen -R [<ip_addr>]:<port>
```

## References
- [0xdf - Creating a SSH Honeypot with Python](https://www.youtube.com/watch?v=HO1h57CiF98&t=435s)
- [How to build an SSH honeypot in Python and Docker - Part 1](https://securehoney.net/blog/how-to-build-an-ssh-honeypot-in-python-and-docker-part-1.html)
- [Paramiko Documentation](https://docs.paramiko.org/en/latest/)