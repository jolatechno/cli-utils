all:
	for filename in *; do \
		if [ ! "$$filename" -ef ./Makefile ] ; then \
			chmod +x $$filename && \
			cp $$filename /usr/bin/ && \
			echo "copied $$filename to /usr/bin/$$filename"; \
		fi \
	done
