function rocketTF = createRocket()

R = 0.15; H = 1.2; Hn = 0.4;
rocketTF = hgtransform;

[Xc,Yc,Zc] = cylinder(R,30);
Zc = Zc * H;
surf(Xc,Yc,Zc,'FaceColor',[0.8 0.8 0.8],...
    'EdgeColor','none','Parent',rocketTF);

[Xn,Yn,Zn] = cylinder([R 0],30);
Zn = Zn * Hn + H;
surf(Xn,Yn,Zn,'FaceColor','red',...
    'EdgeColor','none','Parent',rocketTF);
end
