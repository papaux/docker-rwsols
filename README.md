# Docker container for RWSOLS

RWSOLS is a nice small web appliation that allows to wakeup computers from your low power computer like a Raspberry Pi.

The project is developed by sciguy14 and hosted here: https://github.com/sciguy14/Remote-Wake-Sleep-On-LAN-Server

This repository uses the original code and makes it run in a docker container, providing easier installation and setup.

## Getting started

### Configure

The project comes with a pre-configured `docker-compose.yml` for easy startup. This will also take care of building the image.
While you can use it right away, your RWSOLS won't be helpful until you configure your network hosts to wake up.

#### Your network hosts

Open the `docker-compose.yml` file and set the environment variables to match your setup. Configure at least:

* `WOL_COMPUTER_NAMES`
* `WOL_COMPUTER_MACS`
* `WOL_COMPUTER_LOCAL_IPS`

All values should set as a comma separated list. The ordering must match for each three variables.

#### Password

The web interface requires a password before waking up your hosts. This password is encoded with `sha256`.

Use the provided help script to create a hash based on your password of choice:

```
./generate-password.sh
```

Once you enter your password, you get a hash:

```
Your password hash: 3fc9b689459d738f8c88a3a48aa9e33542016b7a4052e001aaa536fca74813cb
```

Copy this hash in the compose file, for the variable `WOL_PASSWORD_HASH`.

#### Other parameters

You can change additional variables like the ports and ping times. Have a look at [this sample config file](https://github.com/sciguy14/Remote-Wake-Sleep-On-LAN-Server/blob/master/config_sample.php) for a descriptions of each parameters.

### HTTPS Setup

The server supports HTTPS. In order to enable it, you need to create the certificates and copy them to a `ssl` folder that will be mounted to the image.

Use the helper script to create the certificates:

```
./generate-certs.sh
```

Answer the questions and you'll get the certificates in the `ssl` folder:

```
$ ls ssl/
wol.crt  wol.csr  wol.key
```

You can also use your own signed certificates by copying them in the folder, using the same naming.
