module core_region_wrapper
#(
    // CORE PARAMETERS
    parameter int     INSTR_RDATA_WIDTH       = 32,
    parameter bit     CLUSTER_ALIAS           = 1'b1,
    parameter int     CLUSTER_ALIAS_BASE      = 12'h000,
    parameter int     REMAP_ADDRESS           = 0,
    parameter bit     DEM_PER_BEFORE_TCDM_TS  = 1'b0,
    parameter int     N_PMP_ENTRIES           = 16
) (
    input logic         init_ni,

    input logic [3:0]   base_addr_i, // FOR CLUSTER VIRTUALIZATION

    input logic [5:0]   cluster_id_i,

    input logic         irq_req_i,
    output logic        irq_ack_o,
    input logic [4:0]   irq_id_i,
    output logic [4:0]  irq_ack_id_o,

    input logic         clock_en_i,
    input logic         fetch_en_i,
    input logic         fregfile_disable_i,

    input logic [31:0]  boot_addr_i,

    input logic         test_mode_i,

    output logic        core_busy_o,

    // Interface to Instruction Logarithmic interconnect (Req->grant handshake)
    output logic        instr_req_o,
    input logic         instr_gnt_i,
    output logic [31:0] instr_addr_o,
    input logic [INSTR_RDATA_WIDTH-1:0] instr_r_rdata_i,
    input logic         instr_r_valid_i,

    XBAR_TCDM_BUS.Slave debug_bus,
    output logic        debug_core_halted_o,
    input logic         debug_core_halt_i,
    input logic         debug_core_resume_i,

    output logic        unaligned_o,

    // Interface for DEMUX to TCDM INTERCONNECT ,PERIPHERAL INTERCONNECT and DMA CONTROLLER
    XBAR_TCDM_BUS.Master    tcdm_data_master,
    output logic [5:0]      tcdm_data_master_atop,
    XBAR_TCDM_BUS.Master    dma_ctrl_master,
    XBAR_PERIPH_BUS.Master  eu_ctrl_master,
    XBAR_PERIPH_BUS.Master  periph_data_master,
    output logic [5:0]      periph_data_master_atop,

    XBAR_PERIPH_BUS.Slave   this_fifo_slave,
    XBAR_PERIPH_BUS.Master  next_fifo_master,

    XBAR_PERIPH_BUS.Master  hpu_driver_master,

    // APU interconnect interface
    cpu_marx_if.cpu apu_master,

    //interface for configuring PMP from external
    input  logic pmp_conf_override_i,
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

core_region #(
    .CORE_ID                   ( 0                      ),
    .ADDR_WIDTH                ( 32                     ),
    .DATA_WIDTH                ( 32                     ),
    .INSTR_RDATA_WIDTH         ( INSTR_RDATA_WIDTH      ),
    .CLUSTER_ALIAS             ( CLUSTER_ALIAS          ),
    .CLUSTER_ALIAS_BASE        ( CLUSTER_ALIAS_BASE     ),
    .REMAP_ADDRESS             ( REMAP_ADDRESS          ),
    .DEM_PER_BEFORE_TCDM_TS    ( DEM_PER_BEFORE_TCDM_TS ),
    .INTER_CORE_FIFO_DEPTH     ( 32                     ),
    .N_PMP_ENTRIES             ( N_PMP_ENTRIES          )
) core_region_i (
    .clk_i                    ( clk                     ),
    .rst_ni                   ( rst_n                   ),
    .base_addr_i              ( base_addr_i             ),
    .init_ni                  ( init_ni                 ),
    .cluster_id_i             ( cluster_id_i            ),
    .clock_en_i               ( clock_en_i              ),
    .fetch_en_i               ( fetch_en_i              ),
    .fregfile_disable_i       ( fregfile_disable_i      ),
    .boot_addr_i              ( boot_addr_i             ),
    .irq_id_i                 ( irq_id_i                ),
    .irq_ack_id_o             ( irq_ack_id_o            ),
    .irq_req_i                ( irq_req_i               ),
    .irq_ack_o                ( irq_ack_o               ),

    .test_mode_i              ( test_mode_i             ),
    .core_busy_o              ( core_busy_o             ),
    .instr_req_o              ( instr_req_o             ),
    .instr_gnt_i              ( instr_gnt_i             ),
    .instr_addr_o             ( instr_addr_o            ),
    .instr_r_rdata_i          ( instr_r_rdata_i         ),
    .instr_r_valid_i          ( instr_r_valid_i         ),
    .debug_bus                ( debug_bus               ),
    .debug_core_halted_o      ( debug_core_halted_o     ),
    .debug_core_halt_i        ( debug_core_halt_i       ),
    .debug_core_resume_i      ( debug_core_resume_i     ),
    .unaligned_o              ( unaligned_o             ),
    .tcdm_data_master         ( tcdm_data_master        ),
    .tcdm_data_master_atop    ( tcdm_data_master_atop   ),
    .dma_ctrl_master          ( dma_ctrl_master         ),
    .eu_ctrl_master           ( eu_ctrl_master          ),
    .periph_data_master       ( periph_data_master      ),
    .periph_data_master_atop  ( periph_data_master_atop ),
    .this_fifo_slave          ( this_fifo_slave         ),
    .next_fifo_master         ( next_fifo_master        ),
    .hpu_driver_master        ( hpu_driver_master       ),
    .apu_master               ( apu_master              ),

    .pmp_conf_override_i      ( pmp_conf_override_i     ),
    .pmp_cfg_i                ( pmp_cfg_i               ),
    .pmp_addr_i               ( pmp_addr_i              )
);
endmodule