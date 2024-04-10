CHMOD = chmod +x
CP = cp

TARGETS = $(shell ls . -I Makefile)

all: $(TARGETS)

$(TARGETS): .check_auth
	bash ../install-cmd.sh $@

.check_auth:
ifneq ($(shell id -u), 0)
	@echo "root privilege needed..."
	false
endif
