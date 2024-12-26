vsim work.execute_stage
add wave -position insertpoint sim:/execute_stage/*
force -freeze sim:/execute_stage/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/execute_stage/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/execute_stage/src1_addr 000 0
force -freeze sim:/execute_stage/src2_addr 001 0
force -freeze sim:/execute_stage/prev1_addr 011 0
force -freeze sim:/execute_stage/prev2_addr 010 0
force -freeze sim:/execute_stage/Rsrc1 0000000000000111 0
force -freeze sim:/execute_stage/Rsrc2 0000000000000101 0
force -freeze sim:/execute_stage/alu_forwarded_Rsrc1 0000000000000001 0
force -freeze sim:/execute_stage/alu_forwarded_Rsrc2 0000000000000010 0
force -freeze sim:/execute_stage/mem_forwarded_Rsrc1 0000000000000011 0
force -freeze sim:/execute_stage/mem_forwarded_Rsrc2 0000000000000110 0
force -freeze sim:/execute_stage/Imm 0000000000001110 0
force -freeze sim:/execute_stage/flags_in 0000 0
force -freeze sim:/execute_stage/in_port 0000000000001111 0
force -freeze sim:/execute_stage/flag_restore 1 0
force -freeze sim:/execute_stage/flags_in 0001 0
force -freeze sim:/execute_stage/alu_operation 000 0
force -freeze sim:/execute_stage/has_immidiate 0 0
force -freeze sim:/execute_stage/store_op 0 0
force -freeze sim:/execute_stage/input_enable 0 0
force -freeze sim:/execute_stage/output_enable 0 0
force -freeze sim:/execute_stage/jmp_type 00 0
force -freeze sim:/execute_stage/branch 0 0
force -freeze sim:/execute_stage/mem_read 0 0
force -freeze sim:/execute_stage/mem_write 0 0
run