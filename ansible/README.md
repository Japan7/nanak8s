# nanak8s-setup

Ansible playbook to install [nanak8s](https://github.com/Japan7/nanak8s).

# Requirements

Supported linux distributions on the node: Alpine, Arch, Debian, Gentoo, Rocky or Ubuntu

[innernet](https://github.com/tonarino/innernet) must be installed.
Ask for an invitation file and setup the japanet7 interface.

Install Ansible, sops and age on the computer from which you plan to administrate your node.
If you want to use the reboot playbook (which you should use or replicate
manually when you have to [reboot your node](#rebooting-your-node)) you should
install it locally on your computer/laptop.

Ansible is packaged on most distributions, or can be [installed with pipx or
pip](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

Secrets in this repository are encrypted using `sops` and `age`, they are
required to run the install playbook.
sops can be installed from the instructions on their 
[release page](https://github.com/getsops/sops/releases/tag/v3.8.1) it is also
available on [some distributions](https://repology.org/project/sops/versions).
age can be installed from [their instructions](https://github.com/FiloSottile/age#installation).
You must ask for the age key on discord and keep it somewhere, and then set the
`SOPS_AGE_KEY` or `SOPS_AGE_KEY_FILE` accordingly.

`bash` is needed to run the `run_playbook.sh` script.

# Install innernet

You can install innernet with the innernet playbook from your local machine:

```sh
$ ./run_playbook.sh <hostname of your server> innernet
```

Or if running directly from your server:

```sh
$ ./run_playbook.sh localhost innernet
```

NOTE: the playbook installs local services that sets the MTU to 1420, as
recommended in [nanak8s' README](https://github.com/Japan7/nanak8s#steps).

Now, ask for your invitation file before running the next steps in the next section.

```sh
$ innernet install /path/to/invitation.toml
```

# Install nanak8s

Install Ansible on your local machine and run:

```sh
$ ./run_playbook.sh <hostname of your server> main
```

You can set the name of the innernet interface with the NANAK8S_IFACE
environment variable and the type of the node (agent|server) with
NANAK8S_NODE_TYPE.
These variables can be set with [direnv](https://github.com/direnv/direnv) or
similar shell tools for ease of use.

```sh
$ NANAK8S_NODE_TYPE=agent NANAK8S_IFACE=nanak8s ./run_playbook.sh <hostname of your server> main
```

if you are running the playbook directly from the server:
```sh
$ ./run_playbook.sh localhost main
```

# Rebooting your node

You can use the reboot playbook to reboot your server (properly) from your local machine:

```sh
$ ./run_playbook.sh <hostname of your server> reboot
```

This will run the `kubectl drain --ignore-daemonsets --delete-emptydir-data $(hostname)`
before rebooting and `kubectl uncordon` when the node comes back up.

# Optional: Set up your node as an entrypoint to the cluster

See:
https://github.com/Japan7/nanak8s#4-optional-set-up-your-node-as-an-entrypoint-to-the-cluster

# Garage setup

Garage only works with Gentoo and Alpine (for now).

Innernet has to be set up for garage to work.

You can set the GARAGE_DATA_DIR to the directory where you want the data to be
stored on the server.

```sh
$ export GARAGE_DATA_DIR=/media/japan7/garage  # you should store this somewhere
$ ./run_playbook.sh <hostname of your server> garage
```
