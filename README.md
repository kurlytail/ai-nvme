# NVMe Controller

This project implements a simple NVMe controller in Verilog for educational purposes. The controller supports basic read and write commands and a minimal register interface following the NVMe specification.

## Prerequisites

To build and run the testbench, you will need the following tools installed on your system:

- Icarus Verilog
- GTKWave (optional, for viewing simulation waveforms)

## Running the Testbench

To run the testbench, follow these steps:

1. Clone the repository:

```bash
git clone https://github.com/yourusername/nvme-controller.git
cd nvme-controller
```

2. Compile and run the testbench using the provided Makefile:

```bash
make
```

3. (Optional) View the simulation waveforms using GTKWave:

```bash
gtkwave nvme_top_tb.vcd
```

## License

This project is licensed under the terms of the MIT License. See [LICENSE.md](LICENSE.md) for details.
