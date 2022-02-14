
module southbridge(
	input  clk,				// 2x clk
	input  reset_n,		// SB reset
	output [2:0] int,		// NMI, INTR, RESET
	inout  [2:0] bcc,		// ADS, NA, READY (out, in, in)
	input  [3:0] bcd,		// LOCK, MIO, DC, WR
	inout  [1:0] arb, 	// HOLDA(ck), HOLD (out, in)
	input	 [1:0] be, 		// H, L
	inout  [23:0] address, // bit0 = x;
	inout  [15:0] data,
	//`ifdef AUX
	//output [3:0] aux, 	// ERROR, BUSY, PEREQ, FLOAT (input)
	//`endif
	//`ifdef SMI
	////TBD
	//`endif
	//`ifdef DEBUG
	//output [15:0] debug,
	//`endif
	////
	output [7:0] status_led
	//
);

	// INT
	wire nmi, intr, reset;
	assign int[2:0] = { nmi, intr, reset };
	assign nmi = 1'b0;
	assign intr = 1'b0;
	assign reset = ~reset_n;
	// BCC
	wire ads, na, ready;
	assign bcc[1:0] = { na, ready };
	assign ads = bcc[2];
	assign na = 1'b1;
	assign ready = 1'b1;
	// BCD
	wire lock, mio, dc, wr;
	assign { lock,mio, dc, wr } = bcd[3:0];
	// ARB
	wire holda, hold;
	assign holda = arb[1];
	assign arb[0] = hold;
	assign hold = 1'b0;
	// BE
	wire beh, bel;
	assign { beh, bel } = be[1:0];
	// ADDR/DATA
	reg [23:0] address_ff;
	reg [15:0] data_ff;
	reg addr_oe, data_oe;
	assign address [23:0] = addr_oe ? address_ff : 24'hzzzzzz;
	assign data [15:0] 	 = data_oe ? data_ff    : 16'hzzzz;

	////
	localparam RESET_VECTOR = 24'hFF_FFFF_FFF0;
	reg [3:0] state;
	
	always @(posedge clk or negedge reset_n)
	if(!reset_n) begin
		addr_oe	 	<= 0;
		data_oe 		<= 0;
		address_ff 	<= 0;
		data_ff 		<= 0;
		state 		<= 0;
	end else begin
		case(state)
			0: if(!ads) state <= 1;
			1: if(ads)  state <= 2;
			2: if(address[23:1] == RESET_VECTOR[23:1]) state <= 3;
			default: state <= state;
		endcase 
	end
	
	assign status_led[1:0] = state [1:0];
	assign status_led[3:2] = { holda, hold };
	
endmodule