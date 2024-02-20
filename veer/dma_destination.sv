/*  AXI4 Formal Properties.
 *
 *  Copyright (C) 2021  Diego Hernandez <diego@yosyshq.com>
 *  Copyright (C) 2021  Sandia Corporation
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
`default_nettype none
// Connect a constraint entity
localparam amba_axi4_protocol_checker_pkg::axi4_checker_params_t
  cfg =
      '{ID_WIDTH:          `RV_DMA_BUS_TAG,
        ADDRESS_WIDTH:     32,
        DATA_WIDTH:        64,
        AWUSER_WIDTH:      1,
        WUSER_WIDTH:       1,
        BUSER_WIDTH:       1,
        ARUSER_WIDTH:      1,
        RUSER_WIDTH:       1,
	      MAX_WR_BURSTS:     16,
	      MAX_RD_BURSTS:     16,
	      MAX_WR_LENGTH:     1,
	      MAX_RD_LENGTH:     1,
        MAXWAIT:           16,
        VERIFY_AGENT_TYPE: amba_axi4_protocol_checker_pkg::DESTINATION,
        PROTOCOL_TYPE:     amba_axi4_protocol_checker_pkg::AXI4FULL,
        INTERFACE_REQS:    1,
        ENABLE_COVER:      1,
	      ENABLE_XPROP:      1,
        ARM_RECOMMENDED:   1,
        CHECK_PARAMETERS:  1,
        OPTIONAL_WSTRB:    1,
        FULL_WR_STRB:      1,
        OPTIONAL_RESET:    0,
        EXCLUSIVE_ACCESS:  1,
        OPTIONAL_LP:       0};
// Bind the YosysHQ IP to the DUT
bind veer_wrapper amba_axi4_protocol_checker
  // But first define the configuration of the YosysHQ SVA Formal IP
  #(cfg) yosyshq_axi4_full_checker_destination
    (.ACLK     (clk),
     .ARESETn  (core_rst_l),
     // Write Address Channel (AW)
     .AWID     (dma_axi_awid),
     .AWADDR   (dma_axi_awaddr),
     .AWLEN    (dma_axi_awlen),
     .AWSIZE   (dma_axi_awsize),
     .AWBURST  (dma_axi_awburst),
     .AWLOCK   (dma_axi_awlock),
     .AWCACHE  (dma_axi_awcache),
     .AWPROT   (dma_axi_awprot),
     .AWQOS    (dma_axi_awqos),
     .AWREGION (dma_axi_awregion),
     .AWUSER   (1'b0),
     .AWVALID  (dma_axi_awvalid),
     .AWREADY  (dma_axi_awready),
     // Write Data Channel (W)
     .WDATA    (dma_axi_wdata),
     .WSTRB    (dma_axi_wstrb),
     .WLAST    (dma_axi_wlast),
     .WUSER    (1'b0),
     .WVALID   (dma_axi_wvalid),
     .WREADY   (dma_axi_wready),
     // Write Response Channel (B)
     .BID      (dma_axi_bid),
     .BRESP    (dma_axi_bresp),
     .BUSER    (1'b0),
     .BVALID   (dma_axi_bvalid),
     .BREADY   (dma_axi_bready),
     // Read Address Channel (AR)
     .ARID     (dma_axi_arid),
     .ARADDR   (dma_axi_araddr),
     .ARLEN    (dma_axi_arlen),
     .ARSIZE   (dma_axi_arsize),
     .ARBURST  (dma_axi_arburst),
     .ARLOCK   (1'b0),
     .ARCACHE  (1'b0),
     .ARPROT   (dma_axi_arprot),
     .ARQOS    (1'b0),
     .ARREGION (1'b0),
     .ARUSER   (1'b0),
     .ARVALID  (dma_axi_arvalid),
     .ARREADY  (dma_axi_arready),
     // Read Data Channel (R)
     .RID      (dma_axi_rid),
     .RDATA    (dma_axi_rdata),
     .RRESP    (dma_axi_rresp),
     .RLAST    (dma_axi_rlast),
     .RUSER    (1'b0),
     .RVALID   (dma_axi_rvalid),
     .RREADY   (dma_axi_rready));
`default_nettype wire
