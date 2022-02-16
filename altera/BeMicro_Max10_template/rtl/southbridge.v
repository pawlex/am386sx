// 80x86 SX southbridge
// Paul Komurka
// pawlex@gmail.com

`define AM386_DEBUG
//`define RESET_FETCH

module southbridge(
	input  sys_clk,
	input  clk,				// 2x clk
	input  reset_n,		// SB reset
	output [2:0]  int,		// NMI, INTR, RESET
	inout  [2:0]  bcc,		// ADS, NA, READY (out, in, in)
	input  [3:0]  bcd,		// LOCK, MIO, DC, WR
	inout  [1:0]  arb, 	// HOLDA(ck), HOLD (out, in)
	input	 [1:0]  be, 		// H, L
	inout  [23:0] address, // bit0 = x;
	inout  [15:0] data,
	output [7:0]  status_led
	`ifdef AM386_DEBUG
	,output [15:0] debug
	`endif
);
	// INT
	wire nmi, intr, reset;
	assign int[2:0] = { nmi, intr, reset };
	assign nmi = 1'b0;
	assign intr = 1'b0;
	assign reset = ~reset_n;
	// BCC
	wire ads;
	`ifdef RESET_FETCH
	wire ready;
	assign ready = 1'b1;
	`else
	reg ready;
	`endif
	assign bcc[1:0] = { na, ready };
	assign ads = bcc[2];
	assign na = 1'b1;
	// BCD
	wire lock, mio, dc, wr;
	assign { lock, mio, dc, wr } = bcd[3:0];
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
	//wire [23:0] address_out;
	//wire [15:0] data_out;
	//wire addr_oe, data_oe;
	reg addr_oe, data_oe;
	assign address [23:1] = addr_oe ? address_ff [23:1] : 23'hzzzzzz;
	//assign address [23:1] = 24'hzzzzzz;
	//assign address [0]    = 1'b0;
	//assign data [15:0] 	 = data_oe ? data_ff    : 16'hzzzz;
	wire [15:0] data_wire; wire [15:0] ram_data;
	assign data			 = is_read 	? data_wire : 16'hzzzz;
	assign data_wire	 = is_rom 	? rom_data 	: 16'hzzzz;
	assign data_wire	 = is_ram	? ram_data	: 16'hzzzz;

`ifdef AM386_DEBUG
	//`define AM386_DEBUG_PROTOCOL
	`define AM386_DEBUG_ROM_ADDRESS
	//`define AM386_DEBUG_DATA
	
	`ifdef AM386_DEBUG_PROTOCOL
	assign debug[0] = clk;
	assign debug[1] = reset_n;
	assign debug[2] = ads;
	assign debug[3] = ready;
	assign debug[7:4] = bcd[3:0]; // { lock, mio, dc, wr }
	assign debug[9:8] = be[1:0];  // H,L
	assign debug[12:10] = { is_reset_vector, is_ram, is_rom };
	assign debug[15:13] = { is_active, is_busy, rom_clk };
	`endif
	
	`ifdef AM386_DEBUG_ROM_ADDRESS
	//assign debug[0] = clk;
	//assign debug[1] = reset_n;
	//assign debug[2] = ads;
	//assign debug[3] = ready;
	//assign debug[15:4] = address[9:1];
	assign debug[0] = clk & is_active & !is_busy & is_read & is_memory;
	assign debug[15:1] = { address[23:16],address[7:1] }; // 8 + 7 = 15
	`endif
	`ifdef AM386_DEBUG_DATA
	assign debug[0] = is_io & is_write & ~ready;
	assign debug[15:1] = data[15:1];
	`endif

`endif
	

	// BUS CYCLE PHASE
	localparam T0  = 4'b0001; // IDLE
	localparam T1  = 4'b0010; // T1
	localparam T2  = 4'b0100; // T2
	localparam T25 = 4'b1000;
	
	reg [3:0] sm_ph;
	always @(posedge clk or negedge reset_n)
	if(!reset_n) begin
		sm_ph <= T0;
	end else begin
		case(sm_ph)
			T0: if(!ads)   sm_ph <= T1;
			T1: if( ads)   sm_ph <= T2;
			T2: 				sm_ph <= T25;
			T25: if(ready) sm_ph <= T0;
		endcase
	end
//
	// 8MB of physical DRAM
	localparam DRAM_BASE = 24'h000000;
	localparam DRAM_SIZE = 24'h800000; // 0b1000_0000_0000_0000_0000_0000
	// 128K of logical ROM, phyiscally mapped top-down.
	localparam ROM_BASE  = 24'hfe0000; // 0b1111_1110_0000_0000_0000_0000
	localparam ROM_SIZE  = 18'h20000;  // 0b0000_0010_0000_0000_0000_0000

	// Address decode
	wire is_memory, is_io, is_read, is_write, is_control, is_data;
	assign is_memory 	= mio; 	assign is_io 		= ~mio;
	assign is_write 	= wr;		assign is_read 	= ~wr; 	
	assign is_data 	= dc; 	assign is_control = ~dc;
	assign is_active  = ~(ads & ready) | is_busy;
	assign is_busy		= ~sm_ph[0];
	
	
	// This needs some work
	wire is_ram = !address[23] 	& is_memory;	//  < 0x80_0000
	wire is_rom_0 = &address[23:17] & is_memory;	// => 0xfe_0000 (64k)
	wire is_rom_1 = &address[19:17] & is_memory;	//0b1_110_0000_0000_0000_0000 (0x10000, 64k)
	wire is_rom = is_rom_0 | is_rom_1;

	// Assume all transaction will be 2 byte memory reads.
	// and all we have to do is drive data and ready.
	
	// NOP LOOP FROM RESET VECTOR
	localparam JUMP_BACK_16 = 16'hEEEB;
	localparam NOP				= 16'h9090;
	localparam JMPZERO		= 16'hFEEB;
	localparam RESET_VECTOR = 24'hFF_FFF0;
	assign ram_data = JMPZERO;

	always @* begin
		case(sm_ph)
			T1: begin
				data_oe = 1;
				ready	  = 0;
			end
			T2: begin
				data_oe = 1;
				ready = 0;
			end
			T25: begin
				data_oe = 1;
				ready = 1;
			end
			default: begin
				data_oe = 0;
				ready	  = 1;
			end
		endcase
		//
		//
		case(address[23:1])
			RESET_VECTOR[23:1]: begin
				is_reset_vector=1;
				//data_ff = JMPZERO;
				data_ff = JUMP_BACK_16;
			end
			default: begin
				is_reset_vector=0;
				data_ff = NOP;
			end
		endcase
	//
	end
	reg is_reset_vector;
	
	wire is_jmp0;
	assign is_jmp0 = (data[15:0] & JMPZERO) & is_memory & is_read & ~ready;
	
	wire rv_flashy, rom_flashy, ram_flashy;
	flashy #(.TAP(6)) flashy_reset_vector
	( .reset_n(reset_n), .in(is_reset_vector), .out(rv_flashy) );
	
	flashy #(.TAP(20)) flashy_jmp0
	( .reset_n(reset_n), .in(is_jmp0), .out(jmp0_flashy) );
	
	flashy #(.TAP(20)) flashy_ram
	( .reset_n(reset_n), .in(is_ram), .out(ram_flashy) );
	
	assign status_led[3:0] = sm_ph[3:0];
	assign status_led[4] = rv_flashy;
	assign status_led[5] = jmp0_flashy;
	assign status_led[6] = ram_flashy;
	
	wire rom_clk;
	//assign rom_clk = clk & ads & is_control & is_read & is_memory & is_rom;
	assign rom_clk = clk & is_active & !is_busy & is_read & is_memory & is_rom;

	wire [15:0] rom_data;
	rom_fffc00	rom_fffc00_inst (
	.address ( address[9:1] ),
	.clock ( rom_clk ),
	.q ( { rom_data[7:0], rom_data[15:8] } )
	);
endmodule


module flashy
(
	input reset_n,
	input in,
	output out
);
	parameter TAP = 10;
	reg [TAP:0] counter_ff;
	always @(posedge in or negedge reset_n)
	if(!reset_n) begin
		counter_ff <= 0;
	end else begin
		counter_ff <= counter_ff + 1'b1;
	end
	assign out = counter_ff[TAP];
endmodule

//module dbl
//(
//	input  clk,
//	input  in,
//	output out
//);
//	reg in_ff;
//	always @(posedge clk) in_ff <= in;
//	assign out = in ^ in_ff;
//endmodule

// TEMPLATE	
//	always @(posedge clk or negedge reset_n)
//	if(!reset_n) begin
//	end else begin
//	end
//	
	

//`ifdef RESET_FETCH
//	// If working properly, LED[1:0] should go to 0b11 indicating the AM386 process tried to fetch
//	// the reset vector
//	reg [1:0] rf_state;
//	
//	always @(posedge clk or negedge reset_n)
//	if(!reset_n) begin
//		addr_oe	 	<= 0;
//		data_oe 		<= 0;
//		address_ff 	<= 0;
//		data_ff 		<= 0;
//		rf_state		<= 0;
//		//ready			<= 1;
//	end else begin
//		case(rf_state)
//			0: if(!ads) rf_state <= 1;
//			1: if(ads)  rf_state <= 2;
//			2: if(address[23:1] == RESET_VECTOR[23:1]) rf_state <= 3;
//			default: rf_state <= rf_state;
//		endcase 
//	end
	


