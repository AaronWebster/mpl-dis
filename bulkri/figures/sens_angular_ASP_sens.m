ta = 55;
tb = 85; 
theta = linspace(ta,tb,1000);

% these two plots give you hints as to the range you should set in fminbnd
%plot(theta,abs(fresnel_asp_rp(theta,0)-fresnel_asp_rp(theta,0.001)))
%plot(theta,abs(fresnel_asp_tp(theta,0)-fresnel_asp_tp(theta,0.001)))

rp = fresnel_asp_rp(theta,0);
tp = fresnel_asp_tp(theta,0);
%tp = (tp-min(tp))./range(tp);
scalecone = (1-min(tp))./range(tp);
scalenotch = (1-min(rp))./range(rp);

dn = 0.00001;
tmin = fminbnd(@(x) -1.*abs(fresnel_asp_rp(x,0)-fresnel_asp_rp(x,dn)),67.5,71.5);
notchguy = scalenotch.*abs(fresnel_asp_rp(tmin,0)-fresnel_asp_rp(tmin,dn))./dn

tmin = fminbnd(@(x) -1.*abs(fresnel_asp_tp(x,0)-fresnel_asp_tp(x,dn)),67,71);
coneguy = scalecone.*abs(fresnel_asp_tp(tmin,0)-fresnel_asp_tp(tmin,dn))./dn

% 62.9853 for this guy

%plot(theta,abs(fresnel_asp_tp(theta,0)-fresnel_asp_tp(theta,dn)));