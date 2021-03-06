BASE_DIR                       = $(PWD)
DCOS_TEMPLATE                 ?= $(BASE_DIR)/tools/riak-mesos-tools/config/config.dcos.template.json
DCOS_REMOTE                   ?= $(BASE_DIR)/tools/riak-mesos-tools/config/config.dcos.json
TOOLS_TEMPLATE                ?= $(BASE_DIR)/tools/riak-mesos-tools/config/config.template.json
TOOLS_REMOTE                  ?= $(BASE_DIR)/tools/riak-mesos-tools/config/config.example.json
TOOLS_LOCAL                   ?= $(BASE_DIR)/tools/riak-mesos-tools/config/config.local.json
REPO_TEMPLATE                 ?= $(BASE_DIR)/config/config.template.json
REPO_REMOTE                   ?= $(BASE_DIR)/tools/riak-mesos-dcos-repo/repo/packages/R/riak/0/config.json
TOOLS_VERSION_FILE            ?= $(BASE_DIR)/tools/riak-mesos-tools/riak_mesos/constants.py
REPO_VERSION_FILE             ?= $(BASE_DIR)/tools/riak-mesos-dcos-repo/repo/packages/R/riak/0/package.json
REPO_CMD_TEMPLATE             ?= $(BASE_DIR)/config/command.template.json
REPO_CMD_FILE                 ?= $(BASE_DIR)/tools/riak-mesos-dcos-repo/repo/packages/R/riak/0/command.json

.PHONY: all deps clean update-head

all: update-head tarball config
dev: deps tarball config

.config.packages:
	cp $(TOOLS_TEMPLATE) $(TOOLS_REMOTE) && \
	cp $(TOOLS_TEMPLATE) $(TOOLS_LOCAL) && \
	cp $(REPO_TEMPLATE) $(REPO_REMOTE) && \
	cp $(DCOS_TEMPLATE) $(DCOS_REMOTE) && \
	sed -i "s,{{scheduler_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-scheduler/packages/remote.txt),g" $(TOOLS_REMOTE) && \
	sed -i "s,{{scheduler_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-scheduler/packages/local.txt),g" $(TOOLS_LOCAL) && \
	sed -i "s,{{scheduler_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-scheduler/packages/remote.txt),g" $(REPO_REMOTE) && \
	sed -i "s,{{scheduler_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-scheduler/packages/remote.txt),g" $(DCOS_REMOTE) && \
	sed -i "s,{{executor_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/remote.txt),g" $(TOOLS_REMOTE) && \
	sed -i "s,{{executor_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/local.txt),g" $(TOOLS_LOCAL) && \
	sed -i "s,{{executor_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/remote.txt),g" $(REPO_REMOTE) && \
	sed -i "s,{{executor_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/remote.txt),g" $(DCOS_REMOTE) && \
	sed -i "s,{{node_url}},$(shell cat $(BASE_DIR)/riak/packages/remote.txt),g" $(TOOLS_REMOTE) && \
	sed -i "s,{{node_url}},$(shell cat $(BASE_DIR)/riak/packages/local.txt),g" $(TOOLS_LOCAL) && \
	sed -i "s,{{node_url}},$(shell cat $(BASE_DIR)/riak/packages/remote.txt),g" $(REPO_REMOTE) && \
	sed -i "s,{{node_url}},$(shell cat $(BASE_DIR)/riak/packages/remote.txt),g" $(DCOS_REMOTE) && \
	sed -i "s,{{director_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-director/packages/remote.txt),g" $(TOOLS_REMOTE) && \
	sed -i "s,{{director_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-director/packages/local.txt),g" $(TOOLS_LOCAL) && \
	sed -i "s,{{director_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-director/packages/remote.txt),g" $(REPO_REMOTE) && \
	sed -i "s,{{director_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-director/packages/remote.txt),g" $(DCOS_REMOTE) && \
	sed -i "s,{{explorer_url}},$(shell cat $(BASE_DIR)/framework/riak_explorer/packages/remote.txt),g" $(TOOLS_REMOTE) && \
	sed -i "s,{{explorer_url}},$(shell cat $(BASE_DIR)/framework/riak_explorer/packages/local.txt),g" $(TOOLS_LOCAL) && \
	sed -i "s,{{explorer_url}},$(shell cat $(BASE_DIR)/framework/riak_explorer/packages/remote.txt),g" $(REPO_REMOTE) && \
	sed -i "s,{{explorer_url}},$(shell cat $(BASE_DIR)/framework/riak_explorer/packages/remote.txt),g" $(DCOS_REMOTE) && \
	sed -i "s,{{patches_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/patches_remote.txt),g" $(TOOLS_REMOTE) && \
	sed -i "s,{{patches_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/patches_local.txt),g" $(TOOLS_LOCAL) && \
	sed -i "s,{{patches_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/patches_remote.txt),g" $(REPO_REMOTE) && \
	sed -i "s,{{patches_url}},$(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/patches_remote.txt),g" $(DCOS_REMOTE) && \
	sed -i "s,{{patches_package}},$(shell basename $(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/patches_local.txt)),g" $(REPO_REMOTE) && \
	sed -i "s,{{patches_package}},$(shell basename $(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/patches_local.txt)),g" $(DCOS_REMOTE) && \
	sed -i "s,{{explorer_package}},$(shell basename $(shell cat $(BASE_DIR)/framework/riak_explorer/packages/local.txt)),g" $(REPO_REMOTE) && \
	sed -i "s,{{explorer_package}},$(shell basename $(shell cat $(BASE_DIR)/framework/riak_explorer/packages/local.txt)),g" $(DCOS_REMOTE) && \
	sed -i "s,{{node_package}},$(shell basename $(shell cat $(BASE_DIR)/riak/packages/local.txt)),g" $(REPO_REMOTE) && \
	sed -i "s,{{node_package}},$(shell basename $(shell cat $(BASE_DIR)/riak/packages/local.txt)),g" $(DCOS_REMOTE) && \
	sed -i "s,{{executor_package}},$(shell basename $(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/local.txt)),g" $(REPO_REMOTE) && \
	sed -i "s,{{executor_package}},$(shell basename $(shell cat $(BASE_DIR)/framework/riak-mesos-executor/packages/local.txt)),g" $(DCOS_REMOTE) && \
	sed -i "s,{{scheduler_package}},$(shell basename $(shell cat $(BASE_DIR)/framework/riak-mesos-scheduler/packages/local.txt)),g" $(REPO_REMOTE) && \
	sed -i "s,{{scheduler_package}},$(shell basename $(shell cat $(BASE_DIR)/framework/riak-mesos-scheduler/packages/local.txt)),g" $(DCOS_REMOTE)
