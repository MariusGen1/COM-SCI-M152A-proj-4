`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 05/20/2025 01:15:57 PM
// Design Name:
// Module Name: clk_divider
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module clk_divider (
    input wire clk,
    output wire display_clk,
    output wire clk_1hz,
    output wire clk_500hz
);

    reg [27:0] q = 0;

    always @(posedge clk) begin
        q <= q + 1;
    end
   
    assign display_clk = q[1];
    assign clk_1hz = q[25];
    assign clk_500hz = q[17];
   
endmodule