function s9_final_crossCheck()

load('testnames.mat')
load('newAnnotats.mat')
load('checkpoint_improved_after_remaining.mat')
testlist = cell(2,1);


trainannot = struct(); traincount = 0;
testannot = struct(); testcount = 0;
combinedannot = struct(); comcount = 0;
vc = 0;

load('final-merged-check.mat')

v =1;
while v <= length(merged_annot)
    
    num_imgs = merged_annot(v).num_imgs;
    videoname = merged_annot(v).name;
    
    if isgood(v)
        tubes = merged_annot(v).tubes;
        
        if isfield(tubes,'ef')
            [tubes,cc1] = verifyTubes(tubes,num_imgs,v,videoname);
            if isfield(tubes,'ef')
                [tubes,tss] = verifyboxes(tubes,v,videoname);
                merged_annot(v).tubes = tubes;
                
                if sum(strcmp(testvideos,videoname))
                    testcount = testcount +1;
                    testlist{testcount} = videoname;
                    testannot(testcount).num_imgs = num_imgs;
                    testannot(testcount).name = videoname;
                    testannot(testcount).tubes = tubes;
                else
                    traincount = traincount +1;
                    trainannot(traincount).num_imgs = num_imgs;
                    trainannot(traincount).name = videoname;
                    trainannot(traincount).tubes = tubes;
                end
                comcount = comcount +1;
                combinedannot(comcount).num_imgs = num_imgs;
                combinedannot(comcount).name = videoname;
                combinedannot(comcount).tubes = tubes;
            end
        end
    end
    v=v+1;
end

save('final-merged-check.mat','v','merged_annot')

fprintf('corrected %d tubes\n',vc);
save('../testlist','testlist');
annot = trainannot;
save('../trainAnnot.mat','annot');
annot = testannot;
save('../testAnnot.mat','annot')
annot = combinedannot;
save('../finalAnnots.mat','annot')

function [newtubes,cc] = verifyTubes(tubes, num_imgs,v,videoname)
actions = {'Basketball','BasketballDunk','Biking','CliffDiving','CricketBowling',...
        'Diving','Fencing','FloorGymnastics','GolfSwing','HorseRiding','IceDancing',...
        'LongJump','PoleVault','RopeClimbing','SalsaSpin','SkateBoarding','Skiing',...
        'Skijet','SoccerJuggling','Surfing','TennisSwing','TrampolineJumping',...
        'VolleyballSpiking','WalkingWithDog'};
vids = strsplit(videoname,'/');
class = vids;
class = find(strcmp(actions,vids{1}));
cc = 0;tc = 0;
newtubes = struct();
images_dir = ['/mnt/sun-alpha/datasets/UCF101/images/',videoname,'/'];
imglist = dir([images_dir,'*.jpg']);
if num_imgs == length(imglist)
    for t = 1 : length(tubes)
        ef = tubes(t).ef;
        sf = tubes(t).sf;
        numbox = size(tubes(t).boxes,1);
        fdiff = ef-sf+1-numbox;
        if ef>sf && (ef-sf)>2 && fdiff==0
            fprintf('All is well for primary check v %04d %s\n',v,videoname)
            tc = tc +1;
            newtubes(tc).ef = double(tubes(t).ef);
            newtubes(tc).sf = double(tubes(t).sf);
            newtubes(tc).class = double(class);
            newtubes(tc).boxes = double(tubes(t).boxes);
        elseif ef>sf && (ef-sf)>2  && abs(fdiff)<5
            
            
            if fdiff>0
                for kk = 1:fdiff
                    tubes(t).boxes = [tubes(t).boxes;tubes(t).boxes(end,:)];
                end
            else
                tubes(t).boxes(end+fdiff+1:end,:) =[];
            end
            tc = tc +1;
            newtubes(tc).ef = double(tubes(t).ef);
            newtubes(tc).sf = double(tubes(t).sf);
            newtubes(tc).class = double(class);
            newtubes(tc).boxes = double(tubes(t).boxes);
        elseif abs(fdiff)>=5
            fprintf('fdiff is %d\n',fdiff);
        else
            fprintf('something is wrong in primary check %d %s\n',v,videoname);
            error()
        end
    end
else
    fprintf('check for imglist v %04d %s\n',v,videoname);
    error()
end

function [tubes,tss] = verifyboxes(tubes,v,videoname)

images_dir = ['/mnt/sun-alpha/datasets/UCF101/images/',videoname,'/'];
tss = [];
for t = 1 : length(tubes)
    ef = tubes(t).ef;
    sf = tubes(t).sf;
    numboxes = size(tubes(t).boxes,1);
    cc = 0;
    newboxes = tubes(t).boxes;
    for kk = 1 : numboxes
        imgnum = sf+kk-1;
        imgname = sprintf('%s%05d',images_dir,imgnum);
        bb = newboxes(kk,:);
        xmin = bb(1);
        xmax = bb(1)+bb(3);
        ymin = bb(2);
        ymax = bb(2)+bb(4);
        
        
        if xmin<1 || xmin>310 || xmax<1 || xmax>320 || ymin<1 || ymin>230 || ymax<1 || ymax>240
            cc = cc +1;
            fprintf('we have problem in %s xmin %d xmax %d ymin %d ymax %d sf %d ef %d imgnum %d\n',videoname,xmin,xmax,ymin,ymax,sf,ef,imgnum);
        end

    end
    
    if ~(cc==0)
        fprintf('Check boxes v %d %s', v,videoname);
        error();
        tss = [tss;t];
    end
    
end
