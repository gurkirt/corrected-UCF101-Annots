function s2_resave_annot()
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
merged_annot = struct();
v = 1;
while v <= length(baseList)
    
    videoName = baseList{v,1};
    
    base_tubes = base_annot(v).tubes;
    
    index = find(strcmp(philList,videoName));
    phil_tubes = phill_annot(index).tubes;
    
    index = find(strcmp(aptList,videoName));
    apt_tubes = apt_annot(index).tubes;
    num_imgs = base_annot(v).num_images;
    
    merged_annot(v).num_imgs = num_imgs;
    merged_annot(v).name = base_annot(v).name;
    
    if ~isgood(v) && strcmp(inputs{v},'p')
        merged_annot(v).tubes = base_tubes;
        inputs{v} = 'y';
        isgood(v) = 1;
    elseif ~isgood(v) && strcmp(inputs{v},'a')
        merged_annot(v).tubes = base_tubes;
        inputs{v} = 'y';
        isgood(v) = 1;
    else
        merged_annot(v).tubes = base_tubes;
    end
    v=v+1;
    
end

save('checkpoint_improved.mat','isgood','inputs','v');
save('merged_annot.mat','merged_annot')


    
