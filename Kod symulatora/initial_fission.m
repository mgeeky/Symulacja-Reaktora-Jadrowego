%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%

%
% Funkcja generujaca poczatkowy strumien neutronow, ktory rozpocznie kaskade
% rozszczepien jader ciezkich w paliwie. Generuje ona rowniez poczatkowa wartosc
% temperatury reaktora, poczatkowa jego energie (cieplo) 
% oraz poczatkowa ilosc neutronow wygenerowanych.
% zwracana wartoscia jest takze ilosc rozszczepien.
%
function [t, E, T, scatters] = initial_fission(T0, particles)

	% Poczatkowa wartosc chwilowa
	t(1) = 1;
	E(1) = 0;
	T(1) = 0;

	temp = T0;
	scatters = 0;

	% Emitujemy strumien neutronowo, jeden za drugim, zliczajac przy tym
	% ilosc wywolanych rozszczepien w pierwszej kaskadzie.
	for i=1:100,
		ener = emit_neutron(temp);	% Emisja neutronu
		event = nuclid_hit(ener);	% Symulacja uderzenia w jadro ciezkie

		temp = get_temperature(i, particles);
		if (event == 1),
			% Doszlo do rozszczepienia
			E(1) += ener;
			T(1) = temp;
			scatters++;
		end
	end
	return
endfunction