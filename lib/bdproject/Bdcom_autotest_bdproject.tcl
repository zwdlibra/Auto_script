# Bdcom_autotest_bdproject.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

variable global_config_files
array set global_config_files {}

variable global_current_module_name ""

variable global_current_project_name ""

variable global_current_tc_name ""

variable global_module_proc_prefix ""

variable global_module_tc_included {}

variable global_module_var
array set global_module_var {}

variable global_project_module_included {}

variable global_project_topo_DUT_array
array set global_project_topo_DUT_array {}

variable global_project_topo_TESTER_array
array set global_project_topo_TESTER_array {}

variable global_project_topo_tm_DUT_TESTER_array
array set global_project_topo_tm_DUT_TESTER_array {}

variable global_project_topo_tm_PORT_array
array set global_project_topo_tm_PORT_array {}

variable global_project_topotypes_included {}

variable global_project_var
array set global_project_var {}

variable global_projects_project_included {}

variable global_result
array set global_result {}

variable global_tclist_from_tc_in_module {}

variable global_tc_var
array set global_tc_var {}

variable global_testcase_topo_required ""

variable global_topotypes_mapping_included
array set global_topotypes_mapping_included {}
