# Copyright 2019 Colin Samples
#
# SPDX-License-Identifier: Apache-2.0
#

.DEFAULT_GOAL := all

cfg_dir := $(shell systemd-path user-configuration)
data_home := $(shell systemd-path user-shared)

.PHONY: register
register: verify-uid
	mkdir -p $(cfg_dir)/gitlab-runner
	podman run --rm -it \
	    --volume $(cfg_dir)/gitlab-runner:/etc/gitlab-runner:Z \
	    gitlab-runner-user:latest \
	    /usr/bin/gitlab-runner register --executor shell

.PHONY: install
install: verify-uid
	install -d $(data_home)/systemd/user
	install -m 644 gitlab-runner-user.service $(data_home)/systemd/user
	systemctl --user daemon-reload

.PHONY: build-image
build-image: verify-uid
	buildah bud -t gitlab-runner-user $(CURDIR)

.PHONY: verify-uid
verify-uid:
	@[ $$UID != "0" ] || (echo "ERROR: must be run as normal user" ; exit 1)

.PHONY: all
all:
	@echo "Usage:"
	@echo "   make register    register the runner with GitLab"
	@echo "   make install     install the systemd unit file"
	@echo "   make build-image build the container image locally"

