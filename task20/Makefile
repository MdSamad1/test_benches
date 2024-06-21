MODULE += mux4x1.sv
MODULE += tb/mux4x1_tb.sv


TOP += mux4x1_tb

vivado: clean 
	xvlog -sv ${MODULE} 
	xelab ${TOP} -s top 
	xsim top -runall

clean: 
	rm -rf xsim.dir *.log *.pb *.jou *.vcd *.wdb

.PHONY: clean vivado



