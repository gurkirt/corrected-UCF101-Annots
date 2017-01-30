function s1_check_annot()
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
save_path = './saved/';
%for v = 403 % : length(base_annot)
% rvid = randperm(length(base_annot));

% FigHandle = figure(1);
% FigHandle = figure('Position', [100, 100, 1049, 895]);
% hold on
count = 0;
load('checkpoint.mat')
% v=1;
while v <= length(baseList)
    
    save('checkpoint.mat','v','isgood','inputs');
    videoName = baseList{v,1};
    
    base_tubes = base_annot(v).tubes;
    
    index = find(strcmp(philList,videoName));
    phil_tubes = phill_annot(index).tubes;
    
    index = find(strcmp(aptList,videoName));
    apt_tubes = apt_annot(index).tubes;
    
    s1 = 0; s2 = 0;s3=0;
    
    %if length(phil_tubes) < length(base_tubes)
    for t = 1 : length(phil_tubes)
        s1 = s1 + uint16(phil_tubes(t).ef - phil_tubes(t).sf);
    end
    
    for t = 1 : length(base_tubes)
        s2 = s2 + base_tubes(t).ef - base_tubes(t).sf;
    end
    
    for t = 1 : length(apt_tubes)
        s3 = s3 + uint16(apt_tubes(t).ef - apt_tubes(t).sf);
    end
    
    num_imgs = base_annot(v).num_images;
    
    if abs(s2-s1)>1 || abs(s3-s1)>1 || abs(s2-s3)>1 ||(length(phil_tubes) ~= length(base_tubes )) || (length(apt_tubes) ~= length(base_tubes ))
        %if length(phil_tubes) ~= length(base_tubes)
