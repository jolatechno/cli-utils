MKDIR = mkdir
CHMOD = chmod +x
CP = cp

TARGETS = $(shell ls . -I Makefile)

all: $(TARGETS)

$(TARGETS): .check_auth
	bash ../install-cmds.sh $@

.create_file:
ifeq ($(wildcard /etc/git-cli-utils/3dPrinting/params.json),)
	${MKDIR} /etc/git-cli-utils/3dPrinting
	@echo '{"axis": "Z", "scaling_factor": 1.0, "base_height": 0.0, "offset": 0.0}' > /etc/git-cli-utils/3dPrinting/params.json
endif

.check_auth:
ifneq ($(shell id -u), 0)
	@echo "root privilege needed..."
	false
endif
