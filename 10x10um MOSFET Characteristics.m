% Script para Extracción de datos transistor 10x10um
clear; clc;
load('Datos_10x10.mat')                % Carga de datos
% Constantes Físicas
epsilon_vacio = 8.85e-14;              % Permitividad en el vacío [F/cm]
epsilon_Si = 11.68*epsilon_vacio;      % Permitividad Silicio [F/cm]
epsilon_ox = 3.9*epsilon_vacio;        % Permitividad del óxido [F/cm]
tox = 1.8e-7;                          % Grosor del óxido [cm]
% Datos del Transistor
W = 0.001;                             % Profundidad del Transistor [cm]
L = 0.001;                             % Longitud del Canal MOSFET [cm]
% ***** MÉTODO SPLIT C-V *****
% 1) Cálculo de Voltaje Umbral
Ids = interp1(Vg,Ids,Vgs);             % Extrapolación de Ids [A]
gm = interp1(Vg,gm,Vgs);               % Extrapolación de gm [1/Ohm]
Vg = Vgs;                              % Nuevo dominio de Vg [Volt]
Vds = 50e-3;                           % Tensión const aplicada a drain [V]
[max_gm, pos_gm_max] = max(gm);        % Obtención gm máximo y posición
vg_gmax = Vg(pos_gm_max);              % Vg donde se da gm máximo [V]
Id_gmax = Ids(pos_gm_max);             % Id donde se da gm máximo [A]
% El Vg donde se da la transconductancia máxima es de suma importancia
% para el cálculo de la pendiente de la recta que nos ayudará a encontrar
% el voltaje umbral Vth, para ello asumiremos que en Ids dado por este Vg
% sus puntos mas cercanos conocidos tienen tendencia lineal, por tanto
% los utilizaremos para el calculo de la pendiente
y2 = Ids(pos_gm_max+1);  % Punto siguiente conocido en Ids para pendiente
y1 = Ids(pos_gm_max-1);  % Punto anterior conocido en Ids para pendiente
x2 = Vg(pos_gm_max+1);   % Punto siguiente conocido en Vg para pendiente
x1 = Vg(pos_gm_max-1);   % Punto anterior conocido en Vg para pendiente
m = (y2-y1)/(x2-x1);     % Cálculo de la pendiente de la recta
b = Id_gmax-m*vg_gmax;   % Cálculo del desplazamiento de la recta
y = m*Vg + b;            % Ecuación de la recta de interés
[min_recta, pos_VSi] = min(abs(y)); % Cruce con eje X de recta y posición
Vth = Vg(pos_VSi) - Vds/2;          % Cálculo Voltaje Umbral
% 2) Cálulo de la movilidad
Cgc = Cgc-min(Cgc);       % Eliminación de Capacitancias Parásitas
Qinv = cumtrapz(Vgs,Cgc); % Calculo de Carga de Inversión [F]
u_eff = (L/W)*(1/Vds*1e-6)*(Ids./Qinv); % Cálculo de Movilidad efectiva
u_eff(1) = 0;             % Arreglo (La primera división es inf)
E_eff = Qinv/epsilon_Si;  % Cálculo de Campo Efectivo
[u_eff_max, pos_ueffm] = max(u_eff); % Valor pico de la movilidad
% 3) Cálculo de Cox
[cgc_max, pos_cgcm] = max(Cgc);
Cox = cgc_max/(W*L);      % Cálculo de Capacitancia óxido   
% 4) Cálculo de Cinv, tinv y EOT
Cinv = Cox;               % Calculo de Cinv = Cox 
tinv = tox;               % Cálculo de tinv = tox
EOT = tinv - 4e-10;       % tinv - 4 Amstrongs
% 5) Cálculo de Swing
IDlog = log(Ids);
[Ids_min, pos_start] = min(Ids);
rango = pos_VSi-1-pos_start;
pos_mid = round(rango+rango/2);
y2s = IDlog(pos_mid+1);    % Punto siguiente conocido en Ids para pendiente
y1s = IDlog(pos_mid-1);    % Punto anterior conocido en Ids para pendiente
x2s = Vg(pos_mid+1);       % Punto siguiente conocido en Vg para pendiente
x1s = Vg(pos_mid-1);       % Punto anterior conocido en Vg para pendiente
ms = (y2s-y1s)/(x2s-x1s);  % Cálculo de la pendiente de la recta
bs = IDlog(pos_mid)-ms*Vg(pos_mid);   % Cálculo del desplazamiento de la recta
k = 1;
for i= pos_start : pos_VSi-1
  Vgss(k) = Vgs(i);
  k = k+1;
