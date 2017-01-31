function s7_resave_final_check_for_errors()


stp = load('annot_full_Philippe.mat'); % train+test
phill_annot = stp.videos;
clear stp;

stp = load('annot_apt.mat'); % train+test
apt_annot = stp.videos;
clear stp;

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

load('testnames.mat')
% load('merged_annot_remianing.mat')
load('checkpoint_improved_after_remaining.mat')
load('newAnnotats.mat')
vc = 0; tdata = cell(2,1); %v=1;
while v <= length(merged_annot)
    
    num_imgs = merged_annot(v).num_imgs;
    videoname = merged_annot(v).name;
    
    
    if isgood(v)
        [base_tubes,cc,ca] = verifyTubes(merged_annot(v).tubes,num_imgs,v,videoname);
        vc = vc +cc;
        if ca
            
            
            
            index = find(strcmp(philList,videoname));
            phil_tubes = phill_annot(index).tubes;
            
            index = find(strcmp(aptList,videoname));
            apt_tubes = apt_annot(index).tubes;
            base_tubes = merged_annot(v).tubes;
            if v == 1855
                base_tubes.sf = 1;
                base_tubes.ef = num_imgs;
                base_tubes.boxes = repmat(base_tubes.boxes,num_imgs,1);
                base_tubes.class = base_tubes.class;
            end
            checkboxes(base_tubes,phil_tubes,apt_tubes,num_imgs,images_dir,save_path,videoname)
            
            fid = fopen('temp.txt','w');
            
            fid = fopen('temp.txt','w');
            
            for t = 1 : length(base_tubes)
                fprintf(fid,'b %d %d %d\n', t, base_tubes(t).sf, base_tubes(t).ef);
            end
            
            for t = 1 : length(phil_tubes)
                fprintf(fid,'p %d %d %d\n', t, phil_tubes(t).sf, phil_tubes(t).ef);
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
            class = phil_tubes(1).class;
            base_tubes = extract_bounds(newcell, base_tubes, phil_tubes, apt_tubes, num_imgs,class);
            merged_annot(v).tubes = base_tubes;
            save('newAnnotats.mat','merged_annot','v');
        end
        
        merged_annot(v).tubes = base_tubes;
        
        
    end
    v=v+1;
end
save('newAnnotats.mat','merged_annot','v');

% fprintf('corrected %d tubes\n',vc);
% save('../testlist','testlist');
% annot = trainannot;
% save('../trainAnnot.mat','annot');
% annot = testannot;
% save('../testAnnot.mat','annot')
% annot = combinedannot;
% save('../finalAnnots.mat','annot')

function [newtubes,cc,ca] = verifyTubes(tubes, num_imgs,v,videoname)
cc = 0;tc = 0;ca=0;
newtubes = struct();
if isfield(tubes,'ef')>0
    for t = 1 : length(tubes)
        ef = tubes(t).ef;
        sf = tubes(t).sf;
        if ef>sf
            fdiff = abs(num_imgs-ef);
            if fdiff==1 || fdiff==2
                cc = cc+1;
                tubes(t).ef = num_imgs;
                for kk = 1:fdiff
                    tubes(t).boxes = [tubes(t).boxes;tubes(t).boxes(end,:)];
                end
            end
            tc = tc +1;
            newtubes(tc).ef = tubes(t).ef;
            newtubes(tc).sf = tubes(t).sf;
            newtubes(tc).boxes = tubes(t).boxes;
            newtubes(tc).class = tubes(t).class;
        else
            fprintf('%d %s\n',v,videoname);
            ca=1;
        end
    end
else
    fprintf('tube is empty %d %s\n',v,videoname);
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
            philboxes = [philboxes;phil_tubes(t).boxes(i-offset,:),t];
        end
    end
    if isfield(base_tubes,'sf')
        for t = 1 : length(base_tubes)
            if i >= base_tubes(t).sf && i <= base_tubes(t).ef
                offset = uint16(base_tubes(t).sf-1);
                baseboxes = [baseboxes;base_tubes(t).boxes(uint8(i-offset),:),t];
            end
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

