# GitLab Runner Usermode

This is a repo for
[`podman`](https://podman.io/)/[`buildah`](https://buildah.io/) container images
hosting [`gitlab-runner`](https://gitlab.com/gitlab-org/gitlab-runner). I
created this since Fedora 31 uses cgroupsv2, the traditional `docker` daemon is
no longer supported, and the rpm from the `gitlab-runner` repo had SELinux
issues.

The configuration here allows for the use of nested `buildah` containers while
running in usermode.

This only supports the shell executor until
[this issue](https://gitlab.com/gitlab-org/gitlab-runner/issues/4357) is closed.

## Installation

### Building the image
```
podman pull quay.io/vddvss/gitlab-runner-user:latest
```

Or

```
make build-image
```

### Installing `systemd` unit file

```
make install
```

### Registering the runner with GitLab

To register the runner with GitLab, run:

```
make register
```

This will place the `config.toml` file in `~/.config/gitlab-runner`.

### Starting the service

To start the service, run:

```
systemctl --user start gitlab-runner-user.service
```

And to stop the service:

```
systemctl --user stop gitlab-runner-user.service
```

