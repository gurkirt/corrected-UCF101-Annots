function s6_resave_annot_after_remaing()
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
load('lastdata.mat')
% merged_annot = struct();
load('merged_annot_temporal');
load('checkpoint_improved_temporal.mat')
v = 1;vc =0;
while v <= length(baseList)
    
    videoName = baseList{v,1};
    
    base_tubes = base_annot(v).tubes;
    
    index = find(strcmp(philList,videoName));
    phil_tubes = phill_annot(index).tubes;
    
    index = find(strcmp(aptList,videoName));
    apt_tubes = apt_annot(index).tubes;
    
    class = base_annot(v).tubes(1).class;
    num_imgs = base_annot(v).num_images;
    
    merged_annot(v).num_imgs = num_imgs;
    merged_annot(v).name = base_annot(v).name;
    
    
    
    if ~isgood(v) % && strcmp(inputs{v},'t')
        vc = vc +1;
        newcell = tdata{v};
        tline = newcell{1};
        stl = strsplit(tline,' ');
        
        if length(stl{1})>1
            inputs{v} = 'ra';
            isgood(v) = 0;
            merged_annot(v).tubes = base_annot(v).tubes;
        else
            merged_annot(v).tubes = extract_bounds(newcell, base_tubes, phil_tubes, apt_tubes, num_imgs,class);
            inputs{v} = 'y';
            isgood(v) = 1;
        end
  
    end
    v=v+1;
    
end
% vc
fprintf('%d\n',sum(isgood));
save('checkpoint_improved_after_remaining.mat','isgood','inputs');
save('merged_annot_remianing.mat','merged_annot')

function tubes = extract_bounds(newcell, base_tubes, phil_tubes, apt_tubes, num_imgs,class)
tubes = struct();
alltubes = {base_tubes,phil_tubes,apt_tubes};
for t = 1 : length(newcell)
    tline = newcell{t};
    stl = strsplit(tline,' ');
    
    if length(stl)<6
        [sf,ef,boxes] = gettube(alltubes,stl,num_imgs,0);
    else
        [sf,ef,boxes] = gettube(alltubes,stl,num_imgs,1);
    end
    tubes(t).sf = sf;
    tubes(t).ef = ef;
    tubes(t).class = class;
    tubes(t).boxes = boxes;
end
   
function [sf,ef,boxes] = gettube(alltubes,stl,num_imgs,isone)
tube  = [];
annotType = {'b','p','a'};
ind = find(strcmp(annotType,stl{1}));

annot = alltubes{ind};

tid = str2num(stl{2}); 

sf = max(str2num(stl{3}),annot(tid).sf);

ef = min(str2num(stl{4}),annot(tid).ef);
st = sf-annot(tid).sf+1;
et = ef-sf+st; ct = 1;
boxes = annot(tid).boxes(st:et,:);
if isone
    ind = find(strcmp(annotType,stl{5}));
    annot = alltubes{ind};
    tid = str2num(stl{6}); 
    sfa = str2num(stl{7});
    if (sfa-ef)>1
        for kk = 1:(sfa-ef-1) 
            boxes = [boxes;boxes(end,:)];
        end
    end 
    ef = str2num(stl{8});
    st = sfa-annot(tid).sf+1;
    et = ef-sfa+st; ct = 1;
    boxes = [boxes;annot(tid).boxes(st:et,:)];
end




    
