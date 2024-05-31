# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, Timer

async def uart_decoder(rx, period):
    await FallingEdge(rx)

    await Timer(period//2)

    # Expecting start bit
    assert rx == 0

    # Sample 8 data bits
    val = 0
    for i in range(8):
        await Timer(period)
        val |= (rx.value << i)

    # Expecting stop bit
    await Timer(period)
    assert rx == 1
    return val

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 50 ns (20 MHz)
    clock = Clock(dut.clk, 50, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test GPIO as UART")

    expected = "SERV+Tinytapeout rocks!\n"
    for e in expected:
        rx = await uart_decoder(dut.gpio0, 5000000000000//70000)
        assert rx == ord(e)
        dut._log.info(f"Got: {e}")
