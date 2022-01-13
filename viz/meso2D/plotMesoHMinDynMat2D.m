%% Script to plot dynamical matrix eigenvalues during simulation

clear;
close all;
clc;


fname = 'mesoDM2D_N32_n32_ca1.14_kb01e-3_be50_da0.02_dl7_P1e-4_h0.5_cL0_cB0_seed12';
fstr = ['local/mesoDM2D_data/' fname '.posctc'];
hessstr = ['local/mesoDM2D_data/' fname '.hess'];

fstr = '~/Jamming/CellSim/dpm/pos.test';
hessstr = '~/Jamming/CellSim/dpm/hess.test';

% read in data
mesoData = readMesoNetworkCTCS2D(fstr);

% packing fraction (only take frames with phi > 0.25)
phi = mesoData.phi;
idx = phi > 0.1;
phi = phi(idx);

% number of frames
NFRAMES = sum(idx);

% sim info
NCELLS = mesoData.NCELLS;
nv = mesoData.nv(idx,:);
LList = mesoData.L(idx,:);
ctcList = mesoData.ctcs(idx,:);
x = mesoData.x(idx,:);
y = mesoData.y(idx,:);
r = mesoData.r(idx,:);
zc = mesoData.zc(idx,:);
zv = mesoData.zv(idx,:);
a0 = mesoData.a0(idx,:);
l0 = mesoData.l0(idx,:);
t0 = mesoData.t0(idx,:);
kb = mesoData.kb(idx,:);
phi0 = sum(a0,2)./(LList(:,1).*LList(:,2));

% get preferred shape
calA0 = zeros(NFRAMES,NCELLS);
p0 = zeros(NFRAMES,NCELLS);
for ff = 1:NFRAMES
    a0tmp = a0(ff,:);
    l0tmp = l0(ff,:);
    for cc = 1:NCELLS
        p0tmp = sum(l0tmp{cc});
        p0(ff,cc) = p0tmp;
        calA0(ff,cc) = p0tmp^2/(4.0*pi*a0tmp(cc));
    end
end

% particle shape data
p = mesoData.p(idx,:);
a = mesoData.a(idx,:);
calA = p.^2./(4.0*pi*a);

% stress data
S = mesoData.S(idx,:);
P = 0.5*(S(:,1) + S(:,2));


% Read in Hessian data
fid = fopen(hessstr);

% loop over frames, save moduli +  eigenvalues
G = zeros(NFRAMES,1);
B = zeros(NFRAMES,1);
sxylast = zeros(NFRAMES,1);
plast = zeros(NFRAMES,1);
mvals = cell(NFRAMES,1);
hvals = cell(NFRAMES,1);
svals = cell(NFRAMES,1);
fprintf('Reading in data from Hessian file %s\n',hessstr);
for ff = 1:NFRAMES-1
    % read in newfr
    newfrstr = fgetl(fid);
    fprintf('%s\n',newfrstr);
    
    % read in packing fraction
    phitmp = textscan(fid,'PACKF %f',1);
    fprintf('PACKF %0.5g\n',phitmp{1});
    
    % read in box size
    Ltmp = textscan(fid,'BOXSZ %f %f',1);
    fprintf('BOXSZ %0.5g\n',Ltmp{1});
    emptystr = fgetl(fid);
    
    % read in shear modulus
    Gtmp = textscan(fid,'SHRMD %f',1);
    fprintf('SHRMD %0.5g\n',Gtmp{1});
    emptystr = fgetl(fid);
    G(ff) = Gtmp{1};
    
    % read in bulk modulus
    Btmp = textscan(fid,'BLKMD %f',1);
    fprintf('BLKMD %0.5g\n',Btmp{1});
    emptystr = fgetl(fid);
    B(ff) = Btmp{1};
    
%     % read in last stress states during measurement
%     stlasttmp = textscan(fid,'STRSS %f %f',1);
%     fprintf('STRSS %0.5g %0.5g\n',stlasttmp{1},stlasttmp{2});
%     emptystr = fgetl(fid);
%     sxylast(ff) = stlasttmp{1};
%     plast(ff) = stlasttmp{2};
    
%     % read in dynamical matrix eigenvalues
%     mevalsstr = fgetl(fid);
%     mvals{ff} = sscanf(mevalsstr(6:end),'%f');
%     NMVALS = length(mvals{ff});
%     fprintf('%s, %d mvals found\n',mevalsstr(1:5),NMVALS);
%     
%     hevalsstr = fgetl(fid);
%     hvals{ff} = sscanf(hevalsstr(6:end),'%f');
%     NHVALS = length(hvals{ff});
%     fprintf('%s, %d hvals found\n',hevalsstr(1:5),NHVALS);
%     
%     sevalsstr = fgetl(fid);
%     svals{ff} = sscanf(sevalsstr(6:end),'%f');
%     NSVALS = length(svals{ff});
%     fprintf('%s, %d hvals found\n',sevalsstr(1:5),NSVALS);
    
    % read in newfr
    endfrstr = fgetl(fid);
    fprintf('%s\n',endfrstr);
end
poissonRatio = (B-G)./(B+G);

%% Plot

