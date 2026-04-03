clc; clear; close all;

%% ==========================================================
% PARAMETRIC OPTIMIZATION + PROFESSIONAL PLOTTING
%% ==========================================================

water_frac   = 0.20:0.05:0.60;
pressure_bar = 3:0.5:7;
pressure     = pressure_bar * 1e5;

nw = length(water_frac);
np = length(pressure);

Hmax     = zeros(nw,np);
BurnTime = zeros(nw,np);

% Cell arrays to store time histories
TimeHist = cell(nw,np);
HeightHist = cell(nw,np);
VelHist = cell(nw,np);
ThrustHist = cell(nw,np);

%% =============== PARAMETRIC SWEEP =========================
for i = 1:nw
    for j = 1:np
        [Hmax(i,j), BurnTime(i,j), t, h, v, T] = ...
            simulate_water_rocket(water_frac(i), pressure(j), 0);

        TimeHist{i,j}   = t;
        HeightHist{i,j} = h;
        VelHist{i,j}    = v;
        ThrustHist{i,j} = T;
    end
end

%% ================= PARAMETER TABLE ========================
HeightTable = array2table(Hmax,...
    'VariableNames', strcat("P_", string(pressure_bar)),...
    'RowNames', strcat("Water_", string(water_frac)));

disp('===== MAX HEIGHT TABLE (m) =====');
disp(HeightTable);

%% ================= PRESSURE vs HEIGHT =====================
figure; hold on; grid on;
for i = 1:nw
    plot(pressure_bar, Hmax(i,:), '-o','LineWidth',1.8,...
        'DisplayName',sprintf('Water %.0f%%',water_frac(i)*100));
end
xlabel('Pressure (bar)');
ylabel('Maximum Height (m)');
title('Pressure vs Maximum Height');
legend('Location','northwest');

%% ================= MAX HEIGHT HEATMAP =====================
figure;
imagesc(pressure_bar, water_frac, Hmax);
set(gca,'YDir','normal');
colorbar;
xlabel('Pressure (bar)');
ylabel('Water Fraction');
title('Maximum Height Heatmap');
grid on;

%% ================= BURN TIME HEATMAP ======================
figure;
imagesc(pressure_bar, water_frac, BurnTime);
set(gca,'YDir','normal');
colorbar;
xlabel('Pressure (bar)');
ylabel('Water Fraction');
title('Burn Time Heatmap');
grid on;

%% ================= TIME HISTORY PLOTS =====================
for i = 1:nw
    figure;
    tiledlayout(3,1,'TileSpacing','compact');
    sgtitle(sprintf('Time Histories – Water Fraction %.0f%%',water_frac(i)*100));

    % Height
    nexttile; hold on; grid on;
    for j = 1:np
        plot(TimeHist{i,j}, HeightHist{i,j}, 'LineWidth',1.5);
    end
    ylabel('Height (m)');

    % Velocity
    nexttile; hold on; grid on;
    for j = 1:np
        plot(TimeHist{i,j}, VelHist{i,j}, 'LineWidth',1.5);
    end
    ylabel('Velocity (m/s)');

    % Thrust
    nexttile; hold on; grid on;
    for j = 1:np
        plot(TimeHist{i,j}, ThrustHist{i,j}, 'LineWidth',1.5);
    end
    ylabel('Thrust (N)');
    xlabel('Time (s)');

    legend(strcat(string(pressure_bar),' bar'),'Location','northeastoutside');
end

%% ================= OPTIMAL CONFIG =========================
[maxH, idx] = max(Hmax(:));
[row,col] = ind2sub(size(Hmax),idx);

fprintf('\n===== OPTIMAL CONFIGURATION =====\n');
fprintf('Water Fraction : %.2f\n',water_frac(row));
fprintf('Pressure       : %.2f bar\n',pressure_bar(col));
fprintf('Max Height     : %.2f m\n',maxH);
fprintf('================================\n');

%% ================= LIVE SIMULATION ========================
simulate_water_rocket(water_frac(row), pressure(col), 2);
