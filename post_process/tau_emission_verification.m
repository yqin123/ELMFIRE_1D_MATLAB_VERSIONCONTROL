% delX=1;

mu=2.18;sigma=1.23;
pdf=@(x)1./(x*2.18*sqrt(2*pi)).*exp(-(log(x)-mu).^2/sigma^2/2).*(x<=100);
pdf_norm=integral(pdf,0,inf);

CELL_ID=[0:delX:300];
for i=1:length(CELL_ID)-1
    DIS_PDF(i) = integral(@(x)pdf(x)/pdf_norm,CELL_ID(i),CELL_ID(i+1));
end
figure(1)
hold on
sum(EMBER_FLUX)
sum(EMBER_EMIT_FLUX)
plot([0,0,0:delX:300,300,300],EMBER_FLUX,'DisplayName','Simulated results')
plot([0:delX:(300-delX)]+3*delX,NEMBERS_MIN*6*DIS_PDF,'DisplayName','GR\times\tau_{emission}\timespdf(k_i)');
xlabel('X [m]');ylabel('Number of embers [-]');
title(sprintf('\\Delta X=%.1f m, GR=%.1f cell^{-1}s^{-1}',delX,NEMBERS_MIN))
legend();
set(gca,'YScale','log')
set(gca,'FontSize',15)
set(gca,'FontName','Times')

NEMBERS_MIN*delT*ceil(60*0.1/delT)

%%
tau_emission=[6]; %s
for ti=tau_emission
    GR_crit=[];
    i=0;
    for delX=0.2:0.5:30
        i=i+1;
        UNIT_NOE=integral(@(x)pdf(x)/pdf_norm,100-delX,100);
        GR_crit(i)=1/ti/UNIT_NOE;
    end
    figure(3)
    hold on
    plot(0.2:0.5:30,GR_crit,'DisplayName',sprintf('\\tau_{emission}=%.1f s',ti))
end
xlabel('\DeltaX [m]');ylabel('GR_{crit} [cell^{-1}s^{-1}]');
% title(sprintf('\\Delta X=%.1f m, \\Delta t=%.1f s',delX,delT))
legend();
set(gca,'YScale','log')
set(gca,'FontSize',15)
set(gca,'FontName','Times')
%%
plot([1 600], [100/6 100/6],'k--','LineWidth',2,'DisplayName','X_{max}/\tau_emission')