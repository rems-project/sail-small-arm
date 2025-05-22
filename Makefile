SAIL:=sail -Ofast_undefined
SAILFLAGS=

default: armV8.v

# the order of the files is important
SOURCES=\
  prelude.sail\
  armV8.h.sail\
  armV8_A64_sys_regs.sail\
  armV8_A64_special_purpose_regs.sail\
  armV8_A32_sys_regs.sail\
  armV8_pstate.sail\
  armV8_lib.h.sail\
  armV8_common_lib.sail\
  armV8_A64_lib.sail\
  armV8.sail\


.PHONY: interactive
interactive:
	$(SAIL) $(SAILFLAGS) -i $(SOURCES)

.PHONY: check
check:
	$(SAIL) $(SAILFLAGS) -i $(SOURCES)

armV8.v armV8_types.v: $(SOURCES)
	$(SAIL) $(SAILFLAGS) -coq -coq_lib armV8_extras -o armV8 $^

armV8.vo armV8_types.vo armV8_extras.vo: armV8.v armV8_types.v armV8_extras.v
	coqc armV8_types.v
	coqc armV8_extras.v
	coqc armV8.v

clean:
	rm -f armV8.v armV8_types.v
	rm -f *.vo *.vos *.vok *.glob .*.aux
######################################################################
ETCDIR=etc

apply_header:
	headache -c $(ETCDIR)/headache_config -h $(ETCDIR)/header *.sail *.v

.PHONY: apply_header
