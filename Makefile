include python.mk
include cpp.mk

.PHONY: help
help:  ## show this message and exit
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk -F':' '{print $$(NF-1)":"$$NF}' | sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "$(BOLD)%-24s$(END) %s\n", $$1, $$2}'
