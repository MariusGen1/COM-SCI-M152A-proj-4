`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    00:30:38 03/19/2013
// Design Name:
// Module Name:    vga640x480
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module vga640x480(
input wire dclk, //pixel clock: 25MHz
input wire clr, //asynchronous reset
output wire hsync, //horizontal sync out
output wire vsync, //vertical sync out
output reg [2:0] red, //red vga output
output reg [2:0] green, //green vga output
output reg [1:0] blue, //blue vga output
input wire [1:0] symbol
);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; // hsync pulse length
parameter vpulse = 2; // vsync pulse length
parameter hbp = 144; // end of horizontal back porch
parameter hfp = 784; // beginning of horizontal front porch
parameter vbp = 31; // end of vertical back porch
parameter vfp = 511; // beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

reg [9:0] tmp1;
reg [9:0] tmp2;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge dclk or posedge clr)
begin
// reset condition
if (clr == 1)
begin
hc <= 0;
vc <= 0;
end
else
begin
// keep counting until the end of the line
if (hc < hpixels - 1)
hc <= hc + 1;
else
// When we hit the end of the line, reset the horizontal
// counter and increment the vertical counter.
// If vertical counter is at the end of the frame, then
// reset that one too.
begin
hc <= 0;
if (vc < vlines - 1)
vc <= vc + 1;
else
vc <= 0;
end

end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(*)
begin
// first check if we're within vertical active video range
if (vc >= vbp && vc < vfp && hc >= hbp && hc < hfp)
begin
  if (symbol == 0) begin
     red = 3'b000;
     green = 3'b111;
     blue = 2'b00;
  end else if (symbol == 1) begin
     // Rectangle
     if (hc >= (hbp+240) && hc <= (hbp+400) && vc >= (vbp+160) && vc <= (vbp+320)) begin
          red = 3'b111;
          green = 3'b000;
          blue = 2'b00;
     end else begin
          red = 3'b000;
               green = 3'b111;
               blue = 2'b00;
     end
     
  end else if (symbol == 2) begin
          red = 3'b111;
          green = 3'b000;
          blue = 2'b00;
  end else if (symbol == 3) begin
     // Diamond
     tmp1 = (hc > hbp + 320) ? (hc - (hbp + 320)) : (-hc + (hbp + 320));
     tmp2 = (vc > vbp + 240) ? (vc - (vbp + 240)) : (-vc + (vbp + 240));
     if ((tmp1 + tmp2) <= 120) begin
          red = 3'b000;
               green = 3'b111;
               blue = 2'b00;
     end else begin
               red = 3'b111;
               green = 3'b000;
               blue = 2'b00;
          end
  end
end
// we're outside active vertical range so display black
else
begin
red = 0;
green = 0;
blue = 0;
end
end

endmodule