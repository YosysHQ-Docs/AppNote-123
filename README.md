Advanced SBY Use by Example
===========================

The following three designs demonstrate advanced usage of SBY for large and
complex designs.

cv32e40x
--------

This design is based on openhwgroup/cv32e40x-dv/, converting the existing
[`Jasper
script`](https://github.com/openhwgroup/cv32e40x-dv/blob/main/fv/jaspergold.tcl)
to an equivalent SBY implementation.  This core contains around 250 cover
statements, and 750 assertions when run in SBY.  Some adjustments were required
to remove unsupported features from the SVA (especially those that rely on UVM
support).

Just as the Jasper script relied on environment variables defined in makefiles,
so too does the SBY script.  As such, it is recommended to call `make
sby-[task]` to provide the needed variables.

```bash
cd cv32e40x
# clone cv32e40x and verification environment
make clone
# patch source
make patch
# run SBY
make sby-bmc # bmc, pdr, or cover
```

Automatic multiplier detection and blackboxing is not supported in SBY and must
instead be done manually in the `[script]` section with the `cutpoint` command
from Yosys.  Calling `cutpoint cv32e40x_ex_stage*_0/mul.mult_i` disconnects all
the inputs to the `riscv_mult` and connects `$anyseq` cells to all of the
outputs.

#### Note:
It is generally recommended to include all source files in the SBY `[files]`
section and only use relative references.  This ensures that any changes to the
source files do not affect tasks in progress and allows for easier debugging
since only the output folder needs to be examined.  For this design, most of the
files use absolute references in a series of list files which are referenced
recursively.

veer
----

This design uses the [VeeR EH1 RISC-V Core](chipsalliance/Cores-VeeR-EH1) to
demonstrate the use of tasks and tags in SBY.  An SVA assertion is added which
is known to fail at step 31 of BMC.

```
[options]
..
fail: expect fail
..

[script]
..
# remove target assertion
~fail: chformal -assert -remove veer_wrapper/formal_setup_inst.target
..

[file bind.sv]
module formal_setup();
..
    always @* begin
..
        if (!rst)
            target: assert (!veer_wrapper.veer.dec.tlu.synchronous_flush_e4);
..
endmodule

bind veer_wrapper formal_setup formal_setup_inst(.*);
```

```bash
cd veer
# clone VeeR
make Cores-VeeR-EH1
# run SBY
sby [-f] veer_benchmark.sby bmc # bmc, pdr, cover, or fail
```

This design also includes a dma axi interface which, by default, is not
configured and will result in failing assertions.

With a few steps, it is possible to check AXI properties via
YosysHQ-GmbH/SVA-AXI4-FVIP:
```bash
# clone AXI verification IP
make SVA-AXI4-FVIP
# patch source
make patch
# run SBY
sby [-f] veer_benchmark.sby axi-bmc # bmc, pdr, or cover
```

By default, the dma axi interface is not configured and will cause failed
assertions.  The `axi` tag is used to avoid this by converting the assert
properties to assume properties when the AXI FVIP is not included.

pspin
-----

The final design is a NoC, spcl/pspin.  This design is currently only setup for
BMC, but demonstrates advanced usage of `pycode` blocks for selectively
converting asserts to assume depending on the current task.

```bash
cd pspin
# clone pspin
make pspin
# patch source
make patch
# run SBY
sby [-f] pspin_test.sby riscv-core # riscv-core, core_region, or pulp_cluster
```
