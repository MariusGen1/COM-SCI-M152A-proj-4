`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 05/20/2025 01:15:15 PM
// Design Name:
// Module Name: main
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


module main(
    input wire clk,
    input wire btnC,
    input wire btnL,
    input wire btnR,
    output reg [6:0] seg,
    output reg [3:0] an_on,
    output wire [2:0] vgaRed,
    output wire [2:0] vgaGreen,
    output wire [1:0] vgaBlue,
    output wire Hsync,
    output wire Vsync
);

    wire display_clk;
    wire clk_1hz;
    wire clk_500hz;
   
    reg [4:0] score_p1_tens = 0;
    reg [4:0] score_p1_units = 0;
    reg [4:0] score_p2_tens = 0;
    reg [4:0] score_p2_units = 0;
    reg winner_determined = 0;
    reg [4:0] digit_to_display;
   
    reg clr = 0;
    reg [1:0] symbol = 0;
    reg [1:0] prev_symbol = 0;
    reg db_btnL = 0;
    reg [5:0] lfsr = 6'b000001;
    wire feedback = lfsr[5] ^ lfsr[0];
   
    clk_divider div (
        .clk(clk),
        .display_clk(display_clk),
        .clk_1hz(clk_1hz),
        .clk_500hz(clk_500hz)
    );
   
    vga640x480 display (
        .dclk(display_clk),
        .clr(clr),
        .hsync(Hsync),
        .vsync(Vsync),
        .red(vgaRed),
        .green(vgaGreen),
        .blue(vgaBlue),
        .symbol(symbol)
    );

    always @(posedge clk_1hz) begin
        lfsr = { lfsr[4:0], feedback };
        symbol = lfsr[1:0];
    end
   
    always @(posedge display_clk) begin
        db_btnL <= btnL;
    end
   
    always @(posedge clk) begin
        if (prev_symbol != symbol) begin
            prev_symbol = symbol;
            winner_determined = 0;
        end
   
        if (btnC) begin
            score_p1_tens = 0;
            score_p1_units = 0;
            score_p2_tens = 0;
            score_p2_units = 0;
        end
   
        if (winner_determined == 0) begin
            if (btnR) begin
                winner_determined = 1;
               
                if (symbol == 3) begin
                    if (score_p2_units == 9) begin
                        score_p2_units = 0;
                        if (score_p2_tens == 9) begin
                            score_p2_tens = 0;
                        end else begin
                            score_p2_tens = score_p2_tens + 1;
                        end
                    end else begin
                        score_p2_units = score_p2_units + 1;
                    end
                end else begin
                    if (score_p2_units == 0) begin
                        if (score_p2_tens != 0) begin
                            score_p2_units = 9;
                            score_p2_tens = score_p2_tens - 1;
                        end
                    end else begin
                        score_p2_units = score_p2_units - 1;
                    end
                end
            end
           
            if (btnL) begin
                winner_determined = 1;
               
                if (symbol == 3) begin        
                    if (score_p1_units == 9) begin
                        score_p1_units = 0;
                        if (score_p1_tens == 9) begin
                            score_p1_tens = 0;
                        end else begin
                            score_p1_tens = score_p1_tens + 1;
                        end
                    end else begin
                        score_p1_units = score_p1_units + 1;
                    end
                 end else begin
                    if (score_p1_units == 0) begin
                        if (score_p1_tens != 0) begin
                            score_p1_units = 9;
                            score_p1_tens = score_p1_tens - 1;
                        end
                    end else begin
                        score_p1_units = score_p1_units - 1;
                    end
                end
            end
        end
    end
   
   
    always @(posedge clk_500hz) begin            
            if (an_on == 4'b0111) begin
                an_on = 4'b1011;
                digit_to_display = score_p1_units;
            end else if (an_on == 4'b1011) begin
                an_on = 4'b1101;
                digit_to_display = score_p2_tens;
            end else if (an_on == 4'b1101) begin
                an_on = 4'b1110;
                digit_to_display = score_p2_units;
            end else begin
                an_on = 4'b0111;
                digit_to_display = score_p1_tens;
            end
           
            if (digit_to_display == 0) seg = 7'b1000000;
            else if (digit_to_display == 1) seg = 7'b1111001;
            else if (digit_to_display == 2) seg = 7'b0100100;
            else if (digit_to_display == 3) seg = 7'b0110000;
            else if (digit_to_display == 4) seg = 7'b0011001;
            else if (digit_to_display == 5) seg = 7'b0010010;
            else if (digit_to_display == 6) seg = 7'b0000010;
            else if (digit_to_display == 7) seg = 7'b1111000;
            else if (digit_to_display == 8) seg = 7'b0000000;
            else if (digit_to_display == 9) seg = 7'b0010000;
            else seg = 7'b1111111;
        end

endmodule