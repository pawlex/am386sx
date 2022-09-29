/* This is a Verilog template for use with the BeMicro MAX 10 development kit */
/* It is used for showing the IO pin names and directions                     */
/* Ver 0.2 10.07.2014                                                         */

/* NOTE: A VHDL version of this template is also provided with this design    */
/* example for users that prefer VHDL. This BeMicro_MAX10_top.v file would    */
/* need to be removed from the project and replaced with the                  */
/* BeMicro_MAX10_top.vhd file to switch to the VHDL template.                 */

/* The signals below are documented in the "BeMicro MAX 10 Getting Started    */
/* User Guide."  Please refer to that document for additional signal details. */

`define ENABLE_CLOCK_INPUTS
`define ENABLE_PLL_0
`define ENABLE_PLL_1
//`define ENABLE_DAC_SPI_INTERFACE
//`define ENABLE_TEMP_SENSOR
//`define ENABLE_ACCELEROMETER
`define ENABLE_SDRAM
//`define ENABLE_SPI_FLASH
//`define ENABLE_MAX10_ANALOG
`define ENABLE_PUSHBUTTON
`define ENABLE_LED_OUTPUT
//`define ENABLE_EDGE_CONNECTOR
`define ENABLE_HEADERS
`define ENABLE_GPIO_J3
`define ENABLE_GPIO_J4
`define ENABLE_PMOD
`define AM386_SX
//`define AM386_VERY_SLOW_CLOCK
`define DESIGN_LEVEL_RESET
`define ENABLE_CHIPSCOPE

