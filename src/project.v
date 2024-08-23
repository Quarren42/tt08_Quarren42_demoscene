/*
 * Copyright (c) 2024 Nicholas Junker
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_quarren42_demoscene_top(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  localparam h_min_width = 300;
  localparam h_max_width = 340;
  localparam v_min_width = 210;
  localparam v_max_width = 250;

  reg test_h;
  reg test_v;
  reg test_g_h;
  reg test_g_v;
  reg test_b_h;
  reg test_b_v;
  reg [9:0] v_offset;
  reg [9:0] v_offset_2 = 50;
  reg [9:0] v_offset_3 = 115;
  reg v_offset_rev_flag;
  reg v_offset_rev_flag2;
  reg v_offset_rev_flag3;

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );
  
  always @(posedge clk)
    begin
      if (pix_x > (h_min_width-v_offset_2) && pix_x < (h_max_width+v_offset_2))
    test_h <= 1;
  else
    test_h <= 0;
    end
  
   always @(posedge clk)
     begin
       if (pix_y > (v_min_width-v_offset_2) && (pix_y) < (v_max_width+v_offset_2))
    test_v <= 1;
  else
    test_v <= 0;
     end
  
    always @(posedge clk)
    begin
      if (pix_x > (h_min_width-v_offset+15) && pix_x < (h_max_width+v_offset-15))
    test_g_h <= 1;
  else
    test_g_h <= 0;
    end
  
   always @(posedge clk)
     begin
       if (pix_y > (v_min_width-v_offset/2) && (pix_y) < (v_max_width+v_offset*3))
    test_g_v <= 1;
  else
    test_g_v <= 0;
     end
  
    always @(posedge clk)
    begin
      if (pix_x-(v_offset_3*2) > (h_min_width-v_offset_3) && pix_x < (h_max_width+v_offset_3))
    test_b_h <= 1;
  else
    test_b_h <= 0;
    end
  
   always @(posedge clk)
     begin
       if ((pix_y-(v_offset_3*2)) > (v_min_width-v_offset_3) && (pix_y) < (v_max_width+v_offset_3))
    test_b_v <= 1;
  else
    test_b_v <= 0;
     end
  
  always @(posedge vsync or negedge rst_n)
    begin
      if (~rst_n)
        begin
        v_offset <= 0;
      	v_offset_rev_flag <= 0;
        end
      else begin
        if (v_offset == 0)
        v_offset_rev_flag <= 1;
        else if (v_offset == 200)
        v_offset_rev_flag <= 0;
        if (v_offset_rev_flag == 1)
        v_offset <= v_offset + 1;
      else
        v_offset <= v_offset - 1;
      end
    end
  
   always @(posedge vsync or negedge rst_n)
    begin
      if (~rst_n)
        begin
        v_offset_2 <= 100;
      	v_offset_rev_flag2 <= 0;
        end
      else begin
        if (v_offset_2 == 0)
        v_offset_rev_flag2 <= 1;
        else if (v_offset_2 == 200)
        v_offset_rev_flag2 <= 0;
        if (v_offset_rev_flag2 == 1)
        v_offset_2 <= v_offset_2 + 1;
      else
        v_offset_2 <= v_offset_2 - 1;
      end
    end
  
   always @(posedge vsync or negedge rst_n)
    begin
      if (~rst_n)
        begin
        v_offset_3 <= 0;
      	v_offset_rev_flag3 <= 0;
        end
      else begin
        if (v_offset_3 == 0)
        v_offset_rev_flag3 <= 1;
        else if (v_offset_3 == 200)
        v_offset_rev_flag3 <= 0;
        if (v_offset_rev_flag3 == 1)
        v_offset_3 <= v_offset_3 + 1;
      else
        v_offset_3 <= v_offset_3 - 1;
      end
    end      

  wire r = (video_active && test_v && test_h);
  wire g = (video_active && test_g_h && test_g_v);
  wire b = (video_active && test_b_h && test_b_v);

  assign R[0] = b;
  assign R[1] = b;

  assign G[0] = g;
  assign G[1] = g;

  assign B[0] = r;
  assign B[1] = r;
  
endmodule
