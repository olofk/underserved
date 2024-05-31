/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
/* verilator lint_off UNUSEDSIGNAL */

module tt_um_underserved (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  assign uio_out = 0;
  assign uio_oe  = 0;

   wire [31:0] 	wb_ibus_adr;
   wire 	wb_ibus_stb;

   wire [31:0] 	wb_mem_adr;
   wire 	wb_mem_ack;
   wire [31:0] 	wb_mem_rdt;

   wire [31:0] 	wb_dbus_adr;
   wire [31:0] 	wb_dbus_dat;
   wire 	wb_dbus_we;
   wire 	wb_dbus_stb;
   wire 	wb_gpio_ack;
   
   wire		rf_wreq;
   wire		rf_rreq;
   wire [4:0]	wreg0;
   wire		wen0;
   wire		wdata0;
   wire [4:0]	rreg0;
   wire [4:0]	rreg1;
   wire		rf_ready;
   wire		rdata0;
   wire		rdata1;

   rf_shift_reg
     #(.nr_regs (5))
   rf_shift_reg
     (.i_clk    (clk),
      .i_rst    (!rst_n),
      //RF IF
      .i_wreq   (rf_wreq),
      .i_rreq   (rf_rreq),
      .o_ready  (rf_ready),
      .i_wreg0  (wreg0),
      .i_wen0   (wen0),
      .i_wdata0 (wdata0),
      .i_rreg0  (rreg0),
      .i_rreg1  (rreg1),
      .o_rdata0 (rdata0),
      .o_rdata1 (rdata1));

   serv_top
     #(
       .WITH_CSR       (1'b0),
       .PRE_REGISTER   (1'b1),
       .RESET_STRATEGY ("MINI"),
       .RESET_PC       (32'd0),
       .MDU            (1'b0),
       .COMPRESSED     (1'b0))
   cpu
     (
      .clk         (clk),
      .i_rst       (!rst_n),
      .i_timer_irq (1'b0),

      //RF IF
      .o_rf_rreq   (rf_rreq),
      .o_rf_wreq   (rf_wreq),
      .i_rf_ready  (rf_ready),
      .o_wreg0     (wreg0),
      .o_wreg1     (),
      .o_wen0      (wen0),
      .o_wen1      (),
      .o_wdata0    (wdata0),
      .o_wdata1    (),
      .o_rreg0     (rreg0),
      .o_rreg1     (rreg1),
      .i_rdata0    (rdata0),
      .i_rdata1    (rdata1),

      //Instruction bus
      .o_ibus_adr  (wb_ibus_adr),
      .o_ibus_cyc  (wb_ibus_stb),
      .i_ibus_rdt  (wb_mem_rdt),
      .i_ibus_ack  (wb_mem_ack & wb_ibus_stb),

      //Data bus
      .o_dbus_adr  (wb_dbus_adr),
      .o_dbus_dat  (wb_dbus_dat),
      .o_dbus_sel  (),
      .o_dbus_we   (wb_dbus_we),
      .o_dbus_cyc  (wb_dbus_stb),
      .i_dbus_rdt  (wb_mem_rdt),
      .i_dbus_ack  (wb_dbus_we ? wb_gpio_ack : (wb_mem_ack & wb_dbus_stb)),

      //Extension IF
      .o_ext_rs1    (),
      .o_ext_rs2    (),
      .o_ext_funct3 (),
      .i_ext_rd     (32'd0),
      .i_ext_ready  (1'b0),
      //MDU
      .o_mdu_valid  ());

   subservient_gpio gpio
     (.i_wb_clk (clk),
      .i_wb_rst (!rst_n),
      .i_wb_dat (wb_dbus_dat[4:0]),
      .i_wb_we  (wb_dbus_we),
      .i_wb_stb (wb_dbus_stb & wb_dbus_we),
      .o_wb_rdt (),
      .o_wb_ack (wb_gpio_ack),
      .o_gpio   (uo_out[4:0]));

   assign wb_mem_adr = wb_ibus_stb ? wb_ibus_adr : wb_dbus_adr;

   spimemio dut
     (
      .clk (clk),
      .resetn (rst_n),

      .valid (wb_ibus_stb | (wb_dbus_stb & !wb_dbus_we)),
      .ready (wb_mem_ack),
      .addr  (wb_mem_adr[23:0]),
      .rdata (wb_mem_rdt),

      .flash_csb (uo_out[6]),
      .flash_clk (uo_out[5]),

      .flash_io0_oe (),
      .flash_io1_oe (),
      .flash_io2_oe (),
      .flash_io3_oe (),

      .flash_io0_do (uo_out[7]), //mosi
      .flash_io1_do (),
      .flash_io2_do (),
      .flash_io3_do (),

      .flash_io0_di (1'b0),
      .flash_io1_di (ui_in[7]),
      .flash_io2_di (1'b0),
      .flash_io3_di (1'b0),

      .cfgreg_we (4'd0),
      .cfgreg_di (32'd0),
      .cfgreg_do ());

endmodule