module BeMicro_MAX10_top (

`ifdef  ENABLE_DAC_SPI_INTERFACE
    /* DAC, 12-bit, SPI interface (AD5681) */
    output AD5681R_LDACn,
    output AD5681R_RSTn,
    output AD5681R_SCL,
    output AD5681R_SDA,
    output AD5681R_SYNCn,
`endif  

`ifdef ENABLE_TEMP_SENSOR 
    /* Temperature sensor, I2C interface (ADT7420) */
    // Voltage Level 3.3V
    input ADT7420_CT,       
    input ADT7420_INT,      
    inout ADT7420_SCL,      
    inout ADT7420_SDA,
`endif

`ifdef ENABLE_ACCELEROMETER 
    /* Accelerometer, 3-Axis, SPI interface (ADXL362)*/
    // Voltage Level 3.3V
    output ADXL362_CS,
    input ADXL362_INT1,
    input ADXL362_INT2,
    input ADXL362_MISO,
    output ADXL362_MOSI,
    output ADXL362_SCLK,
`endif  

`ifdef ENABLE_SDRAM
    /* 8MB SDRAM, ISSI IS42S16400J-7TL SDRAM device */
    // Voltage Level 3.3V
    output [12:0] SDRAM_A,
    output [1:0] SDRAM_BA,
    output SDRAM_CASn,
    output SDRAM_CKE,
    output SDRAM_CLK,
    output SDRAM_CSn,
    inout [15:0] SDRAM_DQ,
    output SDRAM_DQMH,
    output SDRAM_DQML,
    output SDRAM_RASn,
    output SDRAM_WEn,
`endif

`ifdef ENABLE_SPI_FLASH 
    /* Serial SPI Flash, 16Mbit, Micron M25P16-VMN6 */
    // Voltage Level 3.3V
    input SFLASH_ASDI,
    input SFLASH_CSn,
    inout SFLASH_DATA,
    inout SFLASH_DCLK,
`endif  

`ifdef ENABLE_MAX10_ANALOG
    /* MAX10 analog inputs */
    // Voltage Level 3.3V
    input [7:0] AIN,
`endif

`ifdef ENABLE_PUSHBUTTON    
    /* pushbutton switch inputs */
    // Voltage Level 3.3V
    input [4:1] PB,
`endif  

`ifdef ENABLE_LED_OUTPUT
    /* LED outputs */
    // Voltage Level 3.3V
    output [8:1] USER_LED,
`endif  

`ifdef ENABLE_EDGE_CONNECTOR
    /* BeMicro 80-pin Edge Connector */ 
    // Voltafe Level 3.3V
    inout EG_P1,
    inout EG_P10,
    inout EG_P11,
    inout EG_P12,
    inout EG_P13,
    inout EG_P14,
    inout EG_P15,
    inout EG_P16,
    inout EG_P17,
    inout EG_P18,
    inout EG_P19,
    inout EG_P2,
    inout EG_P20,
    inout EG_P21,
    inout EG_P22,
    inout EG_P23,
    inout EG_P24,
    inout EG_P25,
    inout EG_P26,
    inout EG_P27,
    inout EG_P28,
    inout EG_P29,
    inout EG_P3,
    inout EG_P35,
    inout EG_P36,
    inout EG_P37,
    inout EG_P38,
    inout EG_P39,
    inout EG_P4,
    inout EG_P40,
    inout EG_P41,
    inout EG_P42,
    inout EG_P43,
    inout EG_P44,
    inout EG_P45,
    inout EG_P46,
    inout EG_P47,
    inout EG_P48,
    inout EG_P49,
    inout EG_P5,
    inout EG_P50,
    inout EG_P51,
    inout EG_P52,
    inout EG_P53,
    inout EG_P54,
    inout EG_P55,
    inout EG_P56,
    inout EG_P57,
    inout EG_P58,
    inout EG_P59,
    inout EG_P6,
    inout EG_P60,
    inout EG_P7,
    inout EG_P8,
    inout EG_P9,
    input EXP_PRESENT,
    output RESET_EXPn,
`endif

`ifdef ENABLE_HEADERS   
    /* Expansion headers (pair of 40-pin headers) */
    // Voltage Level 3.3V
    inout GPIO_01,
    inout GPIO_02,
    inout GPIO_03,
    inout GPIO_04,
    inout GPIO_05,
    inout GPIO_06,
    inout GPIO_07,
    inout GPIO_08,
    inout GPIO_09,
    inout GPIO_10,
    inout GPIO_11,
    inout GPIO_12,
    inout GPIO_A,
    inout GPIO_B,
    inout I2C_SCL,
    inout I2C_SDA,
`endif

`ifdef ENABLE_GPIO_J3
    //The following group of GPIO_J3_* signals can be used as differential pair 
    //receivers as defined by some of the Terasic daughter card that are compatible 
    //with the pair of 40-pin expansion headers. To use the differential pairs, 
    //there are guidelines regarding neighboring pins that must be followed.  
    //Please refer to the "Using LVDS on the BeMicro MAX 10" document for details.
    // Voltage Level 3.3V
    inout GPIO_J3_15,
    inout GPIO_J3_16,
    inout GPIO_J3_17, 
    inout GPIO_J3_18,
    inout GPIO_J3_19,
    inout GPIO_J3_20,
    inout GPIO_J3_21,   
    inout GPIO_J3_22,
    inout GPIO_J3_23,   
    inout GPIO_J3_24,
    inout GPIO_J3_25,   
    inout GPIO_J3_26,
    inout GPIO_J3_27,   
    inout GPIO_J3_28,
    inout GPIO_J3_31,   
    inout GPIO_J3_32,
    inout GPIO_J3_33,   
    inout GPIO_J3_34,
    inout GPIO_J3_35,   
    inout GPIO_J3_36,
    inout GPIO_J3_37,   
    inout GPIO_J3_38,
    inout GPIO_J3_39,   
    inout GPIO_J3_40,

`endif

`ifdef ENABLE_GPIO_J4
    //The following group of GPIO_J4_* signals can be used as true LVDS transmitters 
    //as defined by some of the Terasic daughter card that are compatible 
    //with the pair of 40-pin expansion headers. To use the differential pairs, 
    //there are guidelines regarding neighboring pins that must be followed.  
    //Please refer to the "Using LVDS on the BeMicro MAX 10" document for details.
    // Voltage Level 3.3V
    inout GPIO_J4_11, 
    inout GPIO_J4_12,
    inout GPIO_J4_13,
    inout GPIO_J4_14,
    inout GPIO_J4_15, 
    inout GPIO_J4_16, 
    inout GPIO_J4_19,
    inout GPIO_J4_20,
    inout GPIO_J4_21,
    inout GPIO_J4_22, 
    inout GPIO_J4_23,
    inout GPIO_J4_24, 
    inout GPIO_J4_27,
    inout GPIO_J4_28, 
    inout GPIO_J4_29,
    inout GPIO_J4_30, 
    inout GPIO_J4_31,
    inout GPIO_J4_32, 
    inout GPIO_J4_35,
    inout GPIO_J4_36, 
    inout GPIO_J4_37,
    inout GPIO_J4_38, 
    inout GPIO_J4_39,
    inout GPIO_J4_40, 
`endif

`ifdef ENABLE_PMOD  
    /* PMOD connectors */
    //Voltage Level 3.3V
    inout [3:0] PMOD_A,
    inout [3:0] PMOD_B,
    inout [3:0] PMOD_C,
    inout [3:0] PMOD_D,
`endif

    /* Clock inputs, SYS_CLK = 50MHz, USER_CLK = 24MHz */   
`ifdef ENABLE_CLOCK_INPUTS
    //Voltage Level 3.3V
    input SYS_CLK,  // 50MHz oscillator at position Y1.
    input USER_CLK // USER_CLK oscillator is not connected. Postition Y2.
`endif

);
//
`ifdef ENABLE_PLL_0
    wire clk80p0, clk40p0, clk20p0, clk10p0, clk2p0, pll_0_lock;
    pll0    pll0_inst 
    (
        .inclk0 ( SYS_CLK ),
        .c0 ( clk80p0 ),
        .c1 ( clk40p0 ),
        .c2 ( clk20p0 ),
        .c3 ( clk10p0 ),
        .c4 ( clk2p0 ),
        .locked ( pll_0_lock )
    );
`endif

