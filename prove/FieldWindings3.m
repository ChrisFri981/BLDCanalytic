% From Zhu - Instantaneous magnetic field distribution in brushless permanent magnet DC motors - Part II - Armature-Reaction Field


% semplificazione del gruppo_sin con il valore 3 separatamente per v/p+u e
% v/p-u

% clear all
close all
clc

% load CurrentHarmonics.mat

load('motor_data.mat')
omega_r = 1500/60*2*pi;

if strcmp(windoverlap,'overlapping')
    fatt = 6;
elseif strcmp(windoverlap,'nonoverlapping')
    fatt = 3;
end





%% find nontriplen odd harmonics of current
cont2 = 0;
for cont = 1:25
    if ( rem(cont,2) && rem(cont,3) ) % check if it's not multiple of 2 or 3
        cont2 = cont2+1;
        u_array(cont2) = cont;          % then add it in the array
    end
end


%% initialize matrixes
% I_array = 0:1/(length(u_array)-1):1;
% I_array = fliplr(I_array);
% I_array = [0.8 0.3 0.1 0.05 0 0 0 0 0];
theta_u_array = zeros(length(I_array),1);

r = Rs;
t = 0;

cont = 0;
for alfa = 0:pi/500:2*pi
    cont = cont+1;
    %% calc field generated by windings
    B_wind = 0;
    for u_index = 1:length(u_array) % current harmonics index

        u = u_array(u_index);
        theta_u = theta_u_array(u_index);
        I = I_array(u_array(u_index));

        sum_v = 0;
        for v = 1:1:100 % harmonics index
            if (~rem(v/p+u,fatt)) || (~rem(v/p+u,fatt))
                Ksov = sin(v*b0/2/Rs) / (v*b0/2/Rs); % slot-opening factor
                Kdv = sin(q*v*pi/Qs) / (q*sin(v*pi/Qs)); %winding distribution factor (equation valid only if q is integer)
                Kpv = sin(v*alfa_y/2);
                Kdpv = Kdv*Kpv;
                Fv = delta*v/r*(r/Rs)^v * (1+(Rr/r)^(2*v))/(1-(Rr/Rs)^(2*v));
                if (~rem(v/p+u,fatt))
                    sum_v = sum_v + Ksov*Kdpv*Fv/v * sin( u*p*omega_r*t + v*alfa -(v/p+u)*2/3*pi);
                end
                if (~rem(v/p-u,fatt))
                    sum_v = sum_v + Ksov*Kdpv*Fv/v * sin( u*p*omega_r*t - v*alfa +(v/p-u)*2/3*pi);
                end
            end
        end
        B_wind = B_wind + I * sum_v;
    end
    B_wind = B_wind * mi0*3*W/pi/delta;
    B_array(cont,:) = [alfa, r ,t , B_wind];
end

figure('Name','Windings field','NumberTitle','off');
plot(B_array(:,1)*180/pi,B_array(:,4),'-x','MarkerSize',3);
set(gca,'XTick', B_array(1,1):30:B_array(end,1)/pi*180+1);
set(gca,'XGrid','on')
set(get(gca,'XLabel'),'String','\alpha: angular position [�]');
set(get(gca,'YLabel'),'String','B: magnetic field [T]');
title('Magnetic field by windings','FontSize',13)
linex = get(gca,'XLim'); line(linex,[0 0],'LineStyle',':','Color','k');
