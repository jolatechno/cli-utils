MKDIR = mkdir
CHMOD = chmod +x
CP = cp

.DEFAULT_GOAL = .base
FILE = /etc/git-cli-utils/.conf

TARGETS = $(shell cd ./cmds && ls -d */ | tr -d /)
FILES = $(shell cd ./cmds && ls -p | grep -v /)
INSTALLED = $(shell cat ${FILE})

ifndef VERBOSE
.SILENT:
endif

all: $(TARGETS)

update: $(INSTALLED)

$(TARGETS): .base
	@echo "\ninstalling $@..."
	@echo "$@ " >> $(FILE)
	cd ./cmds/$@ && $(MAKE)

.base: .check_auth .create_dir .$(FILES)
	@echo "" > $(FILE)

.$(FILES):
	$(eval file := $(shell echo $@ | tr -d .))

	${CHMOD} ./cmds/$(file)
	${CP} ./cmds/$(file) /usr/bin/
	@echo "copied $(file) to /usr/bin/$(file)"

.create_dir:
ifeq ($(wildcard /etc/git-cli-utils/),)
	${MKDIR} /etc/git-cli-utils/
endif

.check_auth:
ifneq ($(shell id -u), 0)
	@echo "root privilege needed..."
	false
endif
