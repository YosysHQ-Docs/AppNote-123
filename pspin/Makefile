.PHONY: all
all:

pspin:
	git clone https://github.com/spcl/pspin.git
	cd pspin && git checkout a49fec8b582990f9c7f295386274a62ae0380b55

PATCHES = soc_dma_wrap.patch
PATCHES += riscv_core.patch
PATCHES += core_region.patch
PATCHES += pulp_cluster.patch

.PHONY: patch
patch: pspin
	cd pspin \
	$(foreach patch,$(PATCHES),&& git apply ../$(patch))

.PHONY: unpatch
unpatch:
	cd pspin \
	$(foreach patch,$(PATCHES),&& git apply -R ../$(patch))

.PHONY: clean
clean: rm -rf pspin
