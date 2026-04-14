//******************************************************************************
// file:    tb_cocotb.v
//
// author:  JAY CONVERTINO
//
// date:    2025/12/15
//
// about:   Brief
// Test bench wrapper for cocotb
//
// license: License MIT
// Copyright 2024 Jay Convertino
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

`timescale 1ns/100ps

/*
 * Module: tb_cocotb
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
 *  m_data            - Output data that is BUS_WIDTH bits wide.
 *  m_data_valid      - Output data is valid when 1 (high).
 *  m_data_ready      - Core is ready to output data when 1 (high).
 *
 */
module tb_cocotb #(
    parameter BUS_WIDTH   = 8
  )
  (
    input                       clk,
    input                       rstn,
    input                       timeout,
    input                       enable,
    output                      m_data_tvalid,
    input                       m_data_tready,
    output  [BUS_WIDTH-1:0]     m_data_tdata,
    output                      m_data_tlast,
    input                       s_data_tvalid,
    output                      s_data_tready,
    input   [BUS_WIDTH-1:0]     s_data_tdata,
    input                       s_data_tlast
  );
  // fst dump command
  initial begin
    $dumpfile ("tb_cocotb.fst");
    $dumpvars (0, tb_cocotb);
    #1;
  end
  
  //Group: Instantiated Modules
  
  /*
   * Module: dut
   *
   * Device under test, holdbuffer
   */
  holdbuffer #(
    .BUS_WIDTH(BUS_WIDTH)
  ) inst_holdbuffer (
    .clk(clk),
    .rstn(rstn),
    .timeout(timeout),
    .enable(enable),
    .clear(1'b0),
    .s_data(s_data_tdata),
    .s_data_last(s_data_tlast),
    .s_data_valid(s_data_tvalid),
    .s_data_ready(s_data_tready),
    .s_data_ack(),
    .m_data(m_data_tdata),
    .m_data_last(m_data_tlast),
    .m_data_valid(m_data_tvalid),
    .m_data_ready(m_data_tready),
    .m_data_ack(1'b0)
  );
  
endmodule

