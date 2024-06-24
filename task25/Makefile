MODULE +=
MODULE +=

TOP +=

vivado: clean
	xvlog -sv ${MODULE} 
	xelab ${TOP} -s top 
	xsim top -runall

clean: 
	rm -rf xsim.dir *.log *.pb *.jou

PHONY:	vivado clean
