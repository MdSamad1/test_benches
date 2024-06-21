MODULE += decoder3x8.sv
MODULE += tb/decoder3x8_tb.sv


TOP += decoder3x8_tb

vivado: clean 
	xvlog -sv ${MODULE} 
	xelab ${TOP} -s top 
	xsim top -runall

clean: 
	rm -rf xsim.dir *.log *.pb *.jou *.vcd *.wdb

.PHONY: clean vivado