.config.version:
	cp $(REPO_CMD_TEMPLATE) $(REPO_CMD_FILE) && \
	sed -i "s,^version = .*$$,version = '$(shell git describe --tags --abbrev=0 | tr - .)',g" $(TOOLS_VERSION_FILE) && \
	sed -i "s,\"version\": \".*\",\"version\": \"$(shell git describe --tags --abbrev=0 | tr - .)\",g" $(REPO_VERSION_FILE) && \
	sed -i "s,{{tools_version}},$(shell cd tools/riak-mesos-tools && git rev-parse --abbrev-ref HEAD),g" $(REPO_CMD_FILE) && \
	cd tools/riak-mesos-dcos-repo/scripts && \
			./0-validate-version.sh && \
			./1-validate-packages.sh && \
			./2-build-index.sh && \
			./3-validate-index.sh
config: .config.packages .config.version

.tarball.riak-mesos-scheduler:
	cd $(BASE_DIR)/framework/riak-mesos-scheduler && $(MAKE) tarball && \
	touch ../../.tarball.riak-mesos-scheduler
.tarball.riak-mesos-executor:
	cd $(BASE_DIR)/framework/riak-mesos-executor && $(MAKE) tarball && \
	touch ../../.tarball.riak-mesos-executor
.tarball.riak-mesos-director:
	cd $(BASE_DIR)/framework/riak-mesos-director && $(MAKE) tarball && \
	touch ../../.tarball.riak-mesos-director
.tarball.riak_explorer:
	cd $(BASE_DIR)/framework/riak_explorer && $(MAKE) tarball && \
	touch ../../.tarball.riak_explorer
.tarball.framework: .tarball.riak-mesos-scheduler .tarball.riak-mesos-executor .tarball.riak-mesos-director .tarball.riak_explorer
.tarball.riak:
	cd $(BASE_DIR)/riak && $(MAKE) tarball && \
	touch ../.tarball.riak
tarball: .tarball.framework .tarball.riak

deps:
	@if [ -z "$$(git submodule foreach ls)" ]; then \
		git submodule update --init --recursive; \
	fi

clean-framework:
	-rm .tarball.riak-mesos-scheduler .tarball.riak-mesos-executor .tarball.riak-mesos-director .tarball.riak_explorer
	$(foreach dep,$(shell ls framework), \
		cd $(BASE_DIR)/framework/$(dep) && \
			$(MAKE) clean && rm -rf deps/* && rm -rf ebin/*.beam && git reset --hard HEAD;)
clean-riak:
	-rm .tarball.riak
	-rm -rf riak/$(RIAK_SOURCE_DIR)/deps/*
	cd riak && $(MAKE) clean
clean: clean-framework

update-head:
	git submodule update --init --recursive

sync:
	$(foreach dep,$(shell ls framework), \
		cd $(BASE_DIR)/framework/$(dep) && $(MAKE) sync;)
	cd $(BASE_DIR)/riak && make sync
