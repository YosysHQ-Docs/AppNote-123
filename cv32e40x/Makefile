.PHONY: all
all:

core-v-verif:
	git clone https://github.com/openhwgroup/core-v-verif.git
	cd $@ \
	&& git checkout 7082e9affb68bc496e7a379dba2de68f0502e881 \
	&& bin/clonetb -x

core-v-verif/core-v-cores/cv32e40x: core-v-verif
	cd core-v-verif/core-v-cores \
	&& git clone https://github.com/openhwgroup/cv32e40x
	cd $@ \
	&& git checkout b658fbe0b24da9b60d18d737c4ff4cf58b15dd8f

.PHONY: patch-dv unpatch-dv
patch-dv:
	cd core-v-verif/cv32e40x \
	&& git apply ../../dv.patch
unpatch-dv:
	cd core-v-verif/cv32e40x \
	&& git apply -R ../../dv.patch

.PHONY: patch-core unpatch-core
patch-core:
	cd core-v-verif/core-v-cores/cv32e40x \
	&& git apply ../../../core.patch
unpatch-core:
	cd core-v-verif/core-v-cores/cv32e40x \
	&& git apply -R ../../../core.patch

CORE_V_VERIF ?= $(realpath core-v-verif)
CV_CORE      ?= cv32e40x

export CV_CORE_PKG  ?= $(CORE_V_VERIF)/core-v-cores/$(CV_CORE)

export DV_ISA_DECODER_PATH  ?= $(CORE_V_VERIF)/lib/isa_decoder
export DV_SUPPORT_PATH      ?= $(CORE_V_VERIF)/lib/support
export DV_UVM_TESTCASE_PATH ?= $(CORE_V_VERIF)/$(CV_CORE)/tests/uvmt
export DV_UVMA_PATH         ?= $(CORE_V_VERIF)/lib/uvm_agents
export DV_UVME_PATH         ?= $(CORE_V_VERIF)/$(CV_CORE)/env/uvme
export DV_UVMT_PATH         ?= $(CORE_V_VERIF)/$(CV_CORE)/tb/uvmt

export DESIGN_RTL_DIR ?= $(CV_CORE_PKG)/rtl

sby-%:
	sby -f cv32e40x.sby $*
