SAIL:=sail
export SAIL_OPTS= --Ofast-undefined
export SAIL_COQ_OPTS= --coq-record-update
# The order of files in sail_files is important
SOURCES=$(shell cat sail_files)

default: coq

.PHONY: coq
coq:
	dune build

.PHONY: coq-snapshot
coq-snapshot:
	@# First build the file and then check that they match
	-dune build @snapshot --auto-promote
	@dune build @snapshot

.PHONY: interactive
interactive:
	$(SAIL) $(SAIL_OPTS) -i $(SOURCES)

.PHONY: check
check:
	$(SAIL) $(SAIL_OPTS) -i $(SOURCES)

.PHONY: clean
clean:
	dune clean

######################################################################
ETCDIR=etc

.PHONY: apply_header
apply_header:
	headache -c $(ETCDIR)/headache_config -h $(ETCDIR)/header *.sail *.v