`ifdef ENABLE_PLL_1
    wire clk0012p0, pll_1_lock;
    pll1    pll1_inst 
    (
        .inclk0 ( SYS_CLK ),
        .c0 ( clk0012p0 ),  // 1.2KHz 0-deg phase
        .locked ( pll_1_lock )
    );
`endif



//wire am_address_0, am386_status_led;
`ifdef AM386_SX
    // Output Address Bus
    // Address 07:00 : BIT0 X as all transactions are 2-byte aligned.
    `define AM386_ADDRESS_L { GPIO_J4_28, GPIO_J4_27, GPIO_J4_23, GPIO_J4_24, GPIO_J4_21, GPIO_J4_22, GPIO_06, am_address_0 }
    // Address 15:08
    `define AM386_ADDRESS_H { GPIO_J4_38, GPIO_J4_37, GPIO_J4_36, GPIO_J4_35, GPIO_J4_32, GPIO_J4_31, GPIO_J4_30, GPIO_J4_29 }
    // Address 23:16
    `define AM386_ADDRESS_X { GPIO_J3_33, GPIO_J3_36, GPIO_J3_38, GPIO_J3_37, GPIO_J3_40, GPIO_J3_39, GPIO_J4_40, GPIO_J4_39 }
    
    // Bidirectional data bus
    // Data 15:08
    `define AM386_DATA_H { GPIO_J3_34, GPIO_J3_31, GPIO_J3_32, GPIO_J3_28, GPIO_J3_27, GPIO_J3_26, GPIO_J3_25, GPIO_J3_24 }
    // Data 07:00
    `define AM386_DATA_L { GPIO_J3_23, GPIO_J3_22, GPIO_J3_21, GPIO_J3_20, GPIO_J3_19, GPIO_J3_18, GPIO_J3_17, GPIO_J3_16 }
    
    // Byte enables H&L { BHE#, BLE# } (output)
    `define AM386_BE { GPIO_05, GPIO_07 }
    
    // Input 2X clock (input)
    `define AM386_CLK { GPIO_09 }
    // NMI, INTR, RESET (input)
    `define AM386_INT { GPIO_J4_19, GPIO_J4_20, GPIO_J4_13 }
    
    // Bus arbitration
    // HOLDA(ck), HOLD (out, in)
    `define AM386_ARB { GPIO_J3_15, GPIO_12 }
    
    // Bus cycle definition 
    // LOCK, MIO, DC, WR (output)
    `define AM386_BCD { GPIO_B, GPIO_04, GPIO_03, GPIO_02 }
    
    // Bus cycle control
    // ADS, NA, READY (out, in, in)
    `define AM386_BCC { GPIO_08, GPIO_11, GPIO_10 }
    
    // CO-PROCESSOR & AUX CONTROL
    // ERROR, BUSY, PEREQ, FLOAT (input)
    `define AM386_AUX { GPIO_J4_15, GPIO_J4_14, GPIO_J4_16, GPIO_A }
    //
    //
    wire am_address_0;
    wire [7:0] am386_status_led;
    
    //`ifdef AM386_VERY_SLOW_CLOCK
    //reg [3:0] foo;
    //always @(posedge clk0012p0) foo <= foo + 1;
    //assign `AM386_CLK = foo[2]; // 3 = 75Hz, 2 = 150Hz, 1 = 300Hz, 0 = 600Hz
    //localparam SYS_CLK_DIV = 'd10;
    //`else
    ////assign `AM386_CLK = clk0012p0;
    //`define AM386_FASTCLK clk40p0
    ////`define AM386_2MHz
    //`ifdef AM386_2MHz
    //assign `AM386_CLK = clk2p0;
    //`else
    //assign `AM386_CLK = `AM386_FASTCLK; // WORKS in a JMP-16 loop.
    ////assign `AM386_CLK = clk80p0; // WORKS in a JMP-16 loop.
    //`endif
    //localparam SYS_CLK_DIV = 'd1000;
    //`endif
    ////
    
    localparam SYS_CLK_DIV = 'd10000;
    assign `AM386_CLK = clk2p0;
    
    northbridge nb
    (
        .clk(`AM386_CLK),
        .reset_n(reset_n),
        .int(`AM386_INT),       // NMI, INTR, RESET
        .bcc(`AM386_BCC),       // ADS, NA, READY (out, in, in)
        .bcd(`AM386_BCD),       // LOCK, MIO, DC, WR
        .arb(`AM386_ARB),       // HOLDA(ck), HOLD (out, in)
        .be(`AM386_BE),         // H, L
        .address( { `AM386_ADDRESS_X, `AM386_ADDRESS_H, `AM386_ADDRESS_L } ), // bit0 = x;
        .data( { `AM386_DATA_H, `AM386_DATA_L } ),
        .status_led(am386_status_led),
        .debug(DEBUG[8:0]), // 9 bits for protocol
        // SDRAM INTERFACE
        .az_addr(i_addr),       //22
        .az_be_n(i_be_n),       //2
        .az_data(i_data),       //16
        .az_rd_n(i_rd_n),
        .az_wr_n(i_wr_n),
        // outputs:
        .za_data(o_data),       //16
        .za_valid(o_valid),
        .za_waitrequest(o_wait_req)
    );
    
    `ifdef ENABLE_CHIPSCOPE
        reg clkdiv; assign DEBUG[9] = clkdiv; // SPI CLK
        always @(posedge clk10p0) clkdiv <= ~clkdiv;
        wire [2:0] BCC; assign BCC = `AM386_BCC;
        busprobe busprobe0 (
        //.clk2x(clk2p0), .clk4x(clkdiv), .reset_n(reset_n), .ads_b(GPIO_08), .ready_b(GPIO_10),
        .clk2x(clk2p0), .clk4x(clkdiv), .reset_n(reset_n), .ads_b(BCC[2]), .ready_b(BCC[0]),
        .address_i({ `AM386_ADDRESS_X, `AM386_ADDRESS_H, `AM386_ADDRESS_L }), 
        .data_i({ `AM386_DATA_H, `AM386_DATA_L }), 
        .BE(`AM386_BE), .control(`AM386_BCD),
        // DATA
        .datal_sout(DEBUG[10]), // Data Low
        .datah_sout(DEBUG[11]), // Data high
        // Address
        .addrl_sout(DEBUG[12]), // Address Low
        .addrh_sout(DEBUG[13]), // Address High
        .addrx_sout(DEBUG[14]), // Address Extrended[23:16]
        .cs_n(DEBUG[15]) // SPI Chip select
    ); // busprobe0
    `endif // ENABLE_CHIPSCOPE
`endif // AM386_SX
    
    `ifdef ENABLE_SDRAM
    //assign SDRAM_CLK = clk2p0;
    assign SDRAM_CLK = `AM386_CLK;
    wire i_rd_n, i_wr_n, o_valid, o_wait_req;
    wire [15:0] i_data, o_data;
    wire [21:0] i_addr;
    wire [1:0]  i_be_n; // Same as DRAM Data Mask
    nios_system_sdram sdram_0 (
        // inputs:
        .az_addr(i_addr),       //22
        .az_be_n(i_be_n),       //2
        .az_data(i_data),       //16
        .az_rd_n(i_rd_n),
        .az_wr_n(i_wr_n),
        .clk(SDRAM_CLK),
        .reset_n(reset_n),
        // outputs:
        .za_data(o_data),       //16
        .za_valid(o_valid),
        .za_waitrequest(o_wait_req),
        .zs_addr(SDRAM_A),      //12
        .zs_ba(SDRAM_BA),       //2
        .zs_cas_n(SDRAM_CASn),
        .zs_cke(SDRAM_CKE),
        .zs_cs_n(SDRAM_CSn),
        .zs_dq(SDRAM_DQ),   //16 b'z
        .zs_dqm({SDRAM_DQMH,SDRAM_DQML}),       //2
        .zs_ras_n(SDRAM_RASn),
        .zs_we_n(SDRAM_WEn)
        );
`endif

`ifdef ENABLE_CHIPSCOPE
    wire[15:0] DEBUG;
    assign { PMOD_C[3:0], PMOD_D[3:0], PMOD_A[3:0], PMOD_B[3:0] } = DEBUG[15:0];
`endif
`ifdef ENABLE_CHIPSCOPE_DEBUG
    /* Output counter pattern to debug pins */
    reg[15:0] cntr_cs; always @(posedge SYS_CLK) cntr_cs <= cntr_cs + 1'b1;
    assign DEBUG = cntr_cs;
`endif


`ifdef DESIGN_LEVEL_RESET
    /* TODO:  Find out how to use Altera GSR */
    parameter SYS_CLK_FREQ = 'd50_000_000;
    wire reset,reset_n;assign reset = ~reset_n;
    assign reset_n = (user_reset_cpl `ifdef ENABLE_PLL_0 & pll_0_lock `endif `ifdef ENABLE_PLL_1 & pll_1_lock `endif);
    reg [25:0] user_reset_cntr;reg [0:0] user_reset_cpl;
    wire user_reset_button; assign user_reset_button = ~PB[1];

    always @(posedge SYS_CLK or posedge user_reset_button) begin
        if(user_reset_button) begin
            user_reset_cntr <= 0;
            user_reset_cpl  <= 0;
        end 
        else begin
            if(user_reset_cntr == SYS_CLK_FREQ/SYS_CLK_DIV) begin
                user_reset_cpl <= 1;
            end else begin
                user_reset_cntr <= user_reset_cntr + 1'b1;
                user_reset_cpl <= 0;
            end
        end
    end
`endif

/* LED SWAPPING and assigns */
reg [7:0] led_o; assign USER_LED[8:1] = ~led_o;
always @* begin
    led_o[7]= reset_n; // Assert LED while device is in RESET
    led_o[6]= am386_status_led[6];
    led_o[5]= am386_status_led[5];
    led_o[4]= am386_status_led[4];
    led_o[3]= am386_status_led[3];
    led_o[2]= am386_status_led[2];
    led_o[1]= am386_status_led[1];
    led_o[0]= am386_status_led[0];
end


endmodule