%         count = count +1;
%         fprintf('v:= %04d num tubes(Philippe):= %02d num tubes(Ours):= %02d s1 %03d %03d %s %d\n',v,length(phil_tubes),length(base_tubes),s1,s2,videoName,count);
%         %-----------------------------------------------------------------------------------------
%         
%         if 0 %length(phil_tubes) < 15
%             
%             checkboxes(base_tubes,phil_tubes,apt_tubes,num_imgs,images_dir,save_path,videoName)
%         end
%         
%         inputs{v} = 'cf';
%         v = v + 1;
%         
%     else
        fprintf('v:= %04d num tubes(Philippe):= %02d num tubes(Ours):= %02d s1 %03d %03d %s %d\n',v,length(phil_tubes),length(base_tubes),s1,s2,videoName,count);
        cls = strsplit(videoName,'/');
        if  ~strcmp(cls{1},'SoccerJuggling')
            checkboxes(base_tubes,phil_tubes,apt_tubes,num_imgs,images_dir,save_path,videoName)
                prompt = {'Do you wnat to repeat(r)? are you statisfied (`y`)'};
            dlg_title = 'Input';
            num_lines = 1;
            defaultans = {'y'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            answer = answer{1};
        else
            answer='y';
        end
        inputs{v} = answer;
        if answer == 'b'
            prompt = {'Go back how many?'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            answer = str2num(answer{1});
            v = v-answer;
            
        else
            if answer == 'r'
                fprintf('we are going to repeat %d\n', v);
            elseif answer == 'y'
                isgood(v) = 1;
                v = v + 1;
            else
                isgood(v) = 0;
                v = v + 1;
            end
        end
        %         fprintf(answer)
    else
        v = v+1;
    end
    
end



function checkboxes(base_tubes,phil_tubes,apt_tubes,num_imgs,images_dir,save_path,videoName)


for i = 1 :1: num_imgs
    % fprintf('i=%d\n', i);
    philboxes = [];
    baseboxes = [];
    aptboxes = [];
    for t = 1 : length(phil_tubes)
        if phil_tubes(t).sf<= i && phil_tubes(t).ef >=i
            offset = uint16(phil_tubes(t).sf-1);
            philboxes = [philboxes;phil_tubes(t).boxes(i-offset,:)];
        end
    end
    
    for t = 1 : length(base_tubes)
        if i >= base_tubes(t).sf && i <= base_tubes(t).ef
            offset = uint16(base_tubes(t).sf-1);
            baseboxes = [baseboxes;base_tubes(t).boxes(uint8(i-offset),:)];
        end
    end
    
    for t = 1 : length(apt_tubes)
        if i >= apt_tubes(t).sf && i <= apt_tubes(t).ef
            offset = uint16(apt_tubes(t).sf-1);
            aptboxes = [aptboxes;apt_tubes(t).boxes(uint8(i-offset),:)];
        end
    end
    
    image_name = sprintf('%s/%s/%05d.jpg',images_dir,videoName,i);
    if ~isempty(philboxes) || ~isempty(baseboxes)
        plotBoxes(philboxes,baseboxes,aptboxes,image_name, videoName, save_path, i,num_imgs);
        pause(0.01);
    end
end

function plotBoxes(philboxes,baseboxes,aptboxes,img_file, videoName, save_path, framenr,num_imgs)

%str = strsplit(videoName,'/');
%action = str{1};
%videoname = str{2};

savepath = [save_path '/' videoName];
if ~exist(savepath,'dir')
    mkdir(savepath);
end

% savefile = sprintf('%s/%05d.jpg',savepath,framenr);

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
    rectangle('Position', philboxes(b,:), 'EdgeColor','b','LineWidth',5.0 );
    text(-50,steps(count),sprintf('phil %d',b),'Color','blue');
    count = count + 1;
end


for  b = 1 : size(baseboxes,1)
    rectangle('Position', baseboxes(b,:), 'EdgeColor','r','LineWidth',3.0 );
    text(-50,steps(count),sprintf('base %d',b),'Color','red');
    count = count + 1;
end

for  b = 1 : size(aptboxes,1)
    rectangle('Position', aptboxes(b,:), 'EdgeColor','g','LineWidth',1.0 );
    text(-50,steps(count),sprintf('apt %d',b),'Color','green');
    count = count + 1;
end

title([num2str(num_imgs),' ',num2str(framenr)])
pause(0.001)

% frm_save = getframe(gcf); %# Capture the current window
% imwrite(frm_save.cdata, savefile);
%imwrite(im,savefile);
%disp('ok');

function gtVidInd = getVidInd(video,videoName)
for i=1:length(video)
    vidid = video(i).name;
    if strcmp(vidid,videoName)
        gtVidInd = i;
        break;
    end
end


% philip annot with 0 tubes
% v:= 0553 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 CricketBowling/v_CricketBowling_g03_c02
% v:= 0554 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 CricketBowling/v_CricketBowling_g03_c03
% v:= 3054 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 VolleyballSpiking/v_VolleyballSpiking_g19_c01
% v:= 3005 num tubes(Philippe):= 00 num tubes(Ours):= 03 s1 000 000 VolleyballSpiking/v_VolleyballSpiking_g08_c05
% v:= 3008 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 VolleyballSpiking/v_VolleyballSpiking_g09_c02
% v:= 0577 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 CricketBowling/v_CricketBowling_g08_c04
% v:= 1238 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 HorseRiding/v_HorseRiding_g06_c02
% v:= 0555 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 CricketBowling/v_CricketBowling_g03_c04
% v:= 0133 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 Basketball/v_Basketball_g25_c06
% v:= 1298 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 HorseRiding/v_HorseRiding_g15_c04
% v:= 2748 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 TennisSwing/v_TennisSwing_g10_c05
% v:= 3019 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 VolleyballSpiking/v_VolleyballSpiking_g11_c03
% v:= 1666 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 PoleVault/v_PoleVault_g02_c07
% v:= 0496 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 CliffDiving/v_CliffDiving_g18_c04
% v:= 3000 num tubes(Philippe):= 00 num tubes(Ours):= 02 s1 000 000 VolleyballSpiking/v_VolleyballSpiking_g07_c07
% v:= 1206 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 HorseRiding/v_HorseRiding_g01_c05
% v:= 0587 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 CricketBowling/v_CricketBowling_g10_c02
% v:= 0552 num tubes(Philippe):= 00 num tubes(Ours):= 01 s1 000 000 CricketBowling/v_CricketBowling_g03_c01
