# Makefile
IVERILOG = iverilog
VVP = vvp
TARGET = nvme_top_tb

all: $(TARGET).vcd

$(TARGET).vcd: $(TARGET).out
	$(VVP) $(TARGET).out

$(TARGET).out: nvme_top.v nvme_registers.v $(TARGET).v
	$(IVERILOG) -o $(TARGET).out nvme_top.v nvme_registers.v $(TARGET).v

clean:
	rm -f $(TARGET).out $(TARGET).vcd

.PHONY: all clean
