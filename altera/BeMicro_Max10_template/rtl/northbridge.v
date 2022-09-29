// 80x86 SX northbridge
// Paul Komurka
// github.com/pawlex

`define AM386_DEBUG

module northbridge(
    input  clk,             // 2x clk
    input  reset_n,         // SB reset
    output [2:0]  int,      // NMI, INTR, RESET
    inout  [2:0]  bcc,      // ADS, NA, READY (out, in, in)
    input  [3:0]  bcd,      // LOCK, MIO, DC, WR
    inout  [1:0]  arb,      // HOLDA(ck), HOLD (out, in)
    input  [1:0]  be,       // H, L
    inout  [23:0] address,  // bit0 = x;
    inout  [15:0] data,
    output [7:0]  status_led,
    output [15:0] debug,
    // SDRAM INTERFACE
    output [21:0] az_addr,//    (address_ff[23:1]),//22
    output [1:0]  az_be_n,//    ({beh_ff, bel_ff}),//2
    output [15:0] az_data,//    (data_ff),//16
    output reg az_rd_n,//   (!is_read),
    output reg az_wr_n,//   (!is_write),
    
    input [15:0] za_data,
    input za_valid,
    input za_waitrequest
);
    // RAM
    wire ram_valid, ram_wait_req;
    wire [15:0] ram_data;
    assign ram_valid = za_valid;
    assign ram_wait_req = za_waitrequest;
    assign ram_data = za_data;
    assign az_addr = address_ff[22:1];
    assign az_be_n = { beh_ff, bel_ff };
    assign az_data = data_ff;
    // INT
    wire nmi, intr, reset;
    assign int[2:0] = { nmi, intr, reset };
    assign nmi = 1'b0;
    assign intr = 1'b0;
    assign reset = ~reset_n;
    // BCC
    wire ads,ready;
    assign bcc[1:0] = { na, ready };
    assign ads = bcc[2];
    assign na = 1'b1; // active low, Next Address / pipeline?
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
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // LAI DEBUG ASSIGNMENTS

`ifdef AM386_DEBUG
    `define AM386_DEBUG_PROTOCOL
    //`define AM386_DEBUG_ROM_ADDRESS
    //`define AM386_DEBUG_DATA
    //`define AM386_DEBUG_RAM_ADDRESS
    
    `ifdef AM386_DEBUG_PROTOCOL
    assign debug[0] = clk;
    assign debug[1] = reset_n;
    assign debug[3:2] = {ready, ads};
    //assign debug[3:2] = {az_rd_n, az_wr_n};
    assign debug[6:4] = bcd[2:0]; // { mio, dc, wr }
    assign debug[8:7] = {!be[1], !be[0]}; // Active high byte enables
    //assign debug[4] = bcd[0]; // { wr }
    //assign debug[6:5] = { ram_wait_req, ram_valid };
    //assign debug[7] = is_ram;
    //assign debug[8] = sram_we;
    //assign debug[9] = !be[1:0];
    //assign debug[11:10] = { is_sram, is_rom };
    //assign debug[12] = is_reset_vector;
    //assign debug[15:13] = { is_dead, is_nop, is_jmp_zero };
    //assign debug[12:10] = { is_reset_vector, is_ram, is_rom };
    //assign debug[15:13] = { is_active, is_busy, rom_clk };
    //assign debug[15:13] = { is_dead, is_busy, rom_clk };
    //assign debug[15:12] = ads_pulse[3:0];
    //assign debug[15:13] = { is_dead, ads_pulse, ads_pulse_2 };
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
    `ifdef AM386_DEBUG_RAM_ADDRESS
    assign debug[0] = ~ads_pulse[2] & is_ram & is_memory & is_data ;
    assign debug[7:1]  = address_ff[10:4];
    assign debug[15:8] = address_ff[20:13];
    `endif
`endif


    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // ADDR/DATA DRIVERS    
    wire [15:0] data_wire; 
    assign data          = is_read  ? data_wire : 16'hzzzz;
    assign data_wire     = is_rom   ? rom_data  : 16'hzzzz;
    assign data_wire     = is_ram   ? ram_data  : 16'hzzzz;
    assign data_wire     = is_sram  ? sram_data : 16'hzzzz;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // READY SIGNAL DELAY RELATIVE TO ADS
    //localparam DATA_READY_WIDTH=16;
    localparam DATA_READY_WIDTH=7;
    reg [DATA_READY_WIDTH:0] data_ready_ff;
    
    always @(posedge clk or negedge reset_n)
    if(!reset_n) begin
        data_ready_ff <= 32'hFFFFFFFF;
    end else begin
        data_ready_ff <= { data_ready_ff[DATA_READY_WIDTH-1:0], !(|ads_pulse[1:0]) };
    end
    
    wire data_ready;  assign data_ready = data_ready_ff[DATA_READY_WIDTH];
     
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
     // READY ASSERTION
     reg ready_ff;
     assign ready = ready_ff;
     
     reg ram_ready_ff;
     // READY GENERATION
     always @* begin
        if(is_ram) begin
            ready_ff = ram_ready_ff;
        end else 
        if(is_rom | is_sram) begin
            ready_ff = data_ready;
        end else
        if(is_io) begin
            ready_ff = data_ready;
        end else begin
            ready_ff = 1;
        end
     end
     
    // RAM READ/WRITE/READY control.
    reg [6:0] sm_ram;
    always @(posedge clk or negedge reset_n)
    if(!reset_n) begin
       sm_ram <= 0;
       ram_ready_ff <= 1;
       az_wr_n <= 1;
       az_rd_n <= 1;
    end else begin
       case(sm_ram)
           0: if(sm_ph[1] & is_ram) sm_ram <= 1;
           1: if(!ram_wait_req) begin
               az_wr_n <= ~is_write;
               az_rd_n <= ~is_read;
               sm_ram <= 2;
           end 
           2: begin // deassert RW/EN exactly 1 clock later.
               az_wr_n <= 1;
               az_rd_n <= 1;
               sm_ram <= 3;
           end
           3:  if(ram_valid | is_write) begin
               ram_ready_ff <= 1'b0;
               sm_ram <= 4;
           end
           4: sm_ram <= 5;
           5: begin
               ram_ready_ff <= 1'b1;
               sm_ram <= 0;
           end
           default: begin
               ram_ready_ff <= 1;
               sm_ram <= 0;
           end
           endcase
    end
    
    //ram_valid, ram_wait_req
    
    // need to handle wait_req from sdram controller
    // need to handle determining if we're talking to fast sram/rom
    // need to handle additive delay rom data_ready block.
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // BUS CYCLE PHASE
    localparam T0  = 4'b0001; // IDLE
    localparam T1  = 4'b0010; // T1
    localparam T2  = 4'b0100; // T
    
    reg [2:0] sm_ph;
    always @(posedge clk or negedge reset_n)
    if(!reset_n) begin
        sm_ph <= T0;
        //ready <= 1;
    end else begin
        //ready <= data_ready;
        case(sm_ph)
            T0: if(!ads_pulse[0]) begin
                sm_ph <= T1;
            end
            T1: begin
                    // Don't move out of T1 until RAM is ready
                    //if(is_ram) begin
                    //  if(!ram_wait_req & ads & !ready) sm_ph <= T2;
                    //end else begin
                    if(ads & !ready) sm_ph <= T2;
                    //end
            end
            T2: begin
                if(ready) sm_ph <= T0;
            end
        endcase
    end
