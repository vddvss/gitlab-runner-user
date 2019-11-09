# Copyright 2019 Colin Samples
#
# SPDX-License-Identifier: Apache-2.0
#

FROM fedora:31

ARG RUNNER_VERSION="v12.4.1"

RUN dnf -y update && \
    dnf -y install \
        buildah \
        curl \
        git \
        git-lfs \
        golang-bin \
        hostname \
        make \
    --setopt install_weak_deps=false && \
    dnf clean all

RUN mkdir -p /workdir
WORKDIR /workdir

# vfs seems to run faster for me than fuse-overlayfs
RUN sed -e 's/^driver =.*/driver = "vfs"/' \
        -e '/^mountopt =.*/d' \
        -i /etc/containers/storage.conf

RUN RUNNER_BASENAME="gitlab-runner-$RUNNER_VERSION" && \
    RUNNER_URL="https://gitlab.com/gitlab-org/gitlab-runner/-/archive/$RUNNER_VERSION/$RUNNER_BASENAME.tar.gz" && \
    curl -sS $RUNNER_URL | tar xz && \
    make -C $RUNNER_BASENAME build_simple && \
    mv $RUNNER_BASENAME/out/binaries/gitlab-runner /usr/bin && \
    rm -rf *

RUN dnf -y remove golang-bin

EXPOSE 443

# In order to run `buildah` from within the container, we have to set its
# isolation to just use `chroot`. This isn't a huge issue, as we are already
# inside a container.
ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot

CMD ["/usr/bin/gitlab-runner", "run"]

