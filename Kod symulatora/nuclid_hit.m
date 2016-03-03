%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%

%
% Funkcja symulujaca uderzenie neutronu w jadro ciezkie.
% W takiej sytacji konieczne jest obliczenie prawdopodobienstwa rozszczepienia
% tego jadra w oparciu o charakterystyczny dla uzytego paliwa przekroj czynny
% (cross-section) bedacy suma przekrojow rozszczepienia i wychwytu.
% Poprzez sprawdzenie energii uderzajacego neutronu, jestesmy w stanie 
% sprawdzic czy dojdzie do rozszczepienia nuklidu czy nie.
% Funkcja przyjmuje parametry:
% 	- energia neutronu
% Funkcja zwraca:
%	1 - w przypadku gdy doszlo do rozszczepienia
%	2 - w przypadku gdy doszlo do wychwytu neutronu
%
function result = nuclid_hit (neutronEnergy)

	% Parametry funkcji regresji liniowej przekroju czynnego 
	a = -0.00009996;
	b0 = 1000;			% parametr dla funkcji regresji rozszczepienia
	b1 = 200;			% parametr dla funkcji regresji wychwytu

	tmp = 2;

	% Petla wykonuje uderzenie jadra i sasiednich 20-u jader, w nadzieji,
	% ze ktorys neutron zostanie wychwycony lub wywola rozszczepienie.
	for i=1:20,
		% Losowanie zdarzenia - rozszczepienie czy wychwyt z rozkladu jednostajnego
		event = get_random(3);

		% Losujemy prawdopodobienstwo w dziedzinie przekroju czynnego.
		prob = get_random(2);

		% Ustawiamy sztuczny prog prawdopodobienstwa wychwytu na 10%
		if event < 0.10,
			% Mamy do czynienia z wychwytem.

			% Obliczamy wedlug regresji liniowej wartosc prawdopodobienstwa
			% faktycznego dla tej energii przekroju wychwytu
			cross_section = (a * neutronEnergy + b1) / 1000;
			if (prob >= cross_section),
				% Zaszedl wychwyt
				tmp = 2;
				break;
			end
		else
			% Mamy do czynienia z rozszczepieniem.

			% Obliczamy wedlug regresji liniowej wartosc prawdopodobienstwa
			% faktycznego dla tej energii przekroju rozszczepienia
			cross_section = (a * neutronEnergy + b0) / 10000;
			if (prob >= cross_section),
				% Zaszlo rozszczepienie
				tmp = 1;
				break;
			end
		end
	end

	result = tmp;
	return;

endfunction