%% Single static ember source, no spreading time taken account
clear
GR_MEMO = [10 20 50 100 200 500];
ROS_MEMO = [];
mu=2.18;sigma=1.23;
pdf=@(x)1./(x*2.18*sqrt(2*pi)).*exp(-(log(x)-mu).^2/sigma^2/2).*(x<=100);
pdf_norm=integral(pdf,0,100);
for j=1:length(GR_MEMO)
    delX=2;
    CELL_ID=[0:delX:300];
    x0=0;
    for i=1:length(CELL_ID)-1
        DIS_PDF(i) = integral(@(x)((x-x0)>=0).*pdf(x-x0)/pdf_norm,CELL_ID(i),CELL_ID(i+1));
    end
    t0=0;Uw=15*0.447;tau=6;GR=GR_MEMO(j);

    DIS_PDF_XMAX = DIS_PDF(DIS_PDF>0);
    DIS_PDF_XMAX = max(DIS_PDF_XMAX);
    k=find(DIS_PDF==DIS_PDF_XMAX);
    fmdx = pdf((k-1)*delX)/pdf_norm;
    fx = pdf(k*delX)/pdf_norm;

    ROS=GR*DIS_PDF_XMAX.^2./(fmdx-fx);
    ROS_MEMO=[ROS_MEMO ROS];
end
%%
i=find(DIS_PDF==0);
GR_crit=1/delX/tau/DIS_PDF(i(1)-1);

EF_MAT = zeros((length(CELL_ID)-1),length(0:0.2:60));
for i=1:(length(CELL_ID)-1)
%     i=90;
    EF=@(t)(t<(t0)).*0+...
            (t>=(t0) & t<(t0+tau)).*GR.*DIS_PDF(i).*(t-t0)+...
            (t>=(t0+tau)).*GR.*DIS_PDF(i).*tau;
    k=0;
    for j=0:0.2:60
        k=k+1;
        EF_MAT(i,k) = EF(j);
    end
end
 
[X,T]=meshgrid(CELL_ID(1:end-1),0:0.2:60);
figure(1)
[C,h]=contourf(T',X',EF_MAT,[0,1])
colormap('gray')
xlabel('t [s]');ylabel('X [m]')

figure(2)
hold on
[DATA_X,INDEX]=sort(C(1,2:end));
DATA_Y=C(2,2:end);
DATA_Y=DATA_Y(INDEX);
yyaxis left
plot(DATA_X,DATA_Y,'LineWidth',2)
xlabel('t [s]');ylabel('X [m]');xlim([0 20]);ylim([0 150])
set(gca,'FontSize',15)

yyaxis right
plot(DATA_X(1:end-1),diff(DATA_Y)./diff(DATA_X),'LineWidth',2)
xlabel('t [s]');ylabel('ROS [m/s]');xlim([0 20]);ylim([0 150])
set(gca,'FontSize',15)

% hold on
% ROS=(t<=t0).*0+...
%     (t>t0 & t<=t0+tau).*GR*DIS_PDF.^2./(pdf(CELL_ID(1:end-1))-pdf(CELL_ID(2:end)))+...
%     (t>t0 & t<=t0+tau).*0;
ROS=GR*DIS_PDF_XMAX.^2./(fmdx-fx);
% TIME=1./GR./DIS_PDF+t0;
% plot(delX,ROS,'ks','DisplayName',sprintf('\\DeltaX=%.1f m',delX))
xlabel('t [s]');ylabel('X [m]');xlim([0 60]);ylim([0 150])
set(gca,'FontSize',15)


% EF = 
%% Single static ember source
clear
GR_MEMO = [10 20 50 100 200 500];
ROS_MEMO = [];
mu=2.18;sigma=1.23;
pdf=@(x)1./(x*2.18*sqrt(2*pi)).*exp(-(log(x)-mu).^2/sigma^2/2).*(x<=100);
pdf_norm=integral(pdf,0,100);
for j=1:length(GR_MEMO)
    delX=2;
    CELL_ID=[0:delX:300];
    x0=0;
    for i=1:length(CELL_ID)-1
        DIS_PDF(i) = integral(@(x)((x-x0)>=0).*pdf(x-x0)/pdf_norm,CELL_ID(i),CELL_ID(i+1));
    end
    t0=0;Uw=15*0.447;tau=6;GR=GR_MEMO(j);
    DIS_PDF_XMAX = DIS_PDF(DIS_PDF>0);
    DIS_PDF_XMAX = DIS_PDF_XMAX(end);
    fmdx = pdf(100-delX)/pdf_norm;
    fx = pdf(100)/pdf_norm;
    ROS=Uw/(1+Uw*(fmdx-fx)/(GR*DIS_PDF_XMAX.^2));
    ROS_MEMO=[ROS_MEMO ROS];
end
%%
EF_MAT = zeros((length(CELL_ID)-1),length(0:0.2:60));
for i=1:(length(CELL_ID)-1)
    EF=@(t)(t<(t0+i*delX/Uw))*0+...
            (t>=(t0+i*delX/Uw) & t<(t0+i*delX/Uw+tau)).*GR.*DIS_PDF(i).*(t-i*delX/Uw-t0)+...
            (t>=(t0+i*delX/Uw+tau))*GR*DIS_PDF(i)*tau;
    k=0;
    for j=0:0.2:60
        k=k+1;
        EF_MAT(i,k) = EF(j);
    end
end
        
