.PHONY: all
all:

pspin:
	git clone https://github.com/spcl/pspin.git
	cd pspin && git checkout a49fec8b582990f9c7f295386274a62ae0380b55

.PHONY: patch
patch: pspin
	cd pspin \
	&& git apply ../soc_dma_wrap.patch

.PHONY: clean
clean: rm -rf pspin
