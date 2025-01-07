	alias clc ".main clear"
	
	clc
	exec vlib work
	vmap work work
	
	set TB					"tb"
	set hdl_path			"../src/hdl"
	set inc_path			"../src/inc"
	
	set run_time			"300 us"
#	set run_time			"-all"

#============================ Add verilog files  ===============================
# buffer:
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer/buffer.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer/circular_buffer_datapath.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer/circular_buffer_controller.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer/circular_buffer.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer/empty_check.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer/full_check.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer/read_addr_gen.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer/read_ptr_update.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer/write_addr_gen.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer/write_ptr_update.v

#others:
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/adder.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/CNN_datapath.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/CNN.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/current_filter_start.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/decode_status.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/end_ptr.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/error_detector.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/filter_address_checker.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/filter_read_address_generator.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/filter_read_buffer_controller.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/filter_write_counter.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/filter_completion_detector.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/i_counter.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/finish_counter.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/if_read_buffer_controller.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/IFMap_read_address_generator.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/IFMap_status.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/IFMAP_write_counter.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/main_controller.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/multiplier.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/register_file.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/register.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/SRAM.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/start_ptr.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/stride_completion_detector.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/stride_step_counter.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/update_ifmap_end_ptr.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/write_buffer_controller.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/end_detector.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/go_next_filter.v
	vlog 	+acc -incr -source  +incdir+$inc_path +define+SIM 	./tb/$TB.v
	onerror {break}

#================================ simulation ====================================

	vsim	-voptargs=+acc -debugDB $TB


#======================= adding signals to wave window ==========================


	add wave -bin -group 	 	{TB}				sim:/$TB/*
	add wave -bin -group 	 	{top}				sim:/$TB/uut/*	
	add wave -bin -group -r		{all}				sim:/$TB/*

#=========================== Configure wave signals =============================
	
	configure wave -signalnamewidth 2

#====================================== run =====================================

	run $run_time 
	