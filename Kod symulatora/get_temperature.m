%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%

%
% Funkcja wylicza temperature rdzenia jadrowego na podstawie ilosci
% neutronow w obecnym pokoleniu. Funkcja temperatury zostala wyznaczona
% orientacyjnie, by spelnic warunki wartosci krancowych, takich jak
% domyslna temperatura pracy reaktora oraz temperatura krytyczna, przy
% ktorej uszkodzeniu ulegaja koszulki pastylek paliwowych.
function temp = get_temperature(neutrons, PARTICLES)

	LOW_TEMP = 520;			% Dolna, standardowa temperatura pracy rdzenia.
	HIGH_TEMP = 1200;		% Gorna granicy pracy temperatury rdzenia jadrowego

	% Wyznaczamy tutaj, jaka ma byc wartosc mianownika we wzorze na temperature.
	% Wartosc ta okresla nam dla jakiej wartosci maksymalnie mozemy uzyskac
	% gorna wartosc temperatury. Innymi slowy, majac np. 1e5 czasteczek w symulacji,
	% obliczona zostanie wartosc mianownika na 40, dla 3e4 na 12, dla 2e6 - 800.
	% Ten parametr bedzie nam modelowal wykres temperatur w zaleznosci od maksymalnej
	% ilosci czasteczek.
	parts = 0.45*PARTICLES;					% ilosc czasteczek
	pow = floor(log10(parts))-4;			% relatywny wykladnik ilosci czast.
	msd = parts / (10^floor(log10(parts)));	% najbardziej znaczaca cyfra
	div = 4*(floor(msd)) * 10^(pow);		% parametr modelu, mianownik.

	% Rozstep temperatury, niezbedny do przeskalowania funkcji temperatury.
	interval = HIGH_TEMP - LOW_TEMP;

	neutrons *= 1.12;

	% Podejscia do znalezienia najbardziej optymalnej funkcji matematycznej
	% odpowiednio modelujacej wzrost temperatury w rdzeniu reaktora jadrowego.
	% Funkcja musi byc wolno rozsnaca, o przebiegu zblizonym do logarytmicznego.
	
	% 1. Podejscie pierwsze - zbyt duza wariancja, zwlaszcza dla wiekszych wartosci.
	%t1 = 70 * (7.5 + log(neutrons));
	
	% 2. Od liczby neutronow +/- 10.000 funkcja zwraca zbyt duza wartosc.
	% Tak wiec ten model jest niewlasciwy, gdyz ma zbyt duzy skok na poczatku dziedziny.
	%t1 = LOW_TEMP + (interval / log(MAX_PARTICLES)) * log(neutrons);

	% 3. Ponizsza funkcja zwraca IDEALNY zakres (LOW_TEMP, HIGH_TEMP).
	% Odkryta metoda prob i bledow przy szukaniu mnoznika dla parametru.
	% Przy pomocy WolframAlpha udalo sie dobrac odpowiedni, nastepnie przeskalowac
	% i przesunac wzgledem osi rzednych.
	t1 = LOW_TEMP + interval * tanh( (interval / div) * 10^-6 * neutrons);
	
	% Wprowadzamy dodatkowy non-determinizm dla temperatury,
	% wynoszacy N % odchylki.
	t2 = t1 * 0.08 * get_random(0);
	
	temp = t1 + t2;
	return;

endfunction