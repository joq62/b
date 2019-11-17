%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(etcd_lib).
  


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
-define(ETS_NAME,etcd_ets).
%% External exports


-export([init/1,
	 read_all/0,
	 read_catalogue/0,read_catalogue/1,
	 read_machines/0,read_machines/1,
	 ip_addr/1,ip_addr/2,
	 zone/0,zone/1,capability/1,
	 get_all_nodes/0,
	 machine_capabilities/1
	]).


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
init(InitialConfiguration)->
    Result = case file:consult(InitialConfiguration) of
		 {ok,I}->
		     ?ETS_NAME=ets:new(?ETS_NAME, [bag, named_table]),
		     [{Type,Path}]=proplists:get_value(app_specs,I),
		     ok=app_specs_to_ets(Type,Path),
		     MachineList=proplists:get_value(machines,I),
		     ok=machines_to_ets(MachineList),
		     ok;
		 {error,Err}->
		     {error,[badrpc,Err,create_ets_listfile_consult,InitialConfiguration,?MODULE,?LINE]}
	     end,
    Result.


read_all()->
    ets:match(?ETS_NAME,'$1').

machines_to_ets(MachineList)->
    A=[{machine_info,MachineDef}||MachineDef<-MachineList],
    ets:insert(?ETS_NAME,A),
    ok.
app_specs_to_ets(dir,Path)->
    {ok,FileNames}=file:list_dir(Path),
    A=[file:consult(filename:join(Path,FileName))||FileName<-FileNames,".spec"==filename:extension(FileName)],
    AppSpecList=[{catalogue,proplists:get_value(specification,Info),Info}||{ok,Info}<-A],
    ets:insert(?ETS_NAME,AppSpecList),
    ok;
app_specs_to_ets(url,Url)->
    Url;
app_specs_to_ets(Undef1,Undef2) ->
    {error,[unmatched_signal,Undef1,Undef2,?MODULE,?LINE]}.

%%-------------------------------------------------------------------------------------
read_machines()->
    Result=case ets:match(?ETS_NAME,{machine_info,'$1'}) of
	       []->
		   {error,[no_machine_info,?MODULE,?LINE]};
	       Infos->
		   A=[Info||[Info]<-Infos],
		   {ok,A}
	   end,
    Result.
read_machines(Machine)->
    
    Result=case ets:match(?ETS_NAME,{machine_info,'$1'}) of
	       []->
		   {error,[no_machine_specs,?MODULE,?LINE]};
	       Infos->
		   A=[Info||[Info]<-Infos],
		   %glurk=A,
		   case lists:keyfind({machine_id,Machine},1,A) of
		       false->
			   {error,[no_machine_info,?MODULE,?LINE]};
		       MachineInfo->
			   {ok,MachineInfo}
		   end
	   end,
    Result.

read_catalogue()->
   % Result=case ets:match(?ETS_NAME,{catalogue,'$1','$2'}) of
    Result=case ets:match(?ETS_NAME,{catalogue,'$1','$2'}) of
	       []->
		   {error,[no_app_specs,?MODULE,?LINE]};
	       AppSpecs->
		   A=[{App,Info}||[App,Info]<-AppSpecs],
		   {ok,A}
	   end,
    Result.
read_catalogue(Application)->
    Result=case ets:match(?ETS_NAME,{catalogue,Application,'$1'}) of
	       []->
		   {error,[no_app_specs,?MODULE,?LINE]};
	       AppsInfo->
		   [[Info]]=AppsInfo,
		   {ok,Info}
	   end,
    Result.


    
get_all_nodes()->
     Result=case ets:match(?ETS_NAME,{{status,'_','_'},'$2','$1'}) of
	       []->
		   {error,[no_nodes,?MODULE,?LINE]};
	       Nodes->
		   A=[Node||[Node,_Status]<-Nodes],
		   {ok,A}
	   end,
    Result.

zone()->
    Result=case ets:match(?ETS_NAME,{{zone,'$1'},'$2','_'}) of
	       []->
		   {error,[no_zones,?MODULE,?LINE]};
	       Zones->
		   A=[{Node,Zone}||[Node,Zone]<-Zones],
		   {ok,A}
	   end,
    Result.
	       
zone(NodeStr)->
    Result=case ets:match(?ETS_NAME,{{zone,NodeStr},'$2','_'}) of
	       []->
		   {error,[no_zones,?MODULE,?LINE]};
	       [[Zone]]->
		   {ok,Zone}
	   end,
    Result.

   
capability(Capability)->
    Result=case  ets:match(?ETS_NAME,{{cap,Capability,'$1'},'$2','_'}) of
	       []->
		   {ok,[]};
	       EtsResult->
		   A=[{Node,Capability1}||[Node,Capability1]<-EtsResult],
		   {ok,A}
	   end,
    Result.

machine_capabilities(MachineId)->
    Result=case  ets:match(?ETS_NAME,{{cap,'_',MachineId},'$1','$2'})of
	       []->
		   {ok,[{MachineId,[]}]};
	       EtsResult->
		   A=[Caps||[Caps,_MId]<-EtsResult],
		   {ok,[{MachineId,A}]}
	   end,
    Result.

ip_addr(BoardId)->
    Result=case ets:match(?ETS_NAME,{{ip_addr,BoardId},'_',{'$3','$4'}}) of
	       []->
		   {error,[eexist,BoardId,?MODULE,?LINE]};
	       EtsResult->
		   A=[{IpAddr,Port}||[IpAddr,Port]<-EtsResult],
		   {ok,A}
	   end,
    Result.
ip_addr(IpAddr,Port)->
    Result=case ets:match(?ETS_NAME,{{ip_addr,'_'},'$1',{IpAddr,Port}}) of
	       []->
		   {error,[eexists,IpAddr,Port,?MODULE,?LINE]};
	       EtsResult->
		   A=[BoardId||[BoardId]<-EtsResult],
		   {ok,A}
	   end,
    Result.


%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
%filter_events(Key
