%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%

%
% Funkcja przeprowadzajaca symulacje komputerowa poprzez uruchomienie 
% reaktora, zainicjowanie pierwszego rozszczepienia wiazka neutronow a nastepnie
% monitorowanie przebiegu reakcji jadrowych wewnatrz rdzenia.
% Funkcja przyjmuje:
%	- parametr symulacji - stopien zanurzenia pretow sterujacych
% 		(control rods immersion) - Z w skali (0, 1),
% 		gdzie 0 - oznacza brak zanurzenia, a wiec brak kontroli reakcji,
% 		zas 1 - oznacza zanurzenie calkowite - wylaczenie reaktora.
%	- liczbe czastek na ktorych nalezy wykonac symulacje
%	- flaga okreslajaca czy zredukowac ilosc wyswietlanych informacji
% Funkcja zwraca:
%	t - wektor czasow dokonywania pomiarow pracy reaktora
%	E - wektor energii/ciepla wydzielonego w reaktorze w badanych chwilach
%	T - wektor temperatur rdzenia w badanych chwilach
% 	K - wektor wspolczynnikow mnozenia neutronow
%	N - wektor ilosci neutronow w danych pokoleniach
%	PU - uzyskana moc reaktora
% 	PS - szacowana moc reaktora
%	left - pozostala ilosc jader do rozbicia po zakonczeniu symulacji
%
function [t, E, T, K, N, PU, PS, left] = reactor_launch (Z, particles, quiet = false)

	LIGHT_SPEED = 299792458;
	UNIT_MASS = 1.6605e-25;
	OVER_CRITICAL_LEVEL = 1.16;

	% Zmienna regulujaca wlaczenie do symulacji scenariusza awarii reaktora.
	REACTOR_MAY_BREAKDOWN = (quiet == false);

	% Ustalamy maksymalny licznik ilosci iteracji testowania zachodzacych reakcji.
	% Wielkosc ta bedzie uzalezniona od podanej na wejsciu liczby czastek w paliwie.
	MAX_ITERATIONS = 4 * log2(particles);

	% Maksymalna temperatura jaka moze przyjac reaktor. Powyzej tej temperatury,
	% nastepuje awaryjne wylaczenie reaktora i przerwanie kaskad reakcji.
	% Wartosc liczbowa wyrazana w kelwinach.
	MAX_REACTOR_TEMPERATURE = 1200;

	% Zakladajac, ze sredni czas zycia jednego pokolenia neutronow termicznych
	% wynosi 10^-3 sekundy, bedziemy mogli okreslic ile czasu rzeczywistego
	% trwala reakcja w reaktorze jadrowym.
	GENERATION_PERIOD = 10^-3;


	noNeutrons = 0;				% Licznik sytuacji, w ktorej nie wytworzyly sie zadne
								% neutrony. Po trzech takich sytuacjach, reakcja
								% uznawana jest za wygaszona.
	timeOfReactions = 0;		% Calkowity czas przebiegajacej reakcji (rzeczywisty)
	gen = 1;					% Licznik pokolenia neutronow
	nuclidsLeft = particles;	% Pozostala ilosc czasteczek.
	fissions = 0;				% Ilosc rozszczepien jaka zaszla
	reactor_breakdown = false;	% Flaga oznaczajaca czy reaktor doznal awarii
								% i trwa procedura awaryjnego wylaczania.
	breakdown_gen = 0;			% Numer pokolenia podczas ktorego doszlo do awarii.

	% Poczatkowa temperatura rdzenia jadrowego
	currTemp = get_temperature(1, particles);

	% Inicjujemy wstepne rozbicia jader i emisje strumienia neutronow.
	[t(gen), E(gen), T(gen), sc] = initial_fission(currTemp, particles);
	N(1) = 1;
	prevNeutronsNum = 1;

	% W N-tym pokoleniu mamy maksymalnie 2^N neutronow powstalych na skutek 
	% rozszczepienia. Sprawdzimy kazdy z nich, czy koliduje, czy rozszczepia,
	% jest wychwytywyany czy tez ucieka.
	newNeutrons = 2 * sc;

	% Wyswietlamy informacje o rozpoczeciu symulacji.
	time_start = timestamp();

	if(quiet == false),
		fprintf("Rozpoczecie symulacji (czas: %s).\nZanurzenie pretow sterujacych: %d%%\n\n", 
				time_start, Z*100);
	end
  

	% Petla reakcji rozszczepien w reaktorze jadrowym. Numer iteracji petli
	% jest jednoczenie numere generacji. Licznik petli zostaje inkrementowany
	% co pewien krok.
	while (nuclidsLeft > 0 && MAX_ITERATIONS > 0),

		MAX_ITERATIONS--;

		kinEnergies = (1);			% Wektor energii poszczegolnych neutronow.
		numOfScatters = 0;			% Ilosc rozszczepien ktore zaszlo
		numOfCaptures = 0;			% Ilosc wychwytow
		numOfFlees = 0;				% Ilosc ucieczek neutronow
		numOfCollisions = 0;		% Ilosc kolizji z komponentami
		numOfRodHits = 0;			% Ilosc uderzen w prety sterujace

		if (reactor_breakdown == false && quiet == false),
			fprintf("\tTrwa pokolenie %d.\tPowstalo: %d neutronow.\n", gen, newNeutrons);
		end

		activeNeutrons = min(newNeutrons, nuclidsLeft);

		% Iterujemy po wytworzonych neutronach na skutek rozszczepien.
		% Zycie kazdego neutronu zostanie osobno zasymulowane.
		for i = 1:activeNeutrons,

			% Jesli rozbite zostaly wszystkie jadra - przerywamy akcje reaktora.
			% Paliwo sie wypalilo.
			if (nuclidsLeft <= 0), break; end

			if (reactor_breakdown == true),
				% Awaryjne opuszczanie pretow sterujacych
				Z += (50 / particles);
				if (Z > 1.0), break; end
			end

			% Dodajemy czas przebiegania tej konkretnej reakcji
			timeOfReactions += GENERATION_PERIOD * \
							(0.12 + (1 - abs(log(nuclidsLeft) / log(particles))));

			% Wyznaczenie obecnej temperatury ukladu na podstawie
			% ilosc czastek danego pokolenia bioracych udzial w reakcjach.
			restOfNeutrons = numOfRodHits + numOfCaptures + numOfCollisions;
			inum = 0;
			if( i - prevNeutronsNum > 0), inum = i - prevNeutronsNum; end
			neunums = prevNeutronsNum + inum + restOfNeutrons;
			currTemp = get_temperature(neunums, particles);

			% Emisja neutronu i wyznaczenie jego energii.
			neutronEnergy = emit_neutron(currTemp);

			% Imitacja przelotu przez moderator i pobranie informacji czy
			% sie rozbil, czy nie - w drugim przypadku zostanie pomniejszona jego
			% energia, na skutek odbicia.
			[event, energ] = passing_moderator(neutronEnergy, Z, 
												prevNeutronsNum, particles);

			% Sprawdzamy czy reaktor sie przepala.
			if (REACTOR_MAY_BREAKDOWN == true && 
				currTemp > MAX_REACTOR_TEMPERATURE && 
				reactor_breakdown == false),

				% Przepalanie ukladow reaktora, awaria! Nastepuje awaryjne
				% opuszczanie pretow sterujacych.

				reactor_breakdown = true;

				if(quiet == false),
					fprintf("\n[!] UWAGA! Nastapilo przekroczenie maksymalnej dopuszczalnej\n");
					fprintf("[!] temperatury rdzenia jadrowego. Uruchomiono procedure\n");
					fprintf("[!] automatycznego wylaczania reaktora.\n");
				end

				breakdown_gen = gen;
			end


			% Ten neutron doklada sie do bilansu ciepla ukladu reaktora
			kinEnergies(i) = energ;

			if (event == 1),
				% Ten neutron uciekl poza uklad, wiec nie doklada sie do bilansu
				% ciepla wewnetrznego ukladu reaktora jadrowego.
				kinEnergies(i) = 0;
				numOfFlees++;
			elseif (event == 2),
				numOfRodHits++;
			elseif (event == 3),
				numOfCollisions++;
			end

			if(event > 0) continue; end

			% Uderzenie w jadro ciezkie
			result = nuclid_hit(energ);

			if (result == 1),
				% Neutron spowodowal rozszczepienie jadra
				numOfScatters++;
				nuclidsLeft--;

			elseif (result == 2),	
				% Neutron zostal wychwycony przez jadro.
				% W takiej sytuacji jedynie podwyzszamy temperature ukladu rdzenia.
				numOfCaptures++;
			end
		end


		%
		% Przetwarzamy rozszczepienia ktore zaszly w ukladzie.
		%

		% Nastepnymi neutronami do przetworzenia beda te ktore teraz 
		% powstaly w wyniku rozszczepien. Z racji, ze kazdej reakcji 
		% rozszczepienia towarzyszy wydzielenie sie dwoch neutronow - 
		% mnozymy ten czynnik przez dwa.
		gen++;
		restOfNeutrons = numOfCollisions + numOfCaptures + numOfRodHits;

		% Obliczamy energie plynaca bezposrednio z deficytu masy rozszczepien
		[ener, deficit] = get_fission_energy();
		scattersEnergy = numOfScatters * ener;

		% Zapamietujemy wyniki tego pokolenia.
		N(gen) = activeNeutrons;
		E(gen) = sum(kinEnergies) + scattersEnergy;
		T(gen) = get_temperature(activeNeutrons + restOfNeutrons, particles);
		t(gen) = gen;
		
		% Zwiekszamy licznik rozszczepien.
		fissions += numOfScatters;

		currTemp = get_temperature(activeNeutrons, particles);
		newNeutrons = numOfScatters * 2;

		perc = (1 - nuclidsLeft / particles) * 100;
		prevNeutronsNum = (N(length(N)));

		if (prevNeutronsNum == 0),
			ktemp = 0.0001;
		else
			ktemp = newNeutrons / prevNeutronsNum;
		end

		K(gen) = ktemp;

		if (newNeutrons == 0),
			noNeutrons++;
			if (noNeutrons > 2),
				break;
			end
		elseif (newNeutrons <= 2),
			nuclidsLeft = 0;
			break;
		end

		state = "podkrytyczny";
		signs = "(+)";
		if (ktemp == 1.0),
			state = "Krytyczny";
			signs = "(-)";
		elseif (ktemp > 1.0 && ktemp < OVER_CRITICAL_LEVEL),
			state = "Lekko Nadkrytyczny";
			signs = "/!\\";
		else,
			state = "NADKRYTYCZNY";
			signs = "[X]";
		end

		if (reactor_breakdown == false && quiet == false),

			% Wyswietlamy informacje o tej generacji
			fprintf("\tIlosc neutronow: %d\tIlosc rozszczepien: %d\n", 
					prevNeutronsNum, numOfScatters);
			fprintf("(%3d%%)  Reszta neutronow: %d\tEnergia kin. neutronow: %.4f MeV\n", 
					perc, restOfNeutrons, E(gen)/1e6);
			fprintf("\tTemp. chwilowa: %d\tPozostalo jader: %d\n", T(gen), nuclidsLeft);
			fprintf("%s\tWsp. mnozenia: k=%.3f  Stan: %s\n", signs, ktemp, state);
			fprintf("\n");
		
		elseif (quiet == true),
			fprintf("(%3d%%)\r", perc);
		end
	end

	if (reactor_breakdown == true && quiet == false),
		fprintf("\n[!] Zakonczono awaryjne zamykanie reaktora.\n");
		fprintf("\tSzczytowa temperatura: %.3f\n", max(T));
	end

	left = nuclidsLeft;

	% Z uwagi na fakt, ze doszlo do awarii reaktora jadrowego, ta funkcja
	% symulacyjna musi jakos zwrocic te informacje do wywolujacej ja procedury
	% glownej. Ten fakt zostanie przekazany w postaci ujemnej liczby czasteczek
	% ktore pozostaly. Przekazujemy numer pokolenia w ktorym wystapila awaria.
	if (reactor_breakdown == true) left = -breakdown_gen; end

	time1 = abs(timeOfReactions) + 1e-8;

	% Obliczenie calkowitej energii uzyskanej podczas pracy reaktora,
	% oraz odpowiadajacej temu mocy reaktora.
	[en, deficit] = get_fission_energy();
	Q1 = fissions * deficit * UNIT_MASS * (LIGHT_SPEED**2);
	Q2 = sum(E) - Q1;
	power1 = (Q1 + Q2) / time1 / 1e6;

	% Normalizacja szacowanej mocy reaktora niezaleznie od ilosci czastek.
	power2 = 3 * power1 / 10^(floor(log10(power1))) * 1e2;

	PS = power2;
	PU = power1;

	% Statystyki po symulacji.
	if(quiet == false),
		fprintf("\nStatystyki symulacji:\n");
		fprintf("\tCzas rozpoczecia: %s\tCzas zakonczenia: %s\n", 
				time_start, timestamp());
		fprintf("\tIlosc rozszczepien: %d\tSr. energia neutronow: %.3f MeV\n", 
				fissions, mean(E) / 1e6);
		fprintf("\tSrednia temperatura: %.2f K\tSredni wsp. mnozenia: %.4f\n", 
				mean(T), mean(K));
		fprintf("\tMaksymalna temp.: %.2f K\tMaksymalny wsp. mnozenia: %.4f\n", 
				max(T), max(K));
		fprintf("\tMax. neutronow: %d\t\tIlosc pokolen: %d\n", max(N), gen-1);
		fprintf("\tHipotetyczny czas dzialania:\t%.4f sek\n", time1);
		fprintf("\tUzyskana moc reaktora:\t\t%.3f MW\n", power1)
		fprintf("\tSzacowana moc pracy reaktora:\t%.3f MW\n", power2);

		if (reactor_breakdown == true),
			fprintf("[!]\tDo awarii doszlo podczas %d pokolenia.\n", breakdown_gen);
		elseif (nuclidsLeft > 1),
			fprintf("\tPozostalo do rozszczepienia:\t%d jadra\n", nuclidsLeft);
			fprintf("[?]\t\tKaskada reakcji jadrowych samoczynnie wygasla.\n");
		else
			fprintf("[+]\t\tWypalono cale dostarczone paliwo.\n");
		end

		fprintf("\n");
	end
	return

endfunction