end
ys = ms*Vgss + bs;            % Ecuación de la recta de interés
% ****** MÉTODO DE FUNCIÓN Y ******
ID_inv = 1./Ids;              % Función Inversa de ID
dev1 = gradient(ID_inv,Vgs);  % Primera derivada de 1/ID   
dev2 = gradient(dev1,Vgs);    % Segunda derivada de 1/ID
Vgh = Vgs-Vth;
beta = 2./(dev2.*Vds.*Vgh.^3);       % Cálculo de Ganancia
Y_F = Ids./sqrt(beta);               % Función Y
theta2 = dev1.*beta.*Vds+(1./Vgh.^2);
theta1 = beta.*(Vds./Ids)-(1./Vgh)-theta2;
u_eff2 = 1./(1+(theta1.*Vgh)+(theta2.*Vgh.^2)); % Movilidad por FY
u_eff2 = 1./u_eff2 + u_eff_max;
% Gráficas de resultados
figure(1);
plot(Vg,gm,'b'); hold on; grid on;
plot(Vg,Ids,'r'); plot(Vg,y,'k');
plot(vg_gmax,max_gm,'k*')
plot(vg_gmax,Id_gmax,'k*')
plot(Vth,0,'k*');
line([vg_gmax vg_gmax],[0 max_gm],'Color','black','LineStyle','-.');
text(vg_gmax,max_gm+(max_gm/20),strcat('gm(max)=',num2str(max_gm,3)));
text(vg_gmax,Id_gmax-(Id_gmax/15),strcat('Id(gmax)=',num2str(Id_gmax,3)));
text(vg_gmax,15*min(abs(y)),strcat('Vg(gmax)=',num2str(vg_gmax,3)));
text(Vth,-15*min(abs(y)),strcat('Vth=',num2str(Vth,3)));
xlabel('Voltaje VGS [Volt]'); ylabel('Corriente IDS y gm [A] y [1/Ohm]');
legend('gm','Ids','Location','southeast'); title('Obtención de Vth');
saveas(gcf,'vth.png')
figure(2);
subplot(1,2,1)
plot(Vgs,Cgc,'b'); hold on; grid on; plot(Vgs,Qinv,'r');
text(0,max(Cgc)/2,strcat('Cox=',num2str(Cox)));
xlabel('Voltaje VGS [Volt]'); ylabel('Capacitancia [F] y Carga [C]');
legend('Cgc','Q inversión','Location','southeast'); title('Cálculo Qinv');
subplot(1,2,2)
plot(E_eff,u_eff,'b'); grid on; hold on;
plot(E_eff(pos_ueffm),u_eff_max,'k*');
plot(E_eff(pos_ueffm),0,'k*');
text(E_eff(pos_ueffm),u_eff_max+(u_eff_max/20),strcat('Ueff_p_e_a_k=',num2str(u_eff_max,4)));
text(E_eff(pos_ueffm),u_eff_max/10,strcat('Eeff(umax)=',num2str(E_eff(pos_ueffm),3)));
xlabel('Eeff [MV/cm]'); ylabel('ueff [cm^2/Vs]');
legend ('ueff','Location','southwest'); title('Movilidad Efectiva');
saveas(gcf,'movilidad.png')
figure(3);
semilogy(E_eff,u_eff2,'r'); grid on; hold on;
semilogy(E_eff,u_eff,'b');
semilogy(E_eff(pos_ueffm),u_eff_max,'k*');
xlabel('Eeff [MV/cm]');
ylabel('ueff [cm^2/Vs]'); legend('Función Y','Split C-V');
title('Comparativa de la movilidad Split C-V Vs Función Y');
text(E_eff(pos_ueffm),u_eff_max-(u_eff_max/2),strcat('Ueff_p_e_a_k=',num2str(u_eff_max,4)));
saveas(gcf,'movilidadY.png')
figure(4);
subplot(1,2,1);
semilogy(E_eff,theta1,'r'); grid on; hold on;
xlabel('Eeff [MV/cm]'); ylabel('theta1 [cm^2/Vs]');
title('Movilidad de Factor Lineal');
subplot(1,2,2);
semilogy(E_eff,theta2,'b'); grid on; hold on;
xlabel('Eeff [MV/cm]'); ylabel('theta2 [cm^2/Vs]');
title('Movilidad de Factor cuadrático');
saveas(gcf,'movilidades.png')
figure(5);
semilogy(Vgs,IDlog,'r'); grid on; hold on;
semilogy(Vgs(pos_mid),IDlog(pos_mid),'k*');
semilogy(Vgss,ys,'b'); xlabel('VG [Volts]'); ylabel('log(ID)');
title('Obtención de Swing');
saveas(gcf,'swing.png');