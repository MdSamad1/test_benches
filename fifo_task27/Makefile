MODULE += syn_fifo.sv
MODULE += syn_fifo_tb.sv

TOP += syn_fifo_tb

vivado: clean 
	xvlog -sv ${MODULE} 
	xelab ${TOP} -s top 
	xsim top -runall

clean: 
	rm -rf *.dir *.log *.jou *.pb *.wdb *.vcd	

PHONY: vivado clean
