MKDIR := mkdir
.DEFAULT_GOAL := base
FILE=/etc/git-cli-utils/.conf
TARGETS:= $(shell cat ${FILE})

ifndef VERBOSE
.SILENT:
endif

all: desktop 3dPrinting git nas

update: $(TARGETS)

desktop: base
	@echo "\ninstalling desktop..."
	@echo "desktop " >> $(FILE)
	cd cmds/desktop && $(MAKE)

3dPrinting: base
	@echo "\ninstalling 3dPrinting..."
	@echo "3dPrinting " >> $(FILE)
	cd cmds/3dPrinting && $(MAKE)

git: base
	@echo "\ninstalling git..."
	@echo "git " >> $(FILE)
	cd cmds/git && $(MAKE)

nas: base
	@echo "\ninstalling nas..."
	@echo "nas " >> $(FILE)
	cd cmds/nas && $(MAKE)

base: create_dir
	@echo "" > $(FILE)
	@echo "installing base..."
	cd cmds/base && $(MAKE)

create_dir:
ifeq ($(wildcard /etc/git-cli-utils/),)
	${MKDIR} /etc/git-cli-utils/
endif
