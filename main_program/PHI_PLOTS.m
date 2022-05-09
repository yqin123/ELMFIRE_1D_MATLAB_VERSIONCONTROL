%% DRAW PHI FIELD
function h=PHI_PLOTS(CASE_DIR,OUTPUT_GIF,DELX,DRAW_CASE_NUM,WRITE_IMAGE,PLAYBACK)
% CASE_DIR = 'shower_mode_comparison_GR4o15/DX30_DT10_XMAX100_PHI_SINGLE/';
% CASE_DIR = 'DX30_CONVERGE_GR_CORR2/DX30_DT10_GR0.600/';
% % CASE_DIR = 'main_result/';
GIF_filename = OUTPUT_GIF;
CASE_NAME = dir(strcat(CASE_DIR,'*.mat'));
load(strcat(CASE_DIR,CASE_NAME(DRAW_CASE_NUM).name));
del=DELX;
time = prop_log(:,1);
prop_map = prop_log(:,2:end);

h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
set(gcf,'Position',[10 10 800 100])

SIMU_REGION_IND=3:(length(prop_map(1,:))-2);
for n = 1:size(FIRE_BACK_IX,2)
    % Draw plot for y = x.^n
%     contourf(X,Y,repmat(prop_map(n,:),[2 1]),'LineStyle', 'none') 
    
    plot((SIMU_REGION_IND-2)*del+del/2,prop_map(n,SIMU_REGION_IND),...
        ones([1,101])*(FIRE_BACK_IX(n)-1)*del,[-1:0.02:1],'b--',...
        ones([1,101])*(FIRE_FRONT_IX(n)-1)*del,[-1:0.02:1],'r--');
    
    title(sprintf('t=%f s',time(n)))
    xlabel('x [m]');ylabel('\phi')
    ylim([-1 1])
    drawnow
    pause(PLAYBACK)
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if(WRITE_IMAGE)
        if n == 1 
          imwrite(imind,cm,GIF_filename,'gif', 'Loopcount',inf); 
        else  
          imwrite(imind,cm,GIF_filename,'gif','WriteMode','append','DelayTime',0.1); 
        end
    end
end


% %% Different showering method comparison
% REPO_NAME='shower_mode_comparison_GR1o15/DX*';
% FILES=dir(REPO_NAME);
% EMBER_EMIT_FLUX_AVG=zeros(3,105);
% for i=1:3
%     CASE_REPO=strcat(FILES(i).folder,'/',FILES(i).name);
%     RES_FILE=dir(strcat(CASE_REPO,'/result*.mat'));
%     TEMP_FLUX=zeros(1,105);
%     for j=1:10
%         load(strcat(RES_FILE(j).folder,'/',RES_FILE(j).name))
%         TEMP_FLUX=TEMP_FLUX+v2;
%     end
%     EMBER_EMIT_FLUX_AVG(i,:)=TEMP_FLUX/10;
% end
% figure
% hold on
% plot([0,0,0:30:3000,3000,3000],EMBER_EMIT_FLUX_AVG(1,:))
% plot([0,0,0:30:3000,3000,3000],EMBER_EMIT_FLUX_AVG(2,:))
% plot([0,0,0:30:3000,3000,3000],EMBER_EMIT_FLUX_AVG(3,:))
% xlabel('x [m]');ylabel('Number of emitted ember [number/pixel]');
% legend({'Emit from -0.9<=\phi<=0','Emit from -1<=\phi<=0','Emit from leading edge'})
% set(gca,'FontSize',15)
% 
% %% Converged generating rate
% plot([1/45,1/30,1/15,2/15,3/15,4/15,5/15],[2.7,2.9,3.4,4.0,4.4,4.2,4.4],'-o','LineWidth',2,'MarkerSize',10)
% xlabel('GR [embers/m/s]');ylabel('ROS [m/s]');
% set(gca,'FontSize',15)