//
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // ADDRESS DECODING
    // 8MB of physical DRAM
    localparam DRAM_BASE = 24'h000000;
    localparam DRAM_SIZE = 24'h800000; // 0b1000_0000_0000_0000_0000_0000
    // 128K of logical ROM, phyiscally mapped top-down.
    localparam ROM_BASE  = 24'hfe0000; // 0b1111_1110_0000_0000_0000_0000
    localparam ROM_SIZE  = 18'h20000;  // 0b0000_0010_0000_0000_0000_0000

    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // ADDRESS DECODING
    // RESERVED BASE
    localparam XFF_0000 = 24'b1111_1111_0000_0000_0000_0000;
    localparam X0F_0000 = 24'b0000_1111_0000_0000_0000_0000; //[19:16]
    // ROM BASE
    localparam XFF_FC00 = 24'b1111_1111_1111_1100_0000_0000;
    localparam X0F_FC00 = 24'b0000_1111_1111_1100_0000_0000; //[19:10]
    // DECODE LOGIC
    ////////////assign is_ram        = ~is_reserved         &  !address_ff[23]                          & is_memory; 
    ////////////assign is_reserved   = &address_ff[19:16]   & (&address_ff[23:20] | ~address_ff[23:20]) & is_memory;
    ////////////assign is_sram      = is_reserved & ~is_rom; // hack for now.  0x0F_0000 - 0x0F_FBFF (but only 32K mapped).
    ////////////assign is_rom        = &address_ff[19:10]   & (&address_ff[23:20] | ~address_ff[23:20]) & is_memory;
    //assign is_ram        = ~is_reserved & !address[23] & is_memory; 
    //assign is_reserved = &address[19:16] & (&address[23:20] | ~address[23:20]) & is_memory;
    //assign is_rom        = &address[19:10]  & (&address[23:20] | ~address[23:20]) & is_memory;
    
    // ADDRESS DECODE
    wire is_rom, is_sram, is_ram;
    assign is_rom  = is_rom_ff  & is_memory;
    assign is_sram = is_sram_ff & is_memory;
    assign is_ram  = is_ram_ff  & is_memory & !is_rom & !is_sram;
    
    reg is_ram_ff, is_sram_ff, is_rom_ff;
    always @(address) begin
        // ROM
        if( (address >= 'hFF_FC00) ) is_rom_ff = 1;
        else if( (address >= 'h0F_FC00) & address < 'h10_0000) is_rom_ff = 1;
        else is_rom_ff = 0;
        // SRAM
        if( (address >= 'hFF_0000) & address < 'hFF_8000) is_sram_ff = 1;
        else if( (address >= 'h0F_0000) & address < 'h0F_8000) is_sram_ff = 1;
        else is_sram_ff = 0;
        // RAM
        if( (address < 'h80_0000) ) is_ram_ff = 1;
        else is_ram_ff = 0;
    end
    
    

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // HELPER SIGNALS

    wire is_memory, is_io, is_read, is_write, is_control, is_data;
    assign is_memory    = mio_ff;  assign is_io         = ~mio_ff;
    assign is_write     = wr_ff;   assign is_read       = ~wr_ff;  
    assign is_data      = dc_ff;   assign is_control    = ~dc_ff;
    assign is_busy      = ~sm_ph[0];

    // Generate a single pulse when ADS is asserted.
    reg ads_ff[1:0];
    always @(posedge clk) begin
        ads_ff[0] <= ads;
        ads_ff[1] <= ads_ff[0];
    end
    wire [3:0] ads_pulse;
    assign ads_pulse[0] = !ads       &  ads_ff[0];
    assign ads_pulse[1] = !ads_ff[0] &  ads_ff[1];
    assign ads_pulse[2] = !ads_ff[0] & !ads_ff[1];
    assign ads_pulse[3] =  ads_ff[0] & !ads_ff[1];

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // BUS CAPTURE
    reg [23:0] address_ff;
    reg [15:0] data_ff;
    reg mio_ff, wr_ff, dc_ff, beh_ff, bel_ff;
    
    // Latch the bus state the next clock after ADS# is asserted.
    always @(posedge ads_pulse[1]) begin
            address_ff <= address;
            mio_ff <= mio;
            wr_ff <= wr;
            dc_ff <= dc;
            beh_ff <= beh;
            bel_ff <= bel;
    end
     // CAPTURE DATA FROM THE CPU ON THE 2ND CLOCK OF ADS ASSERTED.
     always @(posedge ads_pulse[2]) begin
        data_ff <= data;
     end
    //

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DEBUG HELPER LOGIC

    `define DEBUG_HELPER_LOGIC
    `ifdef DEBUG_HELPER_LOGIC
        localparam JUMP_BACK_16 = 16'hEEEB;
        localparam NOP              = 16'h9090;
        localparam JMPZERO      = 16'hFEEB;
          //localparam JMPZERO      = 16'hEBFE;
        localparam RESET_VECTOR = 24'hFF_FFF0;
        localparam DEAD         = 16'hDEAD;

        wire is_reset_vector;
        wire is_nop;
        wire is_jmp_zero;
        wire is_dead;
        
        assign is_reset_vector = (address[23:1] == RESET_VECTOR[23:1]) | (address[19:1] == RESET_VECTOR[19:1]);
        assign is_nop = data[15:0] == NOP[15:0];
        assign is_dead = data[15:0]  == DEAD[15:0];
        assign is_jmp_zero = !ready & data[15:0] == JMPZERO[15:0];
    `endif
    //
    //`define FLASHY
    `ifdef FLASHY
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
    `endif
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // ROM SECTION
    wire rom_clk;
    assign rom_clk = ads_pulse[1] & is_read & is_memory & is_rom;

    wire [15:0] rom_data;
    rom_fffc00  rom_fffc00_inst (
        .address ( address[9:1] ),
        .clock ( rom_clk ),
        .q ( { rom_data[7:0], rom_data[15:8] } )
    );
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // SRAM SECTION
    
    // M9K RAM INTERFACE:  32KiB
    
    wire [15:0] sram_data;
    wire sram_we, sram_clk;
    
    assign sram_clk  = clk;
    assign sram_we  = ads_pulse[2] & is_memory & is_sram & is_write;
   // assign ram_we   = ram_clk & is_write;
    
    ram_000000  ram_000000_inst (
        .address ( address_ff[14:1] ),
        .clock ( sram_clk ),
        .data ( data_ff ), // non-flopped
        .wren ( sram_we ),
        .q ( sram_data )
    );
endmodule
// TEMPLATE 
//  always @(posedge clk or negedge reset_n)
//  if(!reset_n) begin
//  end else begin
//  end
//  

