{specification, new_test_app}.
{type,application}.
{description, "Specification file for application template" }.
{vsn, "1.0.0" }.
{service_def,[[{service,"t1_service"},{dir,path_t1_service},{machine,"machine_w1@asus"}],
	      [{service,"t2_service"},{git,url_t2_service},{machine,[]}],
	      [{service,"t1_service"},{dir,path_t1_service},{machine,"machine_w1@asus"}]]}.
