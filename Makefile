MKDIR = mkdir
CHMOD = chmod +x
CP = cp

.DEFAULT_GOAL = .base
FILE = /etc/git-cli-utils/installed.conf

TARGETS = $(shell cd ./cmds && ls -d */ | tr -d /)
FILES = $(shell cd ./cmds && ls -p | grep -v /)
INSTALLED = $(shell cat ${FILE})

ifndef VERBOSE
.SILENT:
endif

all: $(TARGETS)

update: $(INSTALLED)

$(TARGETS): .base
	@echo -e "\n\ninstalling $@...\n"
	@echo "$@ " >> $(FILE)
	cd ./cmds/$@ && $(MAKE)

.base: .check_auth .create_dir .base_echo $(FILES)
	@echo ".base" > $(FILE)

.base_echo:
	@echo "installing base..."

$(FILES):
	cd ./cmds && bash ./install-cmd.sh $@

.create_dir:
ifeq ($(wildcard /etc/git-cli-utils/),)
	${MKDIR} /etc/git-cli-utils/
endif

.check_auth:
ifneq ($(shell id -u), 0)
	@echo "root privilege needed..."
	false
endif