figure(1)
[X,T]=meshgrid(CELL_ID(1:end-1),0:0.2:60);
[C,h]=contourf(T',X',EF_MAT,[0,1]);
colormap('gray')
xlabel('t [s]');ylabel('X [m]')

figure(2)
hold on
yyaxis left
plot(C(1,2:end),C(2,2:end))
xlabel('t [s]');ylabel('X [m]')
set(gca,'FontSize',15)

[DATA_X,INDEX]=sort(C(1,2:end));
DATA_Y=C(2,2:end);
DATA_Y=DATA_Y(INDEX);
yyaxis right
hold on
plot(DATA_X(1:end-1),diff(DATA_Y)./diff(DATA_X),'LineWidth',2,'DisplayName',sprintf('\\DeltaX=%.1f m',delX))
ROS=Uw./(1+Uw*(pdf(CELL_ID(1:end-1))-pdf(CELL_ID(2:end)))./(GR*DIS_PDF.^2));
TIME=1./GR./DIS_PDF+t0;
plot(TIME,ROS,'DisplayName',sprintf('\\DeltaX=%.1f m',delX))
xlabel('t [s]');ylabel('ROS [m/s]')
set(gca,'FontSize',15)

%% Multiple static ember source

mu=2.18;sigma=1.23;
pdf=@(x)1./(x*2.18*sqrt(2*pi)).*exp(-(log(x)-mu).^2/sigma^2/2).*(x<=100);
pdf_norm=integral(pdf,0,100);
delX=1;
CELL_ID=[0:delX:300];
X0s = [0:delX:300];
for x0=1:length(X0s)
    for i=1:length(CELL_ID)-1
        DIS_PDF(x0,i) = integral(@(x)((x-X0s(x0))>=0).*pdf(x-X0s(x0))/pdf_norm,CELL_ID(i),CELL_ID(i+1));
    end
end
t0=0;Uw=15*0.447;tau=6;GR=100;

%%
mu=2.18;sigma=1.23;
pdf=@(x)1./(x*2.18*sqrt(2*pi)).*exp(-(log(x)-mu).^2/sigma^2/2).*(x<=100);
pdf_norm=integral(pdf,0,100);
delX=1;
CELL_ID=[0:delX:300];
X0s = [0:delX:300];
load('DIS_PDF.mat');
t0=0;Uw=15*0.447;tau=6;GR=100;
EF_MAT = zeros(300,301);
for i=1:(length(CELL_ID)-1)
    k=0;
    for j=0:0.2:60
        k=k+1;
        for jj=1:10
            EF=@(t)(t<(t0+(i*delX-X0s(jj))/Uw))*0+...
                (t>=(t0+(i*delX-X0s(jj))/Uw) & t<(t0+(i*delX-X0s(jj))/Uw+tau))*GR*DIS_PDF(jj,i)*(t-(i*delX-X0s(jj))/Uw-t0)+...
                (t>=(t0+(i*delX-X0s(jj))/Uw+tau))*GR*DIS_PDF(jj,i)*tau;
            EF_MAT(i,k) = EF_MAT(i,k)+EF(j);
        end
    end
end
        
figure(1)
[X,T]=meshgrid(CELL_ID(1:end-1),0:0.2:60);
[C,h]=contourf(T',X',EF_MAT,[0,1]);
colormap('gray')
xlabel('t [s]');ylabel('X [m]')

figure(2)
hold on
plot(C(1,2:end),C(2,2:end))
xlabel('t [s]');ylabel('X [m]');xlim([0 60]);ylim([0 150])
set(gca,'FontSize',15)

%% Multiple dynamic ember source

mu=2.18;sigma=1.23;
pdf=@(x)1./(x*2.18*sqrt(2*pi)).*exp(-(log(x)-mu).^2/sigma^2/2).*(x<=100);
pdf_norm=integral(pdf,0,100);
delX=1;
CELL_ID=[0:delX:300];
X0s = [0:delX:300];

for x0=1:length(X0s)
    for i=1:length(CELL_ID)-1
        DIS_PDF(x0,i) = integral(@(x)((x-X0s(x0))>=0).*pdf(x-X0s(x0))/pdf_norm,CELL_ID(i),CELL_ID(i+1));
    end
end


%%
load('DIS_PDF.mat');
t0=0;Uw=15*0.447;tau=6;GR=100;
T0_MEMO = 0;
EF_MAT = zeros(300,301);
for iter = 11:20
    for i=1:(length(CELL_ID)-1)
        k=0;
        for j=0:0.2:60
            k=k+1;
            for jj=1:iter
                t0=T0_MEMO(jj);
                EF=@(t)(t<(t0+(i*delX-X0s(jj))/Uw))*0+...
                    (t>=(t0+(i*delX-X0s(jj))/Uw) & t<(t0+(i*delX-X0s(jj))/Uw+tau))*GR*DIS_PDF(jj,i)*(t-(i*delX-X0s(jj))/Uw-t0)+...
                    (t>=(t0+(i*delX-X0s(jj))/Uw+tau))*GR*DIS_PDF(jj,i)*tau;
                EF_MAT(i,k) = EF_MAT(i,k)+EF(j);
            end
        end
    end
    [X,T]=meshgrid(CELL_ID(1:end-1),0:0.2:60);
    [C,h]=contourf(T',X',EF_MAT,[0,1]);
    T0_MEMO=[T0_MEMO, custom_interpolation(C(2,end:-1:2),C(1,end:-1:2),X0s(iter))];
end