% color for frames
plotClr = jet(NFRAMES-1);

% % dyn mat spectra
% figure(1), clf, hold on, box on;
% for ff = 2:NFRAMES
%     mvtmp = mvals{ff};
%     mvtmp = mvtmp(3:end);
%     NV = length(mvtmp);
%     idx = (1:NV)./NV;
%     plot(idx,mvtmp,'-','linewidth',2,'color',plotClr(ff-1,:));
% end
% xlabel('$k/N_{\rm dof}$','Interpreter','latex');
% ylabel('$m_k$','Interpreter','latex');
% ax = gca;
% ax.FontSize = 22;
% ax.YScale = 'log';
% 
% 
% % stiffness matrix spectra
% figure(2), clf, hold on, box on;
% for ff = 2:NFRAMES
%     hvtmp = hvals{ff};
%     hvtmp = hvtmp(3:end);
%     NV = length(hvtmp);
%     idx = (1:NV)./NV;
%     plot(idx,hvtmp,'-','linewidth',2,'color',plotClr(ff-1,:));
% end
% xlabel('$k/N_{\rm dof}$','Interpreter','latex');
% ylabel('$h_k$','Interpreter','latex');
% ax = gca;
% ax.FontSize = 22;
% ax.YScale = 'log';



% % density of states, mean frequency
% nbins = 30;
% figure(3), clf, hold on, box on;
% for ff = 2:NFRAMES
%     % read in eigenvalues
%     mvtmp = mvals{ff};
%     mvtmp = mvtmp(3:end);
%     mvtmp = mvtmp(mvtmp > 0);
%     wtmp = sqrt(mvtmp);
%     
%     % build bins
%     be = logspace(log10(0.99*min(wtmp)),log10(1.05*max(wtmp)),nbins+1);
%     bc = 0.5*(be(2:end) + be(1:end-1));
%     
%     
%     % get DoS
%     figure(101), clf;
%     hobj = histogram(wtmp,'Normalization','pdf','BinEdges',be);
%     hy = hobj.Values;
%     
%     % plot to figure
%     figure(3),
%     plot(bc,hy,'-','linewidth',2,'color',plotClr(ff-1,:));
% end
% xlabel('$\omega$','Interpreter','latex');
% ylabel('$D(\omega)$','Interpreter','latex');
% ax = gca;
% ax.FontSize = 22;
% ax.XScale = 'log';



% % compare mean dyn mat and stiff mat eigenvalues
% mmean = zeros(NFRAMES-1,1);
% hmean = zeros(NFRAMES-1,1);
% for ff = 2:NFRAMES
%     hvtmp = hvals{ff};
%     hvtmp = hvtmp(3:end);
%     
%     mvtmp = mvals{ff};
%     mvtmp = mvtmp(3:end);
%     
%     mmean(ff-1) = mean(mvtmp);
%     hmean(ff-1) = mean(hvtmp);
% end
% figure(4), clf, hold on, box on;
% plot(phi(2) - phi(3:end),mmean(2:end),'ko','markersize',10,'markerfacecolor','b');
% plot(phi(2) - phi(3:end),hmean(2:end),'ko','markersize',10,'markerfacecolor','r');
% xlabel('$\varphi - \varphi_{\rm min}$','Interpreter','latex');
% ylabel('mean eigenvalue','Interpreter','latex');
% ax = gca;
% ax.FontSize = 22;


figure(5), clf, hold on, box on;

yyaxis left;
plot(phi(2) - phi(2:end),B(2:end),'-ko','markersize',10,'markerfacecolor','b');
h = ylabel('$B$','Interpreter','latex');
h.Color = 'b';
ax = gca;
ax.FontSize = 22;
ax.YColor = 'b';

yyaxis right;
plot(phi(2) - phi(2:end),G(2:end),'-kd','markersize',10,'markerfacecolor','r');
h = ylabel('$G$','Interpreter','latex');
h.Color = 'r';
ax = gca;
ax.FontSize = 22;
ax.YColor = 'r';

xlabel('$\varphi - \varphi_{\rm min}$','Interpreter','latex');




figure(6), clf, hold on, box on;
plot(phi(2) - phi(2:end),poissonRatio(2:end),'-kd','markersize',10,'markerfacecolor','g');
xlabel('$\varphi - \varphi_{\rm min}$','Interpreter','latex');
ylabel('$\nu$','Interpreter','latex');
ax = gca;
ax.FontSize = 22;





figure(7), clf, hold on, box on;

yyaxis left;
plot(phi(2) - phi(2:end),plast(2:end),'-ko','markersize',14,'markerfacecolor','b');
h = ylabel('$P$ after B meas. ','Interpreter','latex');
h.Color = 'b';
ax = gca;
ax.FontSize = 22;
ax.YColor = 'b';

yyaxis right;
plot(phi(2) - phi(2:end),sxylast(2:end),'-kd','markersize',10,'markerfacecolor','r');
h = ylabel('$P$ after G meas. ','Interpreter','latex');
h.Color = 'r';
ax = gca;
ax.FontSize = 22;
ax.YColor = 'r';

xlabel('$\varphi - \varphi_{\rm min}$','Interpreter','latex');
