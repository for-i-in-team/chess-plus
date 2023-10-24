class_name PerformanceTracking

extends Node2D

var function_times = {};


func add_call_time(func_name:String, call_time:float):
	if (func_name not in function_times):
		function_times[func_name] = [];
	
	function_times[func_name].append(call_time);

func get_total_times():
	var total_times = {};
	for func_name in function_times:
		var total_time = 0;
		for time in function_times[func_name]:
			total_time += time;
		total_times[func_name] = total_time;
	return total_times;

func display_performance_summary(total:int):
	var performance_breakdown = function_times
	print("Performance Breakdown:\n")

	for key in performance_breakdown.keys():
		var min_val = 999999;
		var max_val = 0;
		var sum = 0;
		for call_time in performance_breakdown[key]:
			if call_time < min_val:
				min_val = call_time
			if call_time > max_val:
				max_val = call_time
			sum += call_time
		print("Function: " + key + " Calls: " + str(len(performance_breakdown[key])) + " Min: " + str(min_val) + " Max: " + str(max_val) + " Average: " + str(sum/performance_breakdown[key].size()) + " Total: " + str(sum) + " Percentage: " + str(sum/total * 100) + "%")
