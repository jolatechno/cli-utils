CHMOD = chmod +x
CP = cp

TARGETS = $(shell ls . -I Makefile)

all: .$(TARGETS)

.$(TARGETS): .check_auth
	$(eval file := $(shell echo $@ | tr -d .))

	${CHMOD} $(file)
	${CP} $(file) /usr/bin/
	@echo "copied $(file) to /usr/bin/$(file)"

.check_auth:
ifneq ($(shell id -u), 0)
	@echo "root privilege needed..."
	false
endif
