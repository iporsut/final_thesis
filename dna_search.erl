-module(dna_search).
-export([search/3,search_con/3,search/4,my_split/2,search_process/4,search_spawn2/5,resultback/2]).

my_split([],_,R) -> R;
my_split(List,N,R) when N > length(List) -> R++[List];
my_split(List,N,R) ->   {Take,Drop}  = lists:split(N,List),
			LastDrop = length(Take)+length(Drop),
		      if LastDrop =< N -> R ++ [Take];
			 true -> {_,Drop2} =  lists:split((N div 2),List),
				 my_split(Drop2,N,R ++ [Take])
		      end.

search(seq,FileName,S) -> [DNASeq] = read_file:readlines(FileName),search(S,DNASeq,[],1).
search_con(DNASubList,S,SPSize) -> search_spawn2(S,DNASubList,self(),0,SPSize),
				resultback(length(DNASubList),[]).

resultback(1,All) -> 	receive
				{finished,R} -> All++R
				
			end;
resultback(N,All) ->	receive
				{finished,R} -> resultback(N-1,All++R)
			end.

search_spawn2(_,[],_,_,_)-> io:format("spwan finished~n");
search_spawn2(S,[H|T],Parent_PID,N,SPSize)-> spawn(dna_search,search_process,[S,H,N*(SPSize div 2)+1,Parent_PID]),
				      search_spawn2(S,T,Parent_PID,N+1,SPSize).


search_process(S,List,N,Parent_PID) -> Parent_PID ! {finished,search(S,List,[],N)}.

search(_,[],R,_) -> R;
search(S,[H|T],R,N) -> G = lists:prefix(S,[H|T]),
			if G ->
				{_,Drop } = lists:split(length(S),[H|T]),	
				search(S,Drop,R++[N],N+length(S));
			 true->
				search(S,T,R,N+1)
			end.

