%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%

%
% Funkcja zwracjaca losowa liczbe w zaleznosci od wybranego rozklad
% prawdopodobienstwa.
% Parametr dist wybiera rozklad do uzycia:
%	0 - rozklad jednolity (uniform)
%	1 - rozklad normalny sztucznie przeniesiony do zakresu (0,1)
%	2 - rozklad Beta (2,2) w zakresie (0,1)
%	3 - rozklad wykladniczy sztucznie przeniesiony do zakresu (0,1)
% Funkcja zwraca wylosowana wartosc z zakresu (0,1).
function rnd = get_random (dist)

	% Dla kompatybilnosci z oprogramowaniem Matlab - rozklad beta
	% zostanie zamieniony na rozklad normalny
	if (dist == 2) dist = 3; end

	if (dist == 0),
		rnd = rand(1);
		
	elseif (dist == 1),
		rndtmp = abs(randn(1));
		if rndtmp > 4.0,
			rndtmp = 4.0;
		end
		rnd = (rndtmp / 4.0);

	elseif (dist == 2),
		%rnd = betarnd(2,2);

	elseif (dist == 3),
		rndtmp = rande();
		if rndtmp > 5.0,
			rndtmp = 5.0;
		end
		rnd = rndtmp / 5.0;
	end

	return;
endfunction