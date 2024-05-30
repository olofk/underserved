`default_nettype none
module rf_shift_reg
  #(parameter nr_regs = 4)
   (input wire	    i_clk,
    input wire	     i_rst,
    input wire	     i_wreq,
    input wire	     i_rreq,
    output wire	     o_ready,
    input wire [4:0] i_wreg0,
    input wire	     i_wen0,
    input wire	     i_wdata0,
    input wire [4:0] i_rreg0,
    input wire [4:0] i_rreg1,
    output wire	     o_rdata0,
    output wire	     o_rdata1);

   reg [4:0]	    cnt;

   reg [31:0]	    x [1:nr_regs];
   

   assign o_ready = i_wreq | rreq_2r;

   reg		    rreq_r;
   reg		    rreq_2r;
   reg		    rd_active;
   
   always @(posedge i_clk) begin
      rreq_r  <= i_rreq;
      rreq_2r <= rreq_r;

      if (rreq_2r | (&cnt))
	rd_active <= rreq_2r;
      if (rd_active)
	cnt <= cnt + 5'd1;

      if (i_rst) begin
	 rreq_r <= 1'b0;
	 rreq_2r <= 1'b0;
	 rd_active <= 1'b0;
	 cnt <= 5'd0;
      end
   end

   wire		    shift_en = i_wen0 | rd_active;

   wire [nr_regs:1] wr_x;
   wire [nr_regs:0] rdata;

   assign rdata[0] = 1'b0;

   genvar	    i;
   generate
      for (i = 1; i <= nr_regs ; i = i+1) begin : gen_reg_loop
	 assign wr_x[i] = i_wen0 & (i_wreg0 == i);
	 assign rdata[i] = x[i][0];
	 always @(posedge i_clk) begin
	    if (shift_en) begin
	       x[i] <= {wr_x[i] ? i_wdata0 : x[i][0], x[i][31:1]};
	    end
	 end
      end
   endgenerate

   assign o_rdata0 = rdata[i_rreg0];
   assign o_rdata1 = rdata[i_rreg1];

endmodule
`default_nettype wire
