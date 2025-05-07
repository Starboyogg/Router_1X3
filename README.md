# Router_1X3
RTL Design & Verification of a High-Performance 1x3 Network Router Using Verilog

This project focuses on the RTL design and verification of an optimized 1x3 network router using Verilog. The router is designed to handle packets with a structured format, comprising a header, payload, and parity bits. The core architecture includes a Finite State Machine (FSM), synchronized registers, and robust control logic to ensure reliable data flow. Data movement is efficiently managed through three FIFO buffers facilitating seamless interaction between the router’s input and three output ports.

Following an Engineering Change Order (ECO) update, significant architectural enhancements were implemented to greatly improve the performance over existing router designs available online. The enhanced design reduces latency by saving 2 clock cycles per data packet, resulting in a 30,000 ns time gain for each complete data in/out operation.

For large-scale data transfers, this performance boost becomes even more significant. When processing 1 million data packets, the updated router completes the task in approximately 1127 seconds, compared to 1159 seconds taken by existing designs—demonstrating a clear advantage in processing speed and time efficiency.

The design has been rigorously verified using comprehensive Verilog testbenches to ensure correct functionality, protocol compliance, and data integrity across all operational scenarios.

