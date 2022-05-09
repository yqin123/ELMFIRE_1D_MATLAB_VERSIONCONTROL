%% Depth Post Process
clear
CASE_DIR = 'main_result/';
CASE_NAME = dir(strcat(CASE_DIR,'*.mat'));
SINGLE_CASE=0;DELX=10;

load(strcat(CASE_DIR,CASE_NAME(1).name));
time = prop_log(:,1);

if (SINGLE_CASE)
    HEAD_MEMO=zeros([1,size(prop_log,1)])+9999;
    BACK_MEMO=zeros([1,size(prop_log,1)])+9999;
    LEN=1;
else
    HEAD_MEMO=zeros([length(CASE_NAME),1000])+9999;
    BACK_MEMO=zeros([length(CASE_NAME),1000])+9999;
    LEN=length(CASE_NAME);
end
LEN_TIME=0;
figure;
for i=1:LEN
    load(strcat(CASE_DIR,CASE_NAME(i).name));
    if (length(prop_log(:,1))>LEN_TIME)
        time = prop_log(:,1);
        LEN_TIME=length(time);
    end
    subplot(1,3,1)
    hold on
    HEAD_HIST_SMOOTH = (FIRE_FRONT_IX-1)*DELX;
    BACK_HIST_SMOOTH = (FIRE_BACK_IX-1)*DELX;
    plot(time(1:length(FIRE_FRONT_IX)),HEAD_HIST_SMOOTH','r*', 'MarkerSize',5)
    plot(time(1:length(FIRE_BACK_IX)),BACK_HIST_SMOOTH', 'bo','MarkerSize',5)    
    
    HEAD_MEMO(i,1:length(HEAD_HIST_SMOOTH))=HEAD_HIST_SMOOTH;
    BACK_MEMO(i,1:length(BACK_HIST_SMOOTH))=BACK_HIST_SMOOTH;
    clear FIRE_FRONT_IX FIRE_BACK_IX
end

[e1,e2]=find(HEAD_MEMO<9999);
HEAD_MEMO(:,max(e2)+1:end)=[];
HEAD_ENDING=find(HEAD_MEMO>=9999);
for i=1:length(HEAD_ENDING)
    END_CELL=unique(HEAD_MEMO);
    END_CELL=END_CELL(end-1);
    HEAD_MEMO(HEAD_ENDING(i))=END_CELL;
end
[e1,e2]=find(BACK_MEMO<9999);
BACK_MEMO(:,max(e2)+1:end)=[];
BACK_ENDING=find(BACK_MEMO>=9999);
for i=1:length(BACK_ENDING)
    END_CELL=unique(HEAD_MEMO);
    END_CELL=END_CELL(end-1);
    BACK_MEMO(BACK_ENDING(i))=END_CELL;
end
%%
subplot(1,3,1)
hold on
TIME_MEAN=time(1:size(HEAD_MEMO,2));
HEAD_MEAN=mean(HEAD_MEMO,1);
BACK_MEAN=mean(BACK_MEMO,1);

plot(TIME_MEAN,HEAD_MEAN,'k-','LineWidth',2)
plot(TIME_MEAN,BACK_MEAN,'k-','LineWidth',2)
xlabel('Time [s]');ylabel('X [m]')
legend({'Head','Back'})
set(gca,'FontSize',20)

subplot(1,3,2)
hold on
HEAD_MEAN_SMOOTH=smooth(HEAD_MEAN,1);
BACK_MEAN_SMOOTH=smooth(BACK_MEAN,1);
VELO_AVG=false;

% Post-process method comparison. 1) Average location; 2) Average velocity
if(~VELO_AVG)
    HEAD_ROS = gradient(HEAD_MEAN_SMOOTH)./gradient(TIME_MEAN);
    BACK_ROS = gradient(BACK_MEAN_SMOOTH)./gradient(TIME_MEAN);
else
    [HEAD_ROS, FY_1]=gradient(HEAD_MEMO);
    [BACK_ROS, FY_2]=gradient(BACK_MEMO);

    TIME_GR=repmat(gradient(TIME_MEAN),[1,size(CASE_NAME,1)]);

    HEAD_ROS = mean(HEAD_ROS./TIME_GR',1);
    BACK_ROS = mean(BACK_ROS./TIME_GR',1);
    HEAD_ROS = HEAD_ROS';
    BACK_ROS = BACK_ROS';
end
plot(TIME_MEAN,HEAD_ROS,'r-','LineWidth',2)
plot(TIME_MEAN,BACK_ROS,'b.-','LineWidth',2)

STEADY_RANGE=1:length(HEAD_ROS);
TEMP_HEAD_ROS=HEAD_ROS;
TEMP_BACK_ROS=BACK_ROS;
TEMP_TIME_MEAN = TIME_MEAN;
TEMP_HEAD=HEAD_MEAN_SMOOTH;
TEMP_BACK=BACK_MEAN_SMOOTH;
for i=1:1000
    TEMP_HEAD_ROS=TEMP_HEAD_ROS(STEADY_RANGE);
    TEMP_BACK_ROS=TEMP_BACK_ROS(STEADY_RANGE);
    TEMP_TIME_MEAN = TEMP_TIME_MEAN(STEADY_RANGE);
    TEMP_HEAD=TEMP_HEAD(STEADY_RANGE);
    TEMP_BACK=TEMP_BACK(STEADY_RANGE);
    D_st=mean(TEMP_HEAD-TEMP_BACK);
    
    VELO_ALL=[TEMP_HEAD_ROS;TEMP_BACK_ROS];
    ROS_st=mean(VELO_ALL);
    
    HEAD_ROS_ERR=abs(TEMP_HEAD_ROS-ROS_st);
    BACK_ROS_ERR=abs(TEMP_BACK_ROS-ROS_st);
    
    VELO_ERR_LIMIT = std(VELO_ALL)/2;
    
    HEAD_STEADY_RANGE = find(HEAD_ROS_ERR<=VELO_ERR_LIMIT);
    BACK_STEADY_RANGE = find(BACK_ROS_ERR<=VELO_ERR_LIMIT);
    
    STEADY_RANGE=max(HEAD_STEADY_RANGE(1),BACK_STEADY_RANGE(1)):...
        min(HEAD_STEADY_RANGE(end),BACK_STEADY_RANGE(end));
    
    T_trans_min=TEMP_TIME_MEAN(STEADY_RANGE(1));
    T_trans_max=TEMP_TIME_MEAN(STEADY_RANGE(end));
    
    ERROR_SUM=sum(abs([TEMP_HEAD_ROS;TEMP_BACK_ROS]-ROS_st))/length(VELO_ALL);
    if (VELO_ERR_LIMIT<=1.0)
        break
    end
end
plot(ones(1,101)*T_trans_min,-10:90,'k--','LineWidth',2)
plot(ones(1,101)*T_trans_max,-10:90,'k--','LineWidth',2)
plot(TIME_MEAN,ones(1,length(TIME_MEAN))*ROS_st,'k--','LineWidth',2)

fprintf('ROS_st: %.1f m/s, T_min: %.1f s, T_max: %.1f s,D_st: %.1f m\n',ROS_st,T_trans_min,T_trans_max,D_st)
legend({'Head','Back'})
xlabel('Time [s]');
ylabel('Velocity [m/s]');ylim([-10,20])
set(gca,'FontSize',20)

subplot(1,3,3)
hold on
DEPTH=HEAD_MEAN_SMOOTH-BACK_MEAN_SMOOTH;
plot(TIME_MEAN,DEPTH, 'LineWidth',2)
xlabel('Time [s]');ylabel('Depth [m]')
set(gca,'FontSize',20)