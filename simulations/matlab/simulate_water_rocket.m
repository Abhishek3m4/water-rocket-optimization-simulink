function [Hmax, burnTime, tHist, H, V, T_hist] = ...
    simulate_water_rocket(fw, P0, plotMode)

%% ---------------- CONSTANTS ----------------
g = 9.81;
rho_w = 1000;
rho_air = 1.225;
gamma = 1.4;
Patm = 101325;

%% ---------------- PARAMETERS ----------------
Vb = 2e-3;
dn = 0.021;
Cd = 0.5;
Aref = pi*(0.05)^2;
mdry = 0.15;
An = pi*dn^2/4;

%% ---------------- INITIAL ------------------
mw = rho_w * fw * Vb;
Vair0 = Vb - mw/rho_w;

h = 0; v = 0; t = 0;
dt = 0.001; tmax = 10;

H = []; V = []; X = []; T_hist = []; tHist = [];
burnTime = 0;
angle = 30;

%% ---------------- SIM LOOP -----------------
while t < tmax

    m = mdry + mw;

    if mw > 0
        Vair = Vb - mw/rho_w;
        P = P0 * (Vair0/Vair)^gamma;

        if P > Patm
            ve = sqrt(2*(P-Patm)/rho_w);
            mdot = rho_w * An * ve;
            T = mdot * ve;
            burnTime = t;
        else
            T = 0; mdot = 0;
        end
        mw = max(mw - mdot*dt,0);
    else
        T = 0;
    end

    D = 0.5*rho_air*Cd*Aref*v^2*sign(v);
    a = (T - D - m*g)/m;

    v = v + a*dt;
    h = h + v*dt;
    t = t + dt;

    if isempty(X), x = 0;
    else, x = X(end) + v*cosd(angle)*dt;
    end

    H(end+1)=h; V(end+1)=v; X(end+1)=x;
    T_hist(end+1)=T; tHist(end+1)=t;

    if v <= 0 && t > 0.5
        break;
    end
end

Hmax = max(H);

%% ---------------- LIVE SIM -----------------
if plotMode == 2
    figure; hold on; grid on; axis equal;
    xlabel('X'); ylabel('Y'); zlabel('Height');
    title('Live 3D Water Rocket Simulation');
    view(45,25);

    rocketTF = createRocket();
    traj = plot3(0,0,0,'b','LineWidth',2);

    for k = 1:length(H)
        set(rocketTF,'Matrix',makehgtform('translate',[X(k),0,H(k)]));
        set(traj,'XData',X(1:k),'YData',zeros(1,k),'ZData',H(1:k));
        drawnow; pause(0.01);
    end
end
end
