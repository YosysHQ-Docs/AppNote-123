import apu_package::*;

module riscv_core_wrapper
#(
    parameter int INSTR_RDATA_WIDTH         = 128,
    parameter bit CLUSTER_ALIAS             = 1'b1,
    parameter int CLUSTER_ALIAS_BASE        = 12'h1B0,
    parameter int REMAP_ADDRESS             = 0,
    parameter bit DEM_PER_BEFORE_TCDM_TS    = 1'b0,
    parameter int N_PMP_ENTRIES             = 16,
    parameter FPU               = apu_package::FPU,
    parameter SHARED_FP         = apu_package::SHARED_FP,
    parameter SHARED_DSP_MULT   = apu_package::SHARED_DSP_MULT,
    parameter SHARED_INT_DIV    = apu_package::SHARED_INT_DIV,
    parameter SHARED_FP_DIVSQRT = apu_package::SHARED_FP_DIVSQRT,
    parameter WAPUTYPE          = apu_package::WAPUTYPE
)
(
    // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
    input  logic [31:0] boot_addr_i,
    /* unused */
    input  logic [31:0] hart_id_i,

    // Instruction memory interface
    output logic        instr_req_o,
    input  logic        instr_gnt_i,
    input  logic        instr_rvalid_i,
    output logic [31:0] instr_addr_o,
    input  logic [INSTR_RDATA_WIDTH-1:0] instr_rdata_i,

    // Data memory interface
    output logic        data_req_o,
    input  logic        data_gnt_i,
    input  logic        data_rvalid_i,
    output logic        data_we_o,
    output logic [3:0]  data_be_o,
    output logic [31:0] data_addr_o,
    output logic [31:0] data_wdata_o,
    input  logic [31:0] data_rdata_i,

    output logic [5:0]  data_atop_o,
    output logic        data_buffer_o,
    output logic        data_unaligned_o,

    // apu-interconnect
    // handshake signals
    /* unused */
    // request channel
    /* unused */
    // response channel
    /* unused */

    // Interrupt inputs
    output logic        irq_ack_o,
    output logic [5:0]  irq_id_o,

    /* unused */

    // Debug Interface
    input  logic        debug_req_i,

    // CPU Control Signals
    input  logic        fetch_enable_i,
    output logic        core_busy_o,

    // PMP coonfiguration
    // NOTE: when pmp_conf_override_i is high, the pmp configuration is taken from the input
    // (i.e., pmp_addr_i and pmp_cfg_i) instead of from the CS registers.
    input  logic                            pmp_conf_override_i,
    input  logic [N_PMP_ENTRIES-1:0] [31:0] pmp_addr_i,
    input  logic [N_PMP_ENTRIES-1:0] [7:0]  pmp_cfg_i
);

    (* gclk *) reg gclk;
    reg clk = 1'b0;
    always @(posedge gclk)
        clk <= !clk;

    reg [3:0] rst_counter = 2;
    always @(posedge clk)
        if (rst_counter)
            rst_counter -= 1;

    wire rst_n = rst_counter == 0;

    logic clock_en_i = 1'b0;
    logic scan_cg_en_i = 1'b0;

    riscv_core #(
        .N_EXT_PERF_COUNTERS ( 5                    ),
        .FPU                 ( FPU                  ),
        .SHARED_FP           ( SHARED_FP            ),
        .SHARED_DSP_MULT     ( SHARED_DSP_MULT      ),
        .SHARED_INT_DIV      ( SHARED_INT_DIV       ),
        .SHARED_FP_DIVSQRT   ( SHARED_FP_DIVSQRT    ),
        .WAPUTYPE            ( WAPUTYPE             ),
        .PULP_HWLP           ( 1                    ),
        .N_PMP_ENTRIES       ( N_PMP_ENTRIES        )
    ) RISCV_CORE (
        .clk_i                 ( clk                      ),
        .rst_ni                ( rst_n                    ),

        .clock_en_i            ( clock_en_i               ),
        .scan_cg_en_i          ( scan_cg_en_i             ),

        .boot_addr_i           ( boot_addr_i              ),
        .dm_halt_addr_i        ( '0                       ),
        .hart_id_i             ( hart_id_i                ),

        .instr_req_o           ( instr_req_o              ),
        .instr_gnt_i           ( instr_gnt_i              ),
        .instr_rvalid_i        ( instr_rvalid_i           ),
        .instr_addr_o          ( instr_addr_o             ),
        .instr_rdata_i         ( instr_rdata_i            ),

        .data_req_o            ( data_req_o               ),
        .data_gnt_i            ( data_gnt_i               ),
        .data_rvalid_i         ( data_rvalid_i            ),
        .data_we_o             ( data_we_o                ),
        .data_be_o             ( data_be_o                ),
        .data_addr_o           ( data_addr_o              ),
        .data_wdata_o          ( data_wdata_o             ),
        .data_rdata_i          ( data_rdata_i             ),

        .data_atop_o           ( data_atop_o              ),
        .data_buffer_o         ( data_buffer_o            ),
        .data_unaligned_o      ( data_unaligned_o         ),

        // apu-interconnect
        // handshake signals
        .apu_master_req_o      ( /* unused */             ),
        .apu_master_ready_o    ( /* unused */             ),
        .apu_master_gnt_i      ( '0                       ),
            // request channel
        .apu_master_operands_o ( /* unused */             ),
        .apu_master_op_o       ( /* unused */             ),
        .apu_master_type_o     ( /* unused */             ),
        .apu_master_flags_o    ( /* unused */             ),
        // response channel
        .apu_master_valid_i    ( '0                       ),
        .apu_master_result_i   ( '0                       ),
        .apu_master_flags_i    ( '0                       ),

        .irq_ack_o             ( irq_ack_o                ),
        .irq_id_o              ( irq_id_o                 ),

        .irq_software_i        ( '0                       ),
        .irq_timer_i           ( '0                       ),
        .irq_external_i        ( '0                       ),
        .irq_fast_i            ( '0                       ),

        .debug_req_i           ( debug_req_i              ),

        .fetch_enable_i        ( fetch_enable_i           ),
        .core_busy_o           ( core_busy_o              ),

        .pmp_conf_override_i   ( pmp_conf_override_i      ),
        .pmp_cfg_i             ( pmp_cfg_i                ),
        .pmp_addr_i            ( pmp_addr_i               )
    );

endmodule