// 80x86 SX project
// Paul Komurka
// github.com/pawlex

/*
Write/Read Cycle:
 Latch address on Rising edge of ADS

Write Cycle:
 Latch data on Rising edge of ADS

Read Cycle:
 Latch data on Falling edge of READY

Control Signals:
 Latch BHE,BLE, Address, M_IO, D_C ,W/R on Rising edge of ADS
     //output [2:0]  int,      // NMI, INTR, RESET
    //inout  [2:0]  bcc,      // ADS, NA, READY (out, in, in)
    //input  [3:0]  bcd,      // LOCK, MIO, DC, WR
    //inout  [1:0]  arb,      // HOLDA(ck), HOLD (out, in)
    //input  [1:0]  be,       // H, L
    //inout  [23:0] address,  // bit0 = x;
    //inout  [15:0] data,

*/

module busprobe(
    // We need 2 clocks.
    input clk2x,    // CPU clock ( sysclk * 2 );
    input clk4x,    // SPI clock
    input reset_n,
    input ads_b,
    input ready_b,
    //
    input [ ADDRESS_WIDTH-1 : 0 ] address_i,
    input [ DATA_WIDTH-1    : 0 ] data_i,
    input [ 1 : 0 ] BE,       // {H,L};
    input [ 2 : 0 ] control,  // { M/IO_b, D/C_b, W/R_b };
    //
    output addrl_sout,
    output addrh_sout,
    output addrx_sout,
    output datal_sout,
    output datah_sout,
    output cs_n
    );
    // Focus on memory transactions.
    `define MIO control[2]
    `define DC  control[1]
    `define WR  control[0]
    
    `define MIO_FF control_ff[2]
    `define DC_FF  control_ff[1]
    `define WR_FF  control_ff[0]

    localparam ADDRESS_WIDTH    = 24;
    localparam DATA_WIDTH       = 16;
    localparam SERIAL_WIDTH     = 8;
    
    reg [ ADDRESS_WIDTH-1 : 0 ] address_ff;
    reg [ DATA_WIDTH-1    : 0 ] wrdata_ff;
    reg [ DATA_WIDTH-1    : 0 ] rddata_ff;
    reg [ 1 : 0 ] be_ff;
    reg [ 2 : 0 ] control_ff;
    reg sample;
    
    wire mem_read;    assign mem_read    = ( `MIO    &  `WR    );
    wire mem_write;   assign mem_write   = ( `MIO    & !`WR    );
    wire mem_read_f;  assign mem_read_f  = ( `MIO_FF &  `WR_FF );
    wire mem_write_f; assign mem_write_f = ( `MIO_FF & !`WR_FF );
    
    // Latch the Write Data, Address and Control signals.
    always @(negedge clk2x or negedge reset_n) begin
        if(!reset_n) begin
            address_ff <= 24'hBEBEBE;
        end else if(mem_read | mem_write & cs_n) begin
            address_ff <= address_i;
            wrdata_ff  <= data_i;
            be_ff      <= BE;
            control_ff <= control;
        end 
    end
    
    always @(negedge clk2x or negedge reset_n) begin
        if(!reset_n) begin
            rddata_ff <= 8'hBEBE;
        end else if(mem_read_f | mem_write_f & cs_n) begin
            rddata_ff <= data_i;
        end
    end
    
    // Now we just have to determine when to store the latched data in the FIFO;
    // wire store_mem_write = !ads & mem_write;
    // wire store_mem_read  = !rea
    
    `define ADDRESS_L address_ff [7 : 0]
    `define ADDRESS_H address_ff [15: 8]
    `define ADDRESS_X address_ff [23:16]
    wire [15:0] data; assign data = mem_read_f ? rddata_ff : wrdata_ff;
    
    wire run; assign run = sample & cs_n; // New sample and not busy.
    // sampler state-machine
    always @(posedge clk2x or negedge reset_n) begin
        if(!reset_n) begin
            sample     <= 0;
        end else begin
            if( !ready_b & cs_n ) sample <= 1;
            else sample <= 0;
        end
    end
    
    // Address
    p2s #(.WIDTH(8)) p2sAddressL 
    (.clk(clk4x), .reset_n(reset_n), .d_in( `ADDRESS_L ), .run(run), .d_out(addrl_sout), .idle(cs_n) );
    p2s #(.WIDTH(8)) p2sAddressH 
    (.clk(clk4x), .reset_n(reset_n), .d_in( `ADDRESS_H ), .run(run), .d_out(addrh_sout), .idle() );
    p2s #(.WIDTH(8)) p2sAddressX 
    (.clk(clk4x), .reset_n(reset_n), .d_in( `ADDRESS_X ), .run(run), .d_out(addrx_sout), .idle() );
    // Data
    p2s #(.WIDTH(8)) DataLow 
    (.clk(clk4x), .reset_n(reset_n), .d_in( data[ 7 : 0 ] ), .run(run), .d_out(datal_sout), .idle() );
    p2s #(.WIDTH(8)) DataHigh 
    (.clk(clk4x), .reset_n(reset_n), .d_in( data[ 15: 8 ] ), .run(run), .d_out(datah_sout), .idle() );

endmodule