# TODO

This project can be improved:

* Properly set the ServerName in apache configuration
* Network "host" mode is currently required because of the nature of WOL packets. A solution working with bridge neworking will be nice and improve security as well as remove the need to hack around apache ports.
* Run as another user: currently this container runs as root. To improve security we should switch to another user.
