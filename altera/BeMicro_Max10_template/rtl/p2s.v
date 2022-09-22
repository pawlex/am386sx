// MODULE: 	p2s.v
// DESC:    parallel to serial converter
// AUTHOR:	pawlex (github.com/pawlex)

module p2s
       (
           input  clk,
           input  reset_n,
           input  [WIDTH-1:0] d_in,
           input  run,     // START CONDITION
           output d_out,   // MOSI
           output idle     // CS_N
       );
//parameter TAP = 10;
parameter WIDTH = 8;
reg [WIDTH-1:0] counter_ff; // change to clog2
reg [WIDTH-1:0] data_ff;
reg idle_ff;

assign d_out = data_ff[counter_ff];
assign idle = ~(idle_ff | |counter_ff);

always @(posedge clk) begin
    idle_ff <= (|counter_ff);
end


always @(posedge clk or negedge reset_n)
    if(!reset_n) begin
        counter_ff <= 0;
        data_ff <= 0;
    end else begin
        if(run && idle) begin
            data_ff <= d_in;
            counter_ff <= WIDTH-1;
        end else begin
            if(counter_ff) counter_ff <= counter_ff - 1'b1;
        end
    end
endmodule
