// MODULE: 	flashy.v
// DESC:		Simple clock divider, intended to be use as an activity indicator.
// AUTHOR:	pawlex (github.com/pawlex)

// TODO:  ADD free-running clock, and logic to determine if signal has changed.
// TODO:  ADD parameter input for clock frequency.

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