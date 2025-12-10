//******************************************************************************
// file:    holdbuffer.v
//
// author:  JAY CONVERTINO
//
// date:    20?/?/?
//
// about:   Brief
// Holdbuffer is used to pipeline backpressure busses.
//
// license: License MIT
// Copyright 2025 Jay Convertino
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
//******************************************************************************

`resetall
`timescale 1 ns/100 ps
`default_nettype none

/*
 * Module: holdbuffer
 *
 * Hold data till ready
 *
 * Parametes:
 *  BUS_WIDTH         - width of the parallel data input in bits.
 *
 * Ports:
 *  clk               - global clock for the core.
 *  rstn              - negative syncronus reset to clk.
 *  s_data            - Input data that is BUS_WIDTH bits wide.
 *  s_data_valid      - Input data is valid when 1 (high).
 *  s_data_ready      - Core is ready for input data when 1 (high).
 *  s_data_ack        - Output 1 when data is written to the register(s) of the core.
 *  m_data            - Output data that is BUS_WIDTH bits wide.
 *  m_data_valid      - Output data is valid when 1 (high).
 *  m_data_ready      - Downstream is ready to output data when 1 (high).
 *  m_data_ack        - Downstream has registered the valid data when 1 (high).
 *
 */
module holdbuffer #(
    parameter integer   BUS_WIDTH = 8,
    parameter integer   ACK_ENABLE = 0
  ) (
    input   wire                    clk,
    input   wire                    rstn,
    input   wire                    timeout,
    input   wire                    enable,
    input   wire  [BUS_WIDTH-1:0]   s_data,
    input   wire                    s_data_last,
    input   wire                    s_data_valid,
    output  wire                    s_data_ready,
    output  wire                    s_data_ack,
    output  wire  [BUS_WIDTH-1:0]   m_data,
    output  wire                    m_data_last,
    output  wire                    m_data_valid,
    input   wire                    m_data_ready,
    input   wire                    m_data_ack
  );
  
  localparam GET   = 2'd1;
  localparam ACK   = 2'd2;
  localparam HOLD  = 2'd3;
  localparam ERROR = 2'd0;
  
  wire                    w_hold_check;
  wire                    w_get_check;

  reg   [1:0]             r_state;
  
  reg                     r_data_ack;
  reg   [BUS_WIDTH-1:0]   r_data;
  reg                     r_data_last;
  reg                     r_data_valid;
  reg   [BUS_WIDTH-1:0]   rr_data;
  reg                     rr_data_last;
  reg                     rr_data_valid;
  
  reg                     r_ready;
  
  assign m_data       = (enable ? r_data        : {BUS_WIDTH{8'h00}});
  assign m_data_last  = (enable ? r_data_last   : 1'b0);
  assign m_data_valid = (enable ? r_data_valid  : 1'b0);
  assign s_data_ready = r_ready;
  assign s_data_ack   = r_data_ack;
  
  assign w_hold_check = (!m_data_ready || (ACK_ENABLE ? !m_data_ack : 1'b0)) && r_data_valid && !timeout && enable;
  assign w_get_check  = (ACK_ENABLE ? m_data_ack : 1'b0) || m_data_ready || timeout || !enable;
  
  
  always @(posedge clk)
  begin
    if(rstn == 1'b0)
    begin
      r_state <= GET;
      
      r_data_ack <= 1'b0;
      r_data <= {BUS_WIDTH{1'b0}};
      r_data_last <= 1'b0;
      r_data_valid <= 1'b0;
      rr_data <= {BUS_WIDTH{1'b0}};
      rr_data_last <= 1'b0;
      rr_data_valid <= 1'b0;
      
      r_ready <= 1'b0;
    end else begin
      r_state <= r_state;
      
      case(r_state)
        GET:
        begin
          r_ready <= 1'b1;
          
          r_data_ack <= 1'b0;
          
          r_data <= s_data;
          r_data_last <= s_data_last;
          r_data_valid <= s_data_valid;
          
          if(s_data_valid)
          begin
            r_data_ack <= (ACK_ENABLE ? 1'b1 : 1'b0);
          end
          
          if(w_hold_check)
          begin
            r_ready <= 1'b0;
            
            r_data <= r_data;
            r_data_last <= r_data_last;
            r_data_valid <= r_data_valid;
            
            rr_data <= s_data;
            rr_data_last <= s_data_last;
            rr_data_valid <= s_data_valid;
            
            r_state <= HOLD;
          end
        end
        HOLD:
        begin
          r_ready <= 1'b0;
          
          r_data_ack <= 1'b0;
          
          if(w_get_check)
          begin
            r_ready <= 1'b1;
            
            r_data <= rr_data;
            r_data_last <= rr_data_last;
            r_data_valid <= rr_data_valid;
            
            rr_data <= {BUS_WIDTH{1'b0}};
            rr_data_last <= 1'b0;
            rr_data_valid <= 1'b0;
            
            r_state <= GET;
            
            if(timeout || !enable)
            begin
              r_data <= {BUS_WIDTH{1'b0}};
              r_data_last <= 1'b0;
              r_data_valid <= 1'b0;
            end
          end
        end
        default:
        begin
          r_state <= GET;
          r_ready <= 1'b0;
        end
      endcase
    end
  end

endmodule

`resetall
