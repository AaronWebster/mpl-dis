ta = 62;
tb = 65; 
theta = linspace(ta,tb,1000);

rp = fresnel_ssp_rp(theta,0);
tp = fresnel_ssp_tp(theta,0);
%tp = (tp-min(tp))./range(tp);
scalecone = (1-min(tp))./range(tp);
scalenotch = (1-min(rp))./range(rp);

dn = 0.00001;
tmin = fminbnd(@(x) -1.*abs(fresnel_ssp_rp(x,0)-fresnel_ssp_rp(x,dn)),63.05,63.3);
notchguy = scalenotch.*abs(fresnel_ssp_rp(tmin,0)-fresnel_ssp_rp(tmin,dn))./dn

tmin = fminbnd(@(x) -1.*abs(fresnel_ssp_tp(x,0)-fresnel_ssp_tp(x,dn)),62.8,63.05);
coneguy = scalecone.*abs(fresnel_ssp_tp(tmin,0)-fresnel_ssp_tp(tmin,dn))./dn

% 62.9853 for this guy

%plot(theta,abs(fresnel_ssp_tp(theta,0)-fresnel_ssp_tp(theta,dn)));