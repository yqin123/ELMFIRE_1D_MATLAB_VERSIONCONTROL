% GR=[0.1:0.2:1,2:2:10,15,17,20];];
% GR=[34 35 36 37 40 45 50
% GR=[0.1:0.2:1,2:2:10,15,17,20,25,30,37,40,45,50];
GR=[1 5 10 20 40 60 80 100 125 150 200 300 500 600 800 1000 1500 3000];
GR=[1];
% GR=[3000];
% DT = [0.5 1 2 5 6];
% DT = [1 2 5];
DX = [10];
for i=1:length(DX)
    delT = 1;
    delX = DX(i);
    BATCH_NAME = sprintf('CLEAN_TEST/DX%.1f_DT%.1f_TAU_6_FLYTIME_CORR_NEW',delX,delT);
    mkdir(BATCH_NAME);
    for j=1:length(GR)
        NEMBERS_MIN          = GR(j);
        NEMBERS_MAX          = GR(j);
        BATCH_TEST;
        filename=sprintf('DX%.1f_DT%.2f_GR%.3f',delX,delT,NEMBERS_MIN);
        movefile(RES_DIR,filename);
        movefile(filename,BATCH_NAME);
    end
end
% end
%%
clear
% GR=[3/15,4/15,5/15,6/15,7/15,8/15,9/15,10/15];
% GR = [1/15,1/30,1/45,2/15,3/15,4/15,5/15,6/15];
GR=zeros(1,5);
DX=zeros(1,6);
ROS=zeros(1,6);
% DEPTH=zeros(1,6); 
CASE_NAME = dir('CLEAN_TEST/DX10.0_DT5.0_TAU_6_FLYTIME_CORR/DX*');
for i=1:length(CASE_NAME)
    PATH = strcat(CASE_NAME(i).folder,'/',CASE_NAME(i).name,'/');
    MODEL_INPUTS = strsplit(CASE_NAME(i).name,{'DX','DT','GR','_'});
    DX_TEMP = cell2mat(MODEL_INPUTS(2));
    GR_TEMP = cell2mat(MODEL_INPUTS(4));
    DX(i) = str2double(DX_TEMP);
    GR(i) = str2double(GR_TEMP);
%     TESTS = dir(strcat(PATH,'/result_*.mat'));
%     for j=1:length(TESTS)
    ROS(i) = ROS_CALC_CELL_CENTER(PATH,DX(i),2,false);
%     [ROS(i),DEPTH(i)]=ROS_DEPTH_CALC(PATH,DX(i),0,false,false,true);
end
figure(1)
hold on
[GR_SORT,index]=sort(GR);
GR_CORR_MAT = ceil([10 20 30]'*[1/100 1/75 1/60 1/45 1/30 1/15 1/8 1/4 1/2 1]*10)./repmat([10 20 30]',[1 10])/10;

plot(GR_SORT,ROS(index),'-o','LineWidth',2,'MarkerSize',10)
xlabel('GR [cell^{-1}s^{-1}]');ylabel('ROS [m/s]')
set(gca,'FontSize',15)
