# nanak8s-setup

Ansible playbook to install [nanak8s](https://github.com/Japan7/nanak8s).

Requirements to run the playbook:
- Alpine, Arch, Debian, Gentoo, Rocky or Ubuntu
- innernet installed and configured to use japanet7
- passthrough of the requests from your main server. [e.g. configuration for Traefik in step 4.](https://github.com/Japan7/nanak8s#steps)

# Install innernet

You can install innernet with the innernet playbook from your local machine:

```sh
$ ./install_innernet.sh <hostname of your server>
```

Or if running directly from your server:

```sh
$ ./install_innernet.sh localhost
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
$ ./run_playbook.sh <hostname of your server>
```

if you are running the playbook directly from the server:
```sh
$ ./run_playbook.sh localhost
```

You can use the reboot playbook to reboot your server (properly) from your local machine:

```sh
$ ./reboot_playbook.sh <hostname of your server>
```

This will run the `kubectl drain` command with the right arguments before
rebooting and `kubectl uncordon` when the node comes back up.
