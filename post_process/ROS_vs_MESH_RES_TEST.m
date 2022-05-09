%%
DX=[10:5:45];
for i=1:10
    BATCH_NAME = sprintf('DX_COMPARISON_GR0.667_CORR/DX_COMPARISON_%d',i);
    mkdir(BATCH_NAME);
    for j=1:length(DX)
        delX          = DX(j);
        BATCH_TEST;
        filename=sprintf('DX%d_DT10_GR%.3f',delX,NEMBERS_MIN);
        movefile('main_result',filename)
        movefile(filename,BATCH_NAME);
    end
end

%%
DX=zeros(1,7);
ROS=zeros(10,7);
DEPTH=zeros(10,7);
for k=1:10
    CASE_NAME = dir(sprintf('DX_COMPARISON_GR0.667_CORR/DX_COMPARISON_%d/DX*',k));
    for i=1:length(CASE_NAME)
        PATH = strcat(CASE_NAME(i).folder,'/',CASE_NAME(i).name,'/');
        MODEL_INPUTS = strsplit(CASE_NAME(i).name,{'DX','DT','GR','_'});
        DX_TEMP = cell2mat(MODEL_INPUTS(2));
        DX(i) = str2double(DX_TEMP);
    %     TESTS = dir(strcat(PATH,'/result_*.mat'));
    %     for j=1:length(TESTS)
        [ROS(k,i),DEPTH(k,i)]=ROS_DEPTH_CALC(PATH,DX(i),0,false,false);

    end
    figure(1)
    hold on
    plot(DX,ROS(k,:),'bo','MarkerSize',10)
    xlabel('\DeltaX [m]');ylabel('ROS [m/s]')
    set(gca,'FontSize',15)
    figure(2)
    hold on
    plot(DX,DEPTH(k,:),'bo','MarkerSize',10)
    xlabel('\DeltaX [m]');ylabel('Depth [m]')
    set(gca,'FontSize',15)
end
figure(1)
[DX,index]=sort(DX);
shadedErrorBar(DX,ROS(:,index),{@mean,@std})
figure(2)
DX_2d=repmat(DX,[10,1]);
shadedErrorBar(DX,DEPTH(:,index),{@mean,@std})