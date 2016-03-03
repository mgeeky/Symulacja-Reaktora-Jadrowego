%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%

%
% Procedura wykorzystana na potrzeby szukania modelu parametru okreslajacego
% prawdopodobienstwo rozbicia sie neutronu na komponentach rdzenia jadrowego,
% takich jak: prety sterujace, elementy konstrukcji, reflektor i inne.
% Ten parametr, ma malec na przedziale (1, 1/2.56), gdzie 2.56 to powszechny 
% wspolczynnik utraty neutronow w paliwie U235 w reaktorach typu PWR.
% Innymi slowy - ten program wylicza wspolczynniki i symuluje metoda Monte Carlo
% ile neutronow rozbije sie przy wyliczonym progu. 
% Program ten pozwolil na znalezienie najbardziej sprzyjajacego modelu funkcji
% rozbic neutronow. Bardzo pomogl w pracy nad symulacja reaktora.
function test_factor()

	% Iterujemy na kolejnych potegach liczby neutronow.
	st = 4;
	en = 4;
	for i=st:en

		% Ustalamy maksymalna liczbe neutronow dla tej iteracji.
		PARTICLES = 10^i;
		x(1)=0;
		n = 0;

		% Wyliczamy krokowe ilosci neutronow w hipotetycznych pokoleniach.
		for j=1:0.2:i
			n++;

			% Tutaj jest implementacja funkcji wygladzajacej stosunek
			% neutronow ktore beda sie rozbijac na komponentach. Modelowanym
			% parametrem jest NEUTRONS_HIT_RATIO.
			neutrons = 0.75 * floor(10^(j))-1;
			%PARTICLES;
			x = 2*(log(neutrons) / log(PARTICLES));
			FACTOR = 2.56 * tanh(x);
			NEUTRONS_HIT_RATIO = 1 / FACTOR;
			
			x(n) = n;
			y1(n) = NEUTRONS_HIT_RATIO;
			y2(n) = FACTOR;
			
			% Za pomoca metody Monte Carlo, wyliczamy ile neutronow, przy obecnym
			% modelu, rozbilo by sie na komponentach reaktora. Pozwala to oszacowac,
			% jak model sprawuje sie w praktyce.
			hit = 0;
			for k=1:neutrons,
				prob = get_random(0);
				if (prob > NEUTRONS_HIT_RATIO),
					hit++;
				end
			end

			nums(n) = hit;
			kfact = 1;

			% Szukamy pierwszej niezerowej ilosci neutronow ktore sie rozbily
			% na komponentach, po to by wyznaczyc obecny wspolczynnik mnozenia.
			for m=2:n,
				if nums(n-1) > 0,
					kfact = nums(n) / nums(n-1);
					break;
				end
			end
			ks(n) = kfact;

			% Wyswietlamy dane.
			fprintf("i,j=%d,%d, p=%.1e, n=%d, f=%.2f, r=%.2f, hits=%d, k=%.3f\n",
					i, j, PARTICLES, neutrons, FACTOR, NEUTRONS_HIT_RATIO, hit, kfact);
		end

		subplot(2, 2, 1);
		plot(x, y1);
		title("Prawdopodobienstwo unikniecia rozbicia");

		subplot(2, 2, 2);
		plot(x, y2);
		title("Ilosc neutronow na jedno rozszczepienie");

		subplot(2, 2, 3);
		plot(x, nums);
		title("Liczba neutronow rozbitych");

		subplot(2, 2, 4);
		plot(x, ks);
		title("Wsp. mnozenia k");

		if(en-st > 0) input("Wcisnij ENTER."); end

	end

endfunction