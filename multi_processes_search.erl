-module(multi_processes_search).
-export([search_bin/2,search_process/4,multi_processes_search/5,count/3]).

multi_processes_search(BinList,Sub,N,S,C) 
	when (S+N) >= byte_size(BinList) ->
		spawn(?MODULE,search_process,[self(),binary:part(BinList,S,byte_size(BinList)-S),Sub,S]),
		merge_result(C+1,[]);
multi_processes_search(BinList,Sub,N,S,C) ->
	spawn(?MODULE,search_process,[self(),binary:part(BinList,S,N),Sub,S]),
	multi_processes_search(BinList,Sub,N,S+(N div 2),C+1).

merge_result(0,R) -> R;

merge_result(C,R) ->
	receive
		IndexList -> merge_result(C-1,lists:umerge(R,IndexList))
	end.

search_process(Parent,BinList,Sub,Offset) -> 
	Parent ! lists:map(fun({X,_}) -> X+Offset end,binary:matches(BinList,[Sub],[])).

search_bin(BinList,Sub) -> 
	lists:map(fun({X,_}) -> X end,binary:matches(BinList,[Sub],[])).

count(N1,N2,C)
    when N1 =< N2 ->
        C+1;
count(N1,N2,C) ->
    count(N1-(N2 div 2),N2,C+1).
