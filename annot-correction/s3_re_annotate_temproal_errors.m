function s3_re_annotate_temproal_errors()
%image chnaged
% stb = load('annot_test.mat');
% base_annot = stb.videos;
% clear stb;clear all
close all
stb = load('annotV5.mat');
%stb = load('annot.mat');
base_annot = stb.videos;
clear stb;

stp = load('annot_full_Philippe.mat'); % train+test
phill_annot = stp.videos;
clear stp;

stp = load('annot_apt.mat'); % train+test
apt_annot = stp.videos;
clear stp;

baseList = {};
for i=1:length(base_annot)
    baseList{i,1} = base_annot(i).name; % store all the cor vid in a cellarray
end

philList = {};
for i=1:length(phill_annot)
    philList{i,1} = phill_annot(i).name; % store all the cor vid in a cellarray
end

aptList = {};

for i=1:length(apt_annot)
    aptList{i,1} = apt_annot(i).name; % store all the cor vid in a cellarray
end

images_dir = '/mnt/sun-alpha/datasets/UCF101/images';
save_path = 'saved/';

%for v = 403 % : length(base_annot)
% rvid = randperm(length(base_annot));

% FigHandle = figure(1);
% FigHandle = figure('Position', [100, 100, 1049, 895]);
% hold on
count = 0;
load('checkpoint_improved.mat')
load('merged_annot')
v = 1;
tdata =cell(1);
load('tdata.mat')
% vc = 17; v = 777;
while v <= length(baseList)
    save('tdata.mat','v','tdata','vc');
    videoName = baseList{v,1};
    
    base_tubes = base_annot(v).tubes;
    
    index = find(strcmp(philList,videoName));
    phil_tubes = phill_annot(index).tubes;
    
    index = find(strcmp(aptList,videoName));
    apt_tubes = apt_annot(index).tubes;
    num_imgs = base_annot(v).num_images;
    
    merged_annot(v).num_imgs = num_imgs;
    merged_annot(v).name = base_annot(v).name;
    
    if ~isgood(v) && strcmp(inputs{v},'t')
        vc = vc +1;
        fprintf('doing %d %d\n',vc,v);
        %merged_annot(v).tubes = base_tubes;
        %inputs{v} = 'y';
        %isgood(v) = 1;
        checkboxes(base_tubes,phil_tubes,apt_tubes,num_imgs,images_dir,save_path,videoName)
        
        fid = fopen('temp.txt','w');

        for t = 1 : length(phil_tubes)
            fprintf(fid,'p %d %d %d\n', t, phil_tubes(t).sf, phil_tubes(t).ef);
        end

        for t = 1 : length(base_tubes)
            fprintf(fid,'b %d %d %d\n', t, base_tubes(t).sf, base_tubes(t).ef);      
        end
        
        for t = 1 : length(apt_tubes)
            fprintf(fid,'a %d %d %d\n', t, apt_tubes(t).sf, apt_tubes(t).ef);
        end
        
        fclose(fid); 
        
        fid = fopen('temp.txt','r');
        
        tline = fgets(fid);
        newcell = cell(1);
        count = 1;
        newcell{count} = tline; 
        while ischar(tline)
            tline = fgets(fid);
            if ischar(tline)
                count = count + 1;
                newcell{count} = tline;
                disp(tline)
            end
        end
        fclose(fid);
        tdata{v} = newcell;
    end
    v=v+1;
    
end

% save('checkpoint_improved_t.mat','isgood','inputs','v');
% save('merged_annot_t.mat','merged_annot')

function checkboxes(base_tubes,phil_tubes,apt_tubes,num_imgs,images_dir,save_path,videoName)


for i = 1 :1: num_imgs
    % fprintf('i=%d\n', i);
    philboxes = [];
    baseboxes = [];
    aptboxes = [];
    for t = 1 : length(phil_tubes)
        if phil_tubes(t).sf<= i && phil_tubes(t).ef >=i
            offset = uint16(phil_tubes(t).sf-1);
            philboxes = [philboxes;phil_tubes(t).boxes(i-offset,:),t];
        end
    end
    
    for t = 1 : length(base_tubes)
        if i >= base_tubes(t).sf && i <= base_tubes(t).ef
            offset = uint16(base_tubes(t).sf-1);
            baseboxes = [baseboxes;base_tubes(t).boxes(uint8(i-offset),:),t];
        end
    end
    
    for t = 1 : length(apt_tubes)
        if i >= apt_tubes(t).sf && i <= apt_tubes(t).ef
            offset = uint16(apt_tubes(t).sf-1);
            aptboxes = [aptboxes;apt_tubes(t).boxes(uint8(i-offset),:),t];
        end
    end
    
    image_name = sprintf('%s/%s/%05d.jpg',images_dir,videoName,i);
%     if ~isempty(philboxes) || ~isempty(baseboxes)
    plotBoxes(philboxes,baseboxes,aptboxes,image_name, videoName, save_path, i,num_imgs);
%     pause(0.000000001);
%     end
end

function plotBoxes(philboxes,baseboxes,aptboxes,img_file, videoName, savepath, framenr,num_imgs)

%str = strsplit(videoName,'/');
%action = str{1};
%videoname = str{2};

% savepath = [save_path '/' videoName];
if ~exist(savepath,'dir')
    mkdir(savepath);
end

savefile = sprintf('%s%05d.jpg',savepath,framenr);

%img_w=500;
%img_h=500;

hold off
im = imread(img_file);
imshow(im);
%set(gca,'Units','normalized','Position',[0 0 1 1]);  %# Modify axes size
%set(gcf,'Units','pixels','Position',[200 200 img_w img_h]);  %# Modify figure size
hold on;
legends = cell(1);
count =1 ;
steps = 1:15:440;

for  b = 1 : size(philboxes,1)
    rectangle('Position', philboxes(b,1:4), 'EdgeColor','b','LineWidth',5.0 );
    text(double(philboxes(b,1)+15), double(philboxes(b,2)-15), sprintf('%d',uint8(philboxes(b,5))),'Color','blue','FontSize',14);
    count = count + 1;
end


for  b = 1 : size(baseboxes,1)
    rectangle('Position', baseboxes(b,1:4), 'EdgeColor','r','LineWidth',3.0 );
    text(double(baseboxes(b,1)), double(baseboxes(b,2)-15), sprintf('%d',uint8(baseboxes(b,5))),'Color','red','FontSize',14);
%     text(-50,steps(count),sprintf('base %d',b),'Color','red');
    count = count + 1;
end

for  b = 1 : size(aptboxes,1)
    rectangle('Position', aptboxes(b,1:4), 'EdgeColor','g','LineWidth',1.0 );
    text(double(aptboxes(b,1))+30, double(aptboxes(b,2)-15), sprintf('%d',uint8(aptboxes(b,5))),'Color','green','FontSize',14);
%     text(-50,steps(count),sprintf('apt %d',b),'Color','green');
    count = count + 1;
end

% title([num2str(num_imgs),' ',num2str(framenr)])
% pause(0.000001)

frm_save = getframe(gcf); %# Capture the current window
imwrite(frm_save.cdata, savefile);
% imwrite(im,savefile);
%disp('ok');

function gtVidInd = getVidInd(video,videoName)
for i=1:length(video)
    vidid = video(i).name;
    if strcmp(vidid,videoName)
        gtVidInd = i;
        break;
    end
end


    
