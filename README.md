# nanak8s-setup

Ansible playbook to install [nanak8s](https://github.com/Japan7/nanak8s).

Requirements to run the playbook:
- Alpine or Gentoo
- innernet installed and configured to use japanet7
- passthrough of the requests from your main server. [e.g. configuration for Traefik in step 4.](https://github.com/Japan7/nanak8s#steps)

# running the playbook

Install Ansible on your local machine and run:

```sh
$ ./run_playbook.sh <hostname of your server>
```

You can use the reboot playbook to reboot your server (properly) from your local machine:

```sh
$ ./reboot_playbook.sh <hostname of your server>
```
