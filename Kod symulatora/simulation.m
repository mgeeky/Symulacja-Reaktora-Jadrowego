%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%


%
% Glowna funkcja programu, majaca za zadanie uruchamienie symulacji.
% Wykona ona symulacje dla wielu kombinacji parametrow wejsciowych po to, by
% znalezc najbardziej optymalne.
%
function simulation (particles = -1, controlRodsImmersion = -1)

	DEFAULT_PARTICLES_NUM = 1e4;
	HIGH_TEMP = 1200;
	Z = 0.25;

	% Pobieramy godzine poczatku symulacji
	simu_start = timestamp();
	full_simulation = false;

	% Uruchomienie zapisywania przebiegu symulacji do pliku
	diary("simulation_log.txt");

	fprintf("\tSymulacja komputerowa pracy Reaktora Jadrowego.\n");
	fprintf("\tMariusz B., 2014/15, Uczelnia.\n\n");

	fprintf("Reakcja chemiczna rozszczepien jadrowych:\n");
	fprintf("\tU235 + n -> U236 -> Mo98 + Xe136 + 2n\n");
	
	[energy, deficit] = get_fission_energy();
	fprintf("\tDeficyt masy po rozszczepieniu: %f unitow\n", deficit);
	fprintf("\tEnergia rozszczepienia jednego atomu Uranu-235: %f MeV\n\n", energy);

	% Sprawdzamy parametry podane przez uzytkownika i w razie ich braku
	% nadajemy domyslne wartosci dla symulacji pogladowej.

	if (particles < 0),
		particles = DEFAULT_PARTICLES_NUM;
	elseif (particles == 0)
		particles = DEFAULT_PARTICLES_NUM;
		full_simulation = true;
	end

	if(controlRodsImmersion >= 0) Z = controlRodsImmersion; end

	if (full_simulation == false),

		% Uruchamiamy pojedyncza symulacje z podanymi przez uzytkownika 
		% parametrami, lub przyjetymi domyslnie. Po skonczonym jej dzialaniu,
		% prezentujemy uzytkownikowi zebrane dane.
		[t, E, T, K, N, PU, PS, partsLeft] = reactor_launch(Z, particles);
		display_results(t, E, T, K, N, PU, PS, partsLeft, Z, particles);

	else
		% Wykonujemy pelen przeglad wynikow symulacji dla kolejnych wartosci
		% zanurzenia pretow sterujacych.
		first_breakdown = false;
		breakdown_val = 0;

		n = 0;
		max_PU = 0;

		% Bedziemy iterowac na kolejnych potegach liczby 10, tak by 
		% uzyskiwac kolejne rzedy wielkosci dla rozpatrywanych ilosci czastek
		% w paliwie reaktora.
		MIN_EXPONENT = 3;
		MAX_EXPONENT = 5;
		maxN = (1/step) * (MAX_EXPONENT - MIN_EXPONENT);
		step = 0.01;

		for m=MIN_EXPONENT:MAX_EXPONENT,
			
			particles = 10^m;

			% Ta petla bedzie iterowala na kolejnych wartosciach procentowych
			% zanurzenia sie pretow sterujacych.
			for i = 0:step:1,
				n += 1;
				Z = i;

				fprintf("m=%d / %d, %d / %d (i=%.2f), n=%d / %d\n", 
						m, 6, (i/step), (1/step), i, n, maxN);

				% Uruchamiamy symulacje pracy reaktora.
				[t, E, T, K, N, PU, PS, partsLeft] = reactor_launch(Z, particles, true);

				% Jesli jest to jak dotad najlepszy wynik dzialania reaktora,
				% dla zadanego zanurzenia - rejestrujemy go by pozniej wyswietlic
				% ten wynik.
				if (PU > max_PU && (partsLeft >= 0) && max(T) < HIGH_TEMP),
					max_PU = PU;
					vec_t = t;
					vec_E = E;
					vec_T = T;
					vec_K = K;
					vec_N = N;
					vec_Z = Z;
					vec_PU = PU;
					vec_PS = PS;
					vec_left = partsLeft;
				end

				display_results(t, E, T, K, N, PU, PS, partsLeft, Z, particles,
							sprintf("%d_%d_%d_%d", m, (i/step), (1/step), Z*100));
			end

			fprintf("\nPREZENTACJA NAJLEPSZEGO WYNIKU DZIALANIA SYMULACJI.\n");
			fprintf("Liczba czastek: %d\n\n", particles);

			% Zebralismy wyniki. Czas je zaprezentowac.
			display_results(	vec_t, vec_E, vec_T, 
							vec_K, vec_N, vec_PU, 
							vec_PS, vec_left, vec_Z, particles,
							sprintf("%d_%d", m, vec_Z*100));

		end
	end

	fprintf("Symulacja trwala od: %s do %s\n", simu_start, timestamp());
	fprintf("Koniec symulacji.\n");
	diary off;
	return;

endfunction