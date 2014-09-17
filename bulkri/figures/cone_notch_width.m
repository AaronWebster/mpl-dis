%% compare the cone and notch widths for ASPs and SSPs

%% first ASP
ta = 55;
tb = 85; 
theta = linspace(ta,tb,10000);

% these two plots give you hints as to the range you should set in fminbnd
%plot(theta,abs(fresnel_asp_rp(theta,0)-fresnel_asp_rp(theta,0.001)))
%plot(theta,abs(fresnel_asp_tp(theta,0)-fresnel_asp_tp(theta,0.001)))

rp = fresnel_asp_rp(theta,0);
tp = fresnel_asp_tp(theta,0);
tp = (tp-min(tp))./range(tp);
rp = (rp-min(rp))./range(rp);

% angular width in notch
ta = find(rp<0.5,1);
tb = find(rp(end:-1:1)<0.5,1);
aspnotch = theta(length(theta)-tb) - theta(ta)

% angular width in cone
ta = find(tp>0.5,1);
tb = find(tp(end:-1:1)>0.5,1);
aspcone = theta(length(theta)-tb) - theta(ta)


%% now SSP
ta = 62;
tb = 65; 
theta = linspace(ta,tb,10000);

rp = fresnel_ssp_rp(theta,0);
tp = fresnel_ssp_tp(theta,0);
tp = (tp-min(tp))./range(tp);
rp = (rp-min(rp))./range(rp);

% angular width in notch
ta = find(rp<0.5,1);
tb = find(rp(end:-1:1)<0.5,1);
sspnotch = theta(length(theta)-tb) - theta(ta)

% angular width in cone
ta = find(tp>0.5,1);
tb = find(tp(end:-1:1)>0.5,1);
sspcone = theta(length(theta)-tb) - theta(ta)