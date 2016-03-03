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
% Parametr wejsciowy:
% 	- T - obecna temperatura osrodka rdzenia
% Wartosc zwracana:
%	- E - energia wyemitowanego neutronu. Energia ta bedzie sie miescila
%			w zakresie mniej wiecej (0.5*10^-3, 5*10^8)
function E = emit_neutron (T)

	LOW_TEMP = 520;			% Dolna, standardowa temperatura pracy rdzenia.
	HIGH_TEMP = 1200;		% Gorna granicy pracy temperatury rdzenia jadrowego

	% Rozstep temperatury, niezbedny do przeskalowania funkcji temperatury.
	interval = HIGH_TEMP - LOW_TEMP;

	% Nalozenie losowosci na wartosc lokalnej temperatury w okolicach
	% powstajacego neutronu. Uzyty zostanie rozklad wykladniczy.
	temp = T * (0.95 + 0.1*get_random(3));

	A = -6.9077;
	B = 16.1181;
	dif = B - A;
	E = exp(A + abs(temp - LOW_TEMP)/interval * dif);

	% Zwazywszy, ze jest to reaktor dzialajacy na paliwie U235, ktore
	% lepiej jest wykorzystywane przez neutrony termiczne (o niskich energiach),
	% oraz, zwazajaz, ze w ukladzie znajduje sie moderator - musimy zrezygnowac
	% z duzej ilosci neutronow predkich i zredukowac gorna granice energii
	% z progu 10^7, na okolo 10^4.
	HIGH_ENERGY_BOUNDARY = 1e4;
	if (E > HIGH_ENERGY_BOUNDARY),
		E = HIGH_ENERGY_BOUNDARY * (0.8 + 0.2 * get_random(3));
	end

	return;
endfunction