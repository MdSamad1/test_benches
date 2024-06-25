MODULE += moore_o_1010.sv
MODULE += moore_o_1010_tb.sv

TOP += moore_o_1010_tb

vivado: clean
	xvlog -sv ${MODULE} 
	xelab ${TOP} -s top 
	xsim top -runall

clean: 
	rm -rf xsim.dir *.log *.pb *.jou

PHONY:	vivado clean
