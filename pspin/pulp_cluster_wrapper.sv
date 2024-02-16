module pulp_cluster_wrapper
#(
  // cluster parameters
  parameter int NB_CORES            = 8,
  parameter int NB_HWACC_PORTS      = 0,
  parameter int NB_DMAS             = 4,
  parameter int TCDM_SIZE           = 256*1024,                // [B], must be 2**N
  parameter int NB_TCDM_BANKS       = 16,                      // must be 2**N
  // I$ parameters
  parameter int NB_CACHE_BANKS            = 4,
  parameter int CACHE_SIZE                = 4096,
  parameter int L2_SIZE                   = 256*1024
)
(
  input  logic                             ref_clk_i,

  input pulp_cluster_cfg_pkg::cluster_id_t cluster_id_i,
  input logic                              fetch_en_i,
  output logic                             eoc_o,
  output logic                             busy_o,

  // AXI4 SLAVE
  //***************************************
  // WRITE ADDRESS CHANNEL
  input  pulp_cluster_cfg_pkg::addr_t      data_slave_aw_addr_i,
  input  axi_pkg::prot_t                   data_slave_aw_prot_i,
  input  axi_pkg::region_t                 data_slave_aw_region_i,
  input  axi_pkg::len_t                    data_slave_aw_len_i,
  input  axi_pkg::size_t                   data_slave_aw_size_i,
  input  axi_pkg::burst_t                  data_slave_aw_burst_i,
  input  logic                             data_slave_aw_lock_i,
  input  axi_pkg::atop_t                   data_slave_aw_atop_i,
  input  axi_pkg::cache_t                  data_slave_aw_cache_i,
  input  axi_pkg::qos_t                    data_slave_aw_qos_i,
  input  pulp_cluster_cfg_pkg::id_slv_t    data_slave_aw_id_i,
  input  pulp_cluster_cfg_pkg::user_t      data_slave_aw_user_i,
  // used if ASYNC_INTF
//   input  pulp_cluster_cfg_pkg::dc_buf_t    data_slave_aw_writetoken_i,
//   output pulp_cluster_cfg_pkg::dc_buf_t    data_slave_aw_readpointer_o,
  // used if !ASYNC_INTF
  input  logic                             data_slave_aw_valid_i,
  output logic                             data_slave_aw_ready_o,

  // READ ADDRESS CHANNEL
  input  pulp_cluster_cfg_pkg::addr_t      data_slave_ar_addr_i,
  input  axi_pkg::prot_t                   data_slave_ar_prot_i,
  input  axi_pkg::region_t                 data_slave_ar_region_i,
  input  axi_pkg::len_t                    data_slave_ar_len_i,
  input  axi_pkg::size_t                   data_slave_ar_size_i,
  input  axi_pkg::burst_t                  data_slave_ar_burst_i,
  input  logic                             data_slave_ar_lock_i,
  input  axi_pkg::cache_t                  data_slave_ar_cache_i,
  input  axi_pkg::qos_t                    data_slave_ar_qos_i,
  input  pulp_cluster_cfg_pkg::id_slv_t    data_slave_ar_id_i,
  input  pulp_cluster_cfg_pkg::user_t      data_slave_ar_user_i,
  // used if ASYNC_INTF
//   input  pulp_cluster_cfg_pkg::dc_buf_t    data_slave_ar_writetoken_i,
//   output pulp_cluster_cfg_pkg::dc_buf_t    data_slave_ar_readpointer_o,
  // used if !ASYNC_INTF
  input  logic                             data_slave_ar_valid_i,
  output logic                             data_slave_ar_ready_o,

  // WRITE DATA CHANNEL
  input  pulp_cluster_cfg_pkg::data_t      data_slave_w_data_i,
  input  pulp_cluster_cfg_pkg::strb_t      data_slave_w_strb_i,
  input  pulp_cluster_cfg_pkg::user_t      data_slave_w_user_i,
  input  logic                             data_slave_w_last_i,
  // used if ASYNC_INTF
//   input  pulp_cluster_cfg_pkg::dc_buf_t    data_slave_w_writetoken_i,
//   output pulp_cluster_cfg_pkg::dc_buf_t    data_slave_w_readpointer_o,
  // used if !ASYNC_INTF
  input  logic                             data_slave_w_valid_i,
  output logic                             data_slave_w_ready_o,

  // READ DATA CHANNEL
  output pulp_cluster_cfg_pkg::data_t      data_slave_r_data_o,
  output axi_pkg::resp_t                   data_slave_r_resp_o,
  output logic                             data_slave_r_last_o,
  output pulp_cluster_cfg_pkg::id_slv_t    data_slave_r_id_o,
  output pulp_cluster_cfg_pkg::user_t      data_slave_r_user_o,
  // used if ASYNC_INTF
//   output pulp_cluster_cfg_pkg::dc_buf_t    data_slave_r_writetoken_o,
//   input  pulp_cluster_cfg_pkg::dc_buf_t    data_slave_r_readpointer_i,
  // used if !ASYNC_INTF
  output logic                             data_slave_r_valid_o,
  input  logic                             data_slave_r_ready_i,

  // WRITE RESPONSE CHANNEL
  output axi_pkg::resp_t                   data_slave_b_resp_o,
  output pulp_cluster_cfg_pkg::id_slv_t    data_slave_b_id_o,
  output pulp_cluster_cfg_pkg::user_t      data_slave_b_user_o,
  // used if ASYNC_INTF
//   output pulp_cluster_cfg_pkg::dc_buf_t    data_slave_b_writetoken_o,
//   input  pulp_cluster_cfg_pkg::dc_buf_t    data_slave_b_readpointer_i,
  // used if !ASYNC_INTF
  output logic                             data_slave_b_valid_o,
  input  logic                             data_slave_b_ready_i,

  // AXI4 MASTER
  //***************************************
  // WRITE ADDRESS CHANNEL
  output pulp_cluster_cfg_pkg::addr_t      data_master_aw_addr_o,
  output axi_pkg::prot_t                   data_master_aw_prot_o,
  output axi_pkg::region_t                 data_master_aw_region_o,
  output axi_pkg::len_t                    data_master_aw_len_o,
  output axi_pkg::size_t                   data_master_aw_size_o,
  output axi_pkg::burst_t                  data_master_aw_burst_o,
  output logic                             data_master_aw_lock_o,
  output axi_pkg::atop_t                   data_master_aw_atop_o,
  output axi_pkg::cache_t                  data_master_aw_cache_o,
  output axi_pkg::qos_t                    data_master_aw_qos_o,
  output pulp_cluster_cfg_pkg::id_mst_t    data_master_aw_id_o,
  output pulp_cluster_cfg_pkg::user_t      data_master_aw_user_o,
  // used if ASYNC_INTF
//   output pulp_cluster_cfg_pkg::dc_buf_t    data_master_aw_writetoken_o,
//   input  pulp_cluster_cfg_pkg::dc_buf_t    data_master_aw_readpointer_i,
  // used if !ASYNC_INTF
  output logic                             data_master_aw_valid_o,
  input  logic                             data_master_aw_ready_i,

  // READ ADDRESS CHANNEL
  output pulp_cluster_cfg_pkg::addr_t      data_master_ar_addr_o,
  output axi_pkg::prot_t                   data_master_ar_prot_o,
  output axi_pkg::region_t                 data_master_ar_region_o,
  output axi_pkg::len_t                    data_master_ar_len_o,
  output axi_pkg::size_t                   data_master_ar_size_o,
  output axi_pkg::burst_t                  data_master_ar_burst_o,
  output logic                             data_master_ar_lock_o,
  output axi_pkg::cache_t                  data_master_ar_cache_o,
  output axi_pkg::qos_t                    data_master_ar_qos_o,
  output pulp_cluster_cfg_pkg::id_mst_t    data_master_ar_id_o,
  output pulp_cluster_cfg_pkg::user_t      data_master_ar_user_o,
  // used if ASYNC_INTF
//   output pulp_cluster_cfg_pkg::dc_buf_t    data_master_ar_writetoken_o,
//   input  pulp_cluster_cfg_pkg::dc_buf_t    data_master_ar_readpointer_i,
  // used if !ASYNC_INTF
  output logic                             data_master_ar_valid_o,
  input  logic                             data_master_ar_ready_i,

  // WRITE DATA CHANNEL
  output pulp_cluster_cfg_pkg::data_t      data_master_w_data_o,
  output pulp_cluster_cfg_pkg::strb_t      data_master_w_strb_o,
  output pulp_cluster_cfg_pkg::user_t      data_master_w_user_o,
  output logic                             data_master_w_last_o,
  // used if ASYNC_INTF
//   output pulp_cluster_cfg_pkg::dc_buf_t    data_master_w_writetoken_o,
//   input  pulp_cluster_cfg_pkg::dc_buf_t    data_master_w_readpointer_i,
  // used if !ASYNC_INTF
  output logic                             data_master_w_valid_o,
  input  logic                             data_master_w_ready_i,

  // READ DATA CHANNEL
  input  pulp_cluster_cfg_pkg::data_t      data_master_r_data_i,
  input  axi_pkg::resp_t                   data_master_r_resp_i,
  input  logic                             data_master_r_last_i,
  input  pulp_cluster_cfg_pkg::id_mst_t    data_master_r_id_i,
  input  pulp_cluster_cfg_pkg::user_t      data_master_r_user_i,
  // used if ASYNC_INTF
//   input  pulp_cluster_cfg_pkg::dc_buf_t    data_master_r_writetoken_i,
//   output pulp_cluster_cfg_pkg::dc_buf_t    data_master_r_readpointer_o,
  // used if !ASYNC_INTF
  input  logic                             data_master_r_valid_i,
  output logic                             data_master_r_ready_o,

  // WRITE RESPONSE CHANNEL
  input  axi_pkg::resp_t                   data_master_b_resp_i,
  input  pulp_cluster_cfg_pkg::id_mst_t    data_master_b_id_i,
  input  pulp_cluster_cfg_pkg::user_t      data_master_b_user_i,
  // used if ASYNC_INTF
//   input  pulp_cluster_cfg_pkg::dc_buf_t    data_master_b_writetoken_i,
//   output pulp_cluster_cfg_pkg::dc_buf_t    data_master_b_readpointer_o,
  // used if !ASYNC_INTF
  input  logic                             data_master_b_valid_i,
  output logic                             data_master_b_ready_o,

  // AXI4 DMA MASTER
  //***************************************
  // WRITE ADDRESS CHANNEL
  output pulp_cluster_cfg_pkg::addr_t      dma_aw_addr_o,
  output axi_pkg::prot_t                   dma_aw_prot_o,
  output axi_pkg::region_t                 dma_aw_region_o,
  output axi_pkg::len_t                    dma_aw_len_o,
  output axi_pkg::size_t                   dma_aw_size_o,
  output axi_pkg::burst_t                  dma_aw_burst_o,
  output logic                             dma_aw_lock_o,
  output axi_pkg::atop_t                   dma_aw_atop_o,
  output axi_pkg::cache_t                  dma_aw_cache_o,
  output axi_pkg::qos_t                    dma_aw_qos_o,
  output pulp_cluster_cfg_pkg::id_dma_t    dma_aw_id_o,
  output pulp_cluster_cfg_pkg::user_t      dma_aw_user_o,
  output logic                             dma_aw_valid_o,
  input  logic                             dma_aw_ready_i,

  // READ ADDRESS CHANNEL
  output pulp_cluster_cfg_pkg::addr_t      dma_ar_addr_o,
  output axi_pkg::prot_t                   dma_ar_prot_o,
  output axi_pkg::region_t                 dma_ar_region_o,
  output axi_pkg::len_t                    dma_ar_len_o,
  output axi_pkg::size_t                   dma_ar_size_o,
  output axi_pkg::burst_t                  dma_ar_burst_o,
  output logic                             dma_ar_lock_o,
  output axi_pkg::cache_t                  dma_ar_cache_o,
  output axi_pkg::qos_t                    dma_ar_qos_o,
  output pulp_cluster_cfg_pkg::id_dma_t    dma_ar_id_o,
  output pulp_cluster_cfg_pkg::user_t      dma_ar_user_o,
  output logic                             dma_ar_valid_o,
  input  logic                             dma_ar_ready_i,

  // WRITE DATA CHANNEL
  output pulp_cluster_cfg_pkg::data_dma_t  dma_w_data_o,
  output pulp_cluster_cfg_pkg::strb_dma_t  dma_w_strb_o,
  output pulp_cluster_cfg_pkg::user_t      dma_w_user_o,
  output logic                             dma_w_last_o,
  output logic                             dma_w_valid_o,
  input  logic                             dma_w_ready_i,

  // READ DATA CHANNEL
  input  pulp_cluster_cfg_pkg::data_dma_t  dma_r_data_i,
  input  axi_pkg::resp_t                   dma_r_resp_i,
  input  logic                             dma_r_last_i,
  input  pulp_cluster_cfg_pkg::id_dma_t    dma_r_id_i,
  input  pulp_cluster_cfg_pkg::user_t      dma_r_user_i,
  input  logic                             dma_r_valid_i,
  output logic                             dma_r_ready_o,

  // WRITE RESPONSE CHANNEL
  input  axi_pkg::resp_t                   dma_b_resp_i,
  input  pulp_cluster_cfg_pkg::id_dma_t    dma_b_id_i,
  input  pulp_cluster_cfg_pkg::user_t      dma_b_user_i,
  input  logic                             dma_b_valid_i,
  output logic                             dma_b_ready_o,

  // AXI4 NIC-HOST-Interconnect (NHI) SLAVE
  //***************************************
  // WRITE ADDRESS CHANNEL
  input  pulp_cluster_cfg_pkg::addr_t      nhi_aw_addr_i,
  input  axi_pkg::prot_t                   nhi_aw_prot_i,
  input  axi_pkg::region_t                 nhi_aw_region_i,
  input  axi_pkg::len_t                    nhi_aw_len_i,
  input  axi_pkg::size_t                   nhi_aw_size_i,
  input  axi_pkg::burst_t                  nhi_aw_burst_i,
  input  logic                             nhi_aw_lock_i,
  input  axi_pkg::atop_t                   nhi_aw_atop_i,
  input  axi_pkg::cache_t                  nhi_aw_cache_i,
  input  axi_pkg::qos_t                    nhi_aw_qos_i,
  input  pulp_cluster_cfg_pkg::id_dma_t    nhi_aw_id_i,
  input  pulp_cluster_cfg_pkg::user_t      nhi_aw_user_i,
  input  logic                             nhi_aw_valid_i,
  output logic                             nhi_aw_ready_o,

  // READ ADDRESS CHANNEL
  input  pulp_cluster_cfg_pkg::addr_t      nhi_ar_addr_i,
  input  axi_pkg::prot_t                   nhi_ar_prot_i,
  input  axi_pkg::region_t                 nhi_ar_region_i,
  input  axi_pkg::len_t                    nhi_ar_len_i,
  input  axi_pkg::size_t                   nhi_ar_size_i,
  input  axi_pkg::burst_t                  nhi_ar_burst_i,
  input  logic                             nhi_ar_lock_i,
  input  axi_pkg::cache_t                  nhi_ar_cache_i,
  input  axi_pkg::qos_t                    nhi_ar_qos_i,
  input  pulp_cluster_cfg_pkg::id_dma_t    nhi_ar_id_i,
  input  pulp_cluster_cfg_pkg::user_t      nhi_ar_user_i,
  input  logic                             nhi_ar_valid_i,
  output logic                             nhi_ar_ready_o,

  // WRITE DATA CHANNEL
  input  pulp_cluster_cfg_pkg::data_dma_t  nhi_w_data_i,
  input  pulp_cluster_cfg_pkg::strb_dma_t  nhi_w_strb_i,
  input  pulp_cluster_cfg_pkg::user_t      nhi_w_user_i,
  input  logic                             nhi_w_last_i,
  input  logic                             nhi_w_valid_i,
  output logic                             nhi_w_ready_o,

  // READ DATA CHANNEL
  output pulp_cluster_cfg_pkg::data_dma_t  nhi_r_data_o,
  output axi_pkg::resp_t                   nhi_r_resp_o,
  output logic                             nhi_r_last_o,
  output pulp_cluster_cfg_pkg::id_dma_t    nhi_r_id_o,
  output pulp_cluster_cfg_pkg::user_t      nhi_r_user_o,
  output logic                             nhi_r_valid_o,
  input  logic                             nhi_r_ready_i,

  // WRITE RESPONSE CHANNEL
  output axi_pkg::resp_t                   nhi_b_resp_o,
  output pulp_cluster_cfg_pkg::id_dma_t    nhi_b_id_o,
  output pulp_cluster_cfg_pkg::user_t      nhi_b_user_o,
  output logic                             nhi_b_valid_o,
  input  logic                             nhi_b_ready_i,

  // Instruction Cache Master Port
  output pulp_cluster_cfg_pkg::addr_t         icache_aw_addr_o,
  output axi_pkg::prot_t                      icache_aw_prot_o,
  output axi_pkg::region_t                    icache_aw_region_o,
  output axi_pkg::len_t                       icache_aw_len_o,
  output axi_pkg::size_t                      icache_aw_size_o,
  output axi_pkg::burst_t                     icache_aw_burst_o,
  output logic                                icache_aw_lock_o,
  output axi_pkg::atop_t                      icache_aw_atop_o,
  output axi_pkg::cache_t                     icache_aw_cache_o,
  output axi_pkg::qos_t                       icache_aw_qos_o,
  output pulp_cluster_cfg_pkg::id_icache_t    icache_aw_id_o,
  output pulp_cluster_cfg_pkg::user_t         icache_aw_user_o,
  output logic                                icache_aw_valid_o,
  input  logic                                icache_aw_ready_i,

  output pulp_cluster_cfg_pkg::addr_t         icache_ar_addr_o,
  output axi_pkg::prot_t                      icache_ar_prot_o,
  output axi_pkg::region_t                    icache_ar_region_o,
  output axi_pkg::len_t                       icache_ar_len_o,
  output axi_pkg::size_t                      icache_ar_size_o,
  output axi_pkg::burst_t                     icache_ar_burst_o,
  output logic                                icache_ar_lock_o,
  output axi_pkg::cache_t                     icache_ar_cache_o,
  output axi_pkg::qos_t                       icache_ar_qos_o,
  output pulp_cluster_cfg_pkg::id_icache_t    icache_ar_id_o,
  output pulp_cluster_cfg_pkg::user_t         icache_ar_user_o,
  output logic                                icache_ar_valid_o,
  input  logic                                icache_ar_ready_i,

  output pulp_cluster_cfg_pkg::data_icache_t  icache_w_data_o,
  output pulp_cluster_cfg_pkg::strb_icache_t  icache_w_strb_o,
  output pulp_cluster_cfg_pkg::user_t         icache_w_user_o,
  output logic                                icache_w_last_o,
  output logic                                icache_w_valid_o,
  input  logic                                icache_w_ready_i,

  input  pulp_cluster_cfg_pkg::data_icache_t  icache_r_data_i,
  input  axi_pkg::resp_t                      icache_r_resp_i,
  input  logic                                icache_r_last_i,
  input  pulp_cluster_cfg_pkg::id_icache_t    icache_r_id_i,
  input  pulp_cluster_cfg_pkg::user_t         icache_r_user_i,
  input  logic                                icache_r_valid_i,
  output logic                                icache_r_ready_o,

  input  axi_pkg::resp_t                      icache_b_resp_i,
  input  pulp_cluster_cfg_pkg::id_icache_t    icache_b_id_i,
  input  pulp_cluster_cfg_pkg::user_t         icache_b_user_i,
  input  logic                                icache_b_valid_i,
  output logic                                icache_b_ready_o,

  //task from scheduler
  input  logic                                task_valid_i,
  output logic                                task_ready_o,
  input  pspin_cfg_pkg::handler_task_t            task_descr_i,

  //feedback to scheduler
  output logic                                feedback_valid_o,
  input  logic                                feedback_ready_i,
  output pspin_cfg_pkg::feedback_descr_t          feedback_o,

  //signal if the cluster is ready to accept tasks
  output logic                                cluster_active_o,

  //commands out
  input  logic                                cmd_ready_i,
  output logic                                cmd_valid_o,
  output pspin_cfg_pkg::pspin_cmd_t               cmd_o,

  //command response
  input  logic                                cmd_resp_valid_i,
  input  pspin_cfg_pkg::pspin_cmd_resp_t          cmd_resp_i
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

pulp_cluster #(
    .ASYNC_INTF               (0),
    .NB_CORES                 (NB_CORES),
    .NB_HWACC_PORTS           (NB_HWACC_PORTS),
    .NB_DMAS                  (NB_DMAS),
    .CLUSTER_ALIAS            (1'b1),
    .CLUSTER_ALIAS_BASE       (12'h1B0),
    .TCDM_SIZE                (TCDM_SIZE),
    .NB_TCDM_BANKS            (NB_TCDM_BANKS),
    .XNE_PRESENT              (1'b0),
    // I$ Parameters
    .NB_CACHE_BANKS           (NB_CACHE_BANKS),
    .CACHE_SIZE               (CACHE_SIZE),
    .L2_SIZE                  (L2_SIZE),
    // Core Parameters
    .DEM_PER_BEFORE_TCDM_TS   (1'b0),
    .ROM_BOOT_ADDR            (32'h1A00_0000),
    .BOOT_ADDR                (32'h1D00_0080),
    // AXI Parameters
    .AXI_ADDR_WIDTH           (pulp_cluster_cfg_pkg::AXI_AW),
    .AXI_DATA_C2S_WIDTH       (pulp_cluster_cfg_pkg::AXI_DW),
    .AXI_DATA_S2C_WIDTH       (pulp_cluster_cfg_pkg::AXI_DW),
    .AXI_USER_WIDTH           (pulp_cluster_cfg_pkg::AXI_UW),
    .AXI_ID_IN_WIDTH          (pulp_cluster_cfg_pkg::AXI_IW_SLV),
    .AXI_ID_OUT_WIDTH         (pulp_cluster_cfg_pkg::AXI_IW_MST),
    .DC_SLICE_BUFFER_WIDTH    (pulp_cluster_cfg_pkg::DC_BUF_W),
    // TCDM and Interconnect Parameters
    .DATA_WIDTH               (32),
    .ADDR_WIDTH               (32),
    .TEST_SET_BIT             (20),
    // DMA Parameters
    .NB_OUTSND_BURSTS         (pulp_cluster_cfg_pkg::DMA_MAX_N_TXNS),
    .MCHAN_BURST_LENGTH       (pulp_cluster_cfg_pkg::DMA_MAX_BURST_SIZE)
) pulp_cluster_i (
    .clk_i          (clk),
    .rst_ni         (rst_n),
    .ref_clk_i,

    .pmu_mem_pwdn_i               (1'b0),
    .base_addr_i                  ('0),
    .test_mode_i                  ('0),
    .en_sa_boot_i                 ('0),

    .cluster_id_i,

    .fetch_en_i,
    .eoc_o,
    .busy_o,

    .ext_events_writetoken_i      ('0),
    .ext_events_readpointer_o     (),
    .ext_events_dataasync_i       ('0),
    .dma_pe_evt_ack_i             ('0),
    .dma_pe_evt_valid_o           (),
    .dma_pe_irq_ack_i             ('0),
    .dma_pe_irq_valid_o           (),
    .pf_evt_ack_i                 ('0),
    .pf_evt_valid_o               (),

    .data_slave_aw_addr_i,
    .data_slave_aw_prot_i,
    .data_slave_aw_region_i,
    .data_slave_aw_len_i,
    .data_slave_aw_size_i,
    .data_slave_aw_burst_i,
    .data_slave_aw_lock_i,
    .data_slave_aw_atop_i,
    .data_slave_aw_cache_i,
    .data_slave_aw_qos_i,
    .data_slave_aw_id_i,
    .data_slave_aw_user_i,
    .data_slave_aw_writetoken_i (),
    .data_slave_aw_readpointer_o (),
    .data_slave_aw_valid_i,
    .data_slave_aw_ready_o,
    .data_slave_ar_addr_i,
    .data_slave_ar_prot_i,
    .data_slave_ar_region_i,
    .data_slave_ar_len_i,
    .data_slave_ar_size_i,
    .data_slave_ar_burst_i,
    .data_slave_ar_lock_i,
    .data_slave_ar_cache_i,
    .data_slave_ar_qos_i,
    .data_slave_ar_id_i,
    .data_slave_ar_user_i,
    .data_slave_ar_writetoken_i (),
    .data_slave_ar_readpointer_o (),
    .data_slave_ar_valid_i,
    .data_slave_ar_ready_o,
    .data_slave_w_data_i,
    .data_slave_w_strb_i,
    .data_slave_w_user_i,
    .data_slave_w_last_i,
    .data_slave_w_writetoken_i (),
    .data_slave_w_readpointer_o (),
    .data_slave_w_valid_i,
    .data_slave_w_ready_o,
    .data_slave_r_data_o,
    .data_slave_r_resp_o,
    .data_slave_r_last_o,
    .data_slave_r_id_o,
    .data_slave_r_user_o,
    .data_slave_r_writetoken_o (),
    .data_slave_r_readpointer_i (),
    .data_slave_r_valid_o,
    .data_slave_r_ready_i,
    .data_slave_b_resp_o,
    .data_slave_b_id_o,
    .data_slave_b_user_o,
    .data_slave_b_writetoken_o (),
    .data_slave_b_readpointer_i (),
    .data_slave_b_valid_o,
    .data_slave_b_ready_i,

    .data_master_aw_addr_o,
    .data_master_aw_prot_o,
    .data_master_aw_region_o,
    .data_master_aw_len_o,
    .data_master_aw_size_o,
    .data_master_aw_burst_o,
    .data_master_aw_lock_o,
    .data_master_aw_atop_o,
    .data_master_aw_cache_o,
    .data_master_aw_qos_o,
    .data_master_aw_id_o,
    .data_master_aw_user_o,
    .data_master_aw_writetoken_o (),
    .data_master_aw_readpointer_i (),
    .data_master_aw_valid_o,
    .data_master_aw_ready_i,
    .data_master_ar_addr_o,
    .data_master_ar_prot_o,
    .data_master_ar_region_o,
    .data_master_ar_len_o,
    .data_master_ar_size_o,
    .data_master_ar_burst_o,
    .data_master_ar_lock_o,
    .data_master_ar_cache_o,
    .data_master_ar_qos_o,
    .data_master_ar_id_o,
    .data_master_ar_user_o,
    .data_master_ar_writetoken_o (),
    .data_master_ar_readpointer_i (),
    .data_master_ar_valid_o,
    .data_master_ar_ready_i,
    .data_master_w_data_o,
    .data_master_w_strb_o,
    .data_master_w_user_o,
    .data_master_w_last_o,
    .data_master_w_writetoken_o (),
    .data_master_w_readpointer_i (),
    .data_master_w_valid_o,
    .data_master_w_ready_i,
    .data_master_r_data_i,
    .data_master_r_resp_i,
    .data_master_r_last_i,
    .data_master_r_id_i,
    .data_master_r_user_i,
    .data_master_r_writetoken_i (),
    .data_master_r_readpointer_o (),
    .data_master_r_valid_i,
    .data_master_r_ready_o,
    .data_master_b_resp_i,
    .data_master_b_id_i,
    .data_master_b_user_i,
    .data_master_b_writetoken_i (),
    .data_master_b_readpointer_o (),
    .data_master_b_valid_i,
    .data_master_b_ready_o,

    .dma_aw_addr_o,
    .dma_aw_prot_o,
    .dma_aw_region_o,
    .dma_aw_len_o,
    .dma_aw_size_o,
    .dma_aw_burst_o,
    .dma_aw_lock_o,
    .dma_aw_atop_o,
    .dma_aw_cache_o   (),
    .dma_aw_qos_o,
    .dma_aw_id_o,
    .dma_aw_user_o,
    .dma_aw_valid_o,
    .dma_aw_ready_i,
    .dma_ar_addr_o,
    .dma_ar_prot_o,
    .dma_ar_region_o,
    .dma_ar_len_o,
    .dma_ar_size_o,
    .dma_ar_burst_o,
    .dma_ar_lock_o,
    .dma_ar_cache_o   (),
    .dma_ar_qos_o,
    .dma_ar_id_o,
    .dma_ar_user_o,
    .dma_ar_valid_o,
    .dma_ar_ready_i,
    .dma_w_data_o,
    .dma_w_strb_o,
    .dma_w_user_o,
    .dma_w_last_o,
    .dma_w_valid_o,
    .dma_w_ready_i,
    .dma_r_data_i,
    .dma_r_resp_i,
    .dma_r_last_i,
    .dma_r_id_i,
    .dma_r_user_i,
    .dma_r_valid_i,
    .dma_r_ready_o,
    .dma_b_resp_i,
    .dma_b_id_i,
    .dma_b_user_i,
    .dma_b_valid_i,
    .dma_b_ready_o,

    .nhi_aw_addr_i,
    .nhi_aw_prot_i,
    .nhi_aw_region_i,
    .nhi_aw_len_i,
    .nhi_aw_size_i,
    .nhi_aw_burst_i,
    .nhi_aw_lock_i,
    .nhi_aw_atop_i,
    .nhi_aw_cache_i,
    .nhi_aw_qos_i,
    .nhi_aw_id_i,
    .nhi_aw_user_i,
    .nhi_aw_valid_i,
    .nhi_aw_ready_o,
    .nhi_ar_addr_i,
    .nhi_ar_prot_i,
    .nhi_ar_region_i,
    .nhi_ar_len_i,
    .nhi_ar_size_i,
    .nhi_ar_burst_i,
    .nhi_ar_lock_i,
    .nhi_ar_cache_i,
    .nhi_ar_qos_i,
    .nhi_ar_id_i,
    .nhi_ar_user_i,
    .nhi_ar_valid_i,
    .nhi_ar_ready_o,
    .nhi_w_data_i,
    .nhi_w_strb_i,
    .nhi_w_user_i,
    .nhi_w_last_i,
    .nhi_w_valid_i,
    .nhi_w_ready_o,
    .nhi_r_data_o,
    .nhi_r_resp_o,
    .nhi_r_last_o,
    .nhi_r_id_o,
    .nhi_r_user_o,
    .nhi_r_valid_o,
    .nhi_r_ready_i,
    .nhi_b_resp_o,
    .nhi_b_id_o,
    .nhi_b_user_o,
    .nhi_b_valid_o,
    .nhi_b_ready_i,

    .icache_aw_addr_o,
    .icache_aw_prot_o,
    .icache_aw_region_o,
    .icache_aw_len_o,
    .icache_aw_size_o,
    .icache_aw_burst_o,
    .icache_aw_lock_o,
    .icache_aw_atop_o,
    .icache_aw_cache_o,
    .icache_aw_qos_o,
    .icache_aw_id_o,
    .icache_aw_user_o,
    .icache_aw_valid_o,
    .icache_aw_ready_i,
    .icache_ar_addr_o,
    .icache_ar_prot_o,
    .icache_ar_region_o,
    .icache_ar_len_o,
    .icache_ar_size_o,
    .icache_ar_burst_o,
    .icache_ar_lock_o,
    .icache_ar_cache_o,
    .icache_ar_qos_o,
    .icache_ar_id_o,
    .icache_ar_user_o,
    .icache_ar_valid_o,
    .icache_ar_ready_i,
    .icache_w_data_o,
    .icache_w_strb_o,
    .icache_w_user_o,
    .icache_w_last_o,
    .icache_w_valid_o,
    .icache_w_ready_i,
    .icache_r_data_i,
    .icache_r_resp_i,
    .icache_r_last_i,
    .icache_r_id_i,
    .icache_r_user_i,
    .icache_r_valid_i,
    .icache_r_ready_o,
    .icache_b_resp_i,
    .icache_b_id_i,
    .icache_b_user_i,
    .icache_b_valid_i,
    .icache_b_ready_o,

    .task_valid_i,
    .task_ready_o,
    .task_descr_i,
    .feedback_valid_o,
    .feedback_ready_i,
    .feedback_o,
    .cluster_active_o,
    .cmd_ready_i,
    .cmd_valid_o,
    .cmd_o,
    .cmd_resp_valid_i,
    .cmd_resp_i
);

endmodule