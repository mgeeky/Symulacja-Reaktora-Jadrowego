%
% Projekt symulacji komputerowej Reaktora Jadrowego.
%
% Mariusz B., nr, 
% Uczelnia, 2014/2015
%

%
% Funkcja rozpoczynajaca symulacje komputerowa poprzez uruchomienie 
% reaktora i zainicjowanie pierwszego rozszczepienia wiazka neutronow.
%
function [energy, deficit] = get_fission_energy()

	URANIUM_MASS = 235.124;
	XENON_MASS = 135.951;
	MOLYBDENUM_MASS = 97.936;
	NEUTRON_MASS = 1.0086654;
	SPEED_LIGHT = 2.99792458e8;
	UNIT_MASS = 1.6605e-27;
	ELECTRONOVOLT = 1.602e-19;

	deficit = (URANIUM_MASS + NEUTRON_MASS) - \
				(XENON_MASS + MOLYBDENUM_MASS + 2*NEUTRON_MASS);

	energy = deficit * UNIT_MASS * (SPEED_LIGHT**2) / ELECTRONOVOLT / 1e6;

	return
endfunction