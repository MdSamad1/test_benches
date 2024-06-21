MODULE += gray_to_binary.sv
MODULE += gray_to_binary_tb.sv


TOP += gray_to_binary_tb

vivado: clean 
	xvlog -sv ${MODULE} 
	xelab ${TOP} -s top 
	xsim top -runall

clean: 
	rm -rf xsim.dir *.log *.pb *.jou *.vcd *.wdb

.PHONY: clean vivado


