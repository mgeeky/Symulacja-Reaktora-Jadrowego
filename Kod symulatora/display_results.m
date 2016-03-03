%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%


%
% Funkcja majaca za zadanie dokonac prezentacji zebranych
% przez uzytkownika wynikow symulacji w postaci wykresow i komunikatow.
% Funkcja przyjmuje:
%	t - wektor czasow dokonywania pomiarow pracy reaktora
%	E - wektor energii/ciepla wydzielonego w reaktorze w badanych chwilach
%	T - wektor temperatur rdzenia w badanych chwilach
% 	K - wektor wspolczynnikow mnozenia neutronow
%	N - wektor ilosci neutronow w danych pokoleniach
%	PU - uzyskana moc reaktora
% 	PS - szacowana moc reaktora
%	left - pozostala ilosc jader do rozbicia po zakonczonej symulacji
%	Z - zanurzenie pretow sterujacych
%	p - ilosc jader w paliwie jadrowym
%	num - napis wchodzacy w sklad nazwy pliku dla wykresu
% 	quiet - flaga okreslajaca czy zredukowac ilosc wyswietlanych informacji
%
function display_results (t, E, T, K, N, PU, PS, left, Z, p, num = "1", quiet = false)

	HIGH_TEMP = 1200;
	OVER_CRITICAL_LEVEL = 1.16;

	% Tytuly wykresow:
	title1 = "Energii w pokoleniach E(t)";
	title2 = "Zaleznosc temp. od ilosci neutronow T(N)";
	title3 = "Mnoznik neutronow w pokoleniach K(t)";
	title4 = "Zaleznosci ilosci neutronow od temp. N(T)";
	title5 = "Ilosci neutronow w pokoleniach N(t)";

	% Nazwy osi dla poszczegolnych zmiennych:
	Nlabel = "Ilosc neutronow";
	Elabel = "Ener. kin. neutronow [eV]";
	Tlabel = "Temp. reaktora [K]";
	tlabel = "Numer pokolenia";
	Klabel = "Wsp. mnozenia neutronow";


	generations = numel(t);
	bfunc = (0);
	br = false;
	highTemp = (0);

	for i=1:generations,
		if(left < 0),
			br = true;
			bfunc(i) = abs(left); 
		else 
			bfunc(i) = 0;
		end
		highTemp(i) = HIGH_TEMP;
	end

	if (br), 
		tlabel = strcat(tlabel, " - (czerwona linia oznacza pokolenie awarii reaktora)");
	end

	if (quiet == true), 
		figure('visible', false);
	else
		figure('visible', true);
	end

	% Zapisujemy wykres do pliku.
	filename = strcat ("plots/plot_", num, ".png");
	print(filename, '-dpng', '-r300');

	hold all;

	% Wykres 1.
	subplot(3, 2, 1, "align");
	plot(t, E, bfunc, E, "r");
	title(title1);
	%xlabel(tlabel);
	ylabel(Elabel);

	% Wykres 2.
	subplot(3, 2, 2, "align");
	plot(N, T, N, highTemp, "--m");
	title(title2);
	axis([0 max(N)+60 500 HIGH_TEMP+60]);
	%xlabel(Nlabel);
	ylabel(Tlabel);

	% Wykres 3.
	subplot(3, 2, 3, "align");
	plot(t, K, t, ones(1, generations), bfunc, K, "r", t, 
		OVER_CRITICAL_LEVEL * ones(1, generations), "m");
	title(title3);
	%xlabel(tlabel);
	ylabel(Klabel);

	% Wykres 4.
	subplot(3, 2, 4, "align");
	plot(T, N, highTemp, N, "--m");
	title(title4);
	axis([500 HIGH_TEMP+60]);
	xlabel(Tlabel);
	ylabel(Nlabel);

	% Wykres 5.
	subplot(3, 2, 5, "align");
	plot(t, N, bfunc, N, "r");
	title(title5);
	xlabel(tlabel);
	ylabel(Nlabel);

	% Garsc informacji
	if (quiet == false),
		fprintf("Podsumowanie symulacji: '%s'\n", num);
		fprintf("----------------------\n");
		fprintf("Zanurzenie pretow sterujacych:\t\t%.1f%%\n", Z);
		fprintf("Ilosc jader w paliwie:\t\t\t%d\n", p);
		fprintf("Uzyskana moc reaktora:\t\t\t%.4f MW\n", PU);
		fprintf("Szacowana moc reaktora:\t\t\t%.4f MW\n", PS);
		fprintf("Srednia temperatura rdzenia:\t\t%.4f K\n", mean(T));
		fprintf("Maksymalna odnotowana temperatura:\t%.4f K\n", max(T));
		fprintf("Srednia energia kinetyczna neutronow:\t%.4f MeV\n", mean(E)/1e6);
		fprintf("Maksymalna energia kin. neutronow:\t%.4f MeV\n", max(E)/1e6);
		fprintf("Maksymalna ilosc neutronow w pokoleniu: %d\n", max(N));
		fprintf("Sredni wsp. mnozenia neutronow:\t\t%.5f\n", mean(K));
		fprintf("Odchylenie std. wsp. mnozenia:\t\t%.4f\n", std(K));
		fprintf("Maksymalny wsp. mnozenia neutronow:\t%.5f\n", max(K));

		[ktemp, occurs, c] = mode(K);
		state = "podkrytycznym";
		if (ktemp == 1.0),
			state = "krytycznym";
		elseif (ktemp > 1.0 && ktemp < OVER_CRITICAL_LEVEL),
			state = "lekko nadkrytycznym";
		else,
			state = "nadkrytycznym";
		end

		fprintf("Wiekszosc czasu reaktor pracowal w stanie %s.\n", state);

		if (left < 0),
			fprintf("Symulacja zakonczona awaria, pokolenie: %d\n", abs(left));
		elseif (left == 0),
			fprintf("Symulacja zakonczona wypaleniem paliwa. Sukces.\n");
		else
			fprintf("Symulacja zakonczona samoistnym wygaszeniem reakcji.\n");
		end
		fprintf("\n");
	end

	figure(1, 'name','Wyniki przeprowadzonej symulacji');

	return;
endfunction