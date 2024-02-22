.PHONY: all
all: clone patch

.PHONY: clone
clone: Cores-VeeR-EH1 SVA-AXI4-FVIP

Cores-VeeR-EH1:
	git clone https://github.com/chipsalliance/Cores-VeeR-EH1
	cd $@ && git checkout 915fb34a5b38ef14c5d5c05431765ad8b912bc34

SVA-AXI4-FVIP:
	git clone https://github.com/YosysHQ-GmbH/SVA-AXI4-FVIP
	cd $@ && git checkout 250f1ffd47fc1cdc4b4dd1670c6e1df58dec1b12

CORE_PATCHES = dma_ctrl.patch

.PHONY: patch
patch: Cores-VeeR-EH1
	cd Cores-VeeR-EH1 \
	$(foreach patch,$(CORE_PATCHES),&& git apply ../$(patch))

.PHONY: unpatch
unpatch:
	cd Cores-VeeR-EH1 \
	$(foreach patch,$(CORE_PATCHES),&& git apply -R ../$(patch))

.PHONY: clean
clean:
	rm -rf Cores-VeeR-EH1
	rm -rf SVA-AXI4-FVIP
