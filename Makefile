IVERILOG := iverilog
VVP := vvp

all: nvme_top_tb.out

nvme_top_tb.out: nvme_top.v nvme_registers.v nvme_top_tb.v nvme_cq.v nvme_sq.v
	$(IVERILOG) -g2012 -o $@ $^

tests: nvme_registers_tb.out

nvme_registers_tb.out: nvme_registers.v nvme_registers_tb.v
	$(IVERILOG) -g2012 -o $@ $^
	$(VVP) $@

clean:
	rm -f nvme_top_tb.out nvme_registers_tb.out

.PHONY: all tests clean
