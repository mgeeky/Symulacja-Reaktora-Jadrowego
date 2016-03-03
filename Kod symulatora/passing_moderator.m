%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%

%
% Funkcja imitujaca przelot neutronu przez moderator, bedacy substancja
% pelniaca role osrodka zachodzenia reakcji. Substancja ta (np. ciezka woda)
% ma na celu spowolnienie neutronow - gdyz w przypadku paliwa U235 - wieksze jest
% prawdopodobienstwo rozszczepienie jadra neutronem, gdy ma on nizsza stosunkowo 
% predkosc (tzw. neutron termiczny).
% Parametry wejsciowe:
%	- neutronEnergy - energia neutronu przelatujacego
%	- Z - stopien zanurzenia pretow kontrolnych
%	- particles - ilosc czastek na ktorych przebiega symulacja
% Parametry wyjsciowe:
%	- event - zmienna opisujaca stan neutronu po wyjsciu z tej funkcji:
%				0 - neutron przelecial przez moderator
%				1 - neutron "uciekl"
%				2 - neutron zatrzymal sie na precie sterujacym
%				3 - neutron zostal pochloniety przez inne komponenty
%
function [event, E] = passing_moderator (neutronEnergy, Z, neutrons, particles)

	% Zgodnie z praktyka obserwowana w dzialaniu reaktorow PWR, aby zaszlo
	% 100 rozszczepien - potrzebne jest 256 neutronow. Wynika to z faktu, ze wiele
	% neutronow ulega pochlonieciu przez czynniki takie jak. prety sterujace,
	% reflektor, elementy budowy reaktora, itp.
	% W zwiazku z tym najpierw losujemy, czy w ogole ten neutron uderzy w to jadro
	% czy tez nie.
	x = 2*(log(neutrons) / log(particles));
	FACTOR = 2.56 * tanh(x);
	if(FACTOR <= 0) FACTOR = 1; end
	%NEUTRONS_HIT_RATIO = 1 / FACTOR;
	NEUTRONS_HIT_RATIO = 1;

	E = neutronEnergy;
	rnd = get_random(0);
	if (rnd > NEUTRONS_HIT_RATIO),
		event = 3;	% Niestety, ten neutron nie dotrze do jadra
		return;
	else

		% Redukujemy energie neutronu na skutek zderzenia pod losowym katem,
		% z czastkami moderatora (spowalniacza).
		% Kat odbicia losujemy z zakresu (0,110)
		hit_angle = get_random(0) * 110;				% kat losowy 

		if (hit_angle <= 10) || (hit_angle >= 100),
			% Uznajemy ze neutron ominal czasteczke moderatora. W takiej sytuacji
			% losujemy czy neutron ucieknie czy odbije sie od reflektora.
			if get_random(0) < 0.05,
				% Neutron uciekl.
				event = 1;
				return;
			else
				% Neutron odbija sie od reflektora. Nadajemy mu nowy kat odbicia.
				hit_angle = get_random(0) * 90;
			end
		end

		E = neutronEnergy * (0.8 + 0.2 * cos(hit_angle));

		% Neutron zostal odbity, stracil czesc energii (do 10%). Teraz sprawdzamy,
		% czy rozbije sie o prety sterujace.
		life_decision = get_random(0);

		% Prawdopodobienstwo uderzenia o pret sterujacy (z zakresu (1,103)%)
		control_rod_hit_probability = 0.40 * Z + (1 + (get_random(0) * 2))/100;
		
		if (life_decision > control_rod_hit_probability),
			% Neutron nie wpadl na prety sterujace.
			event = 0;
		else
			% Neutron uderzyl o pret sterujacy, ale byc moze sie od niego odbil.
			% Sprawdzamy to poprzez zinterpretowanie wylosowanego kata odbicia.
			% Z racji, iz kat odbicia losowany byl z zakresu (0,110),
			% mozemy przyjac, ze uderzenie w pret sterujacy wystepuje wylacznie w
			% przypadku katow z zakresu (10,100).
			if (hit_angle <= 10) || (hit_angle >= 100),
				event = 0;
			else
				event = 2;
			end
		end
	end	
	return;
endfunction