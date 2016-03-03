%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%

%
% Funkcja zwraca string bedacy obecna godzina.
%
function time_string = timestamp()
	ts = now;
  	c = datevec(ts);
  	time_string = datestr(c, 13);
  	return
endfunction