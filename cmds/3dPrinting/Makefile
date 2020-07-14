MKDIR := mkdir

all: create_file
	for filename in *; do \
		if [ ! "$$filename" -ef ./Makefile ] ; then \
			echo "copying $$filename to /usr/bin/$$filename..."; \
			chmod +x $$filename && \
			cp $$filename /usr/bin/; \
		fi \
	done

create_file:
ifeq ($(wildcard /etc/git-cli-utils/3dPrinting/params.json),)
	${MKDIR} /etc/git-cli-utils/3dPrinting
	@echo '{"axis": "Z", "scaling_factor": 1.0, "base_height": 0.0, "offset": 0.0}' > /etc/git-cli-utils/3dPrinting/params.json
endif
