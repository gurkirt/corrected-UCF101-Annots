function s7_resave_final_remove_last_frame_errors()

load('testnames.mat')
load('merged_annot_remianing.mat')
load('checkpoint_improved_after_remaining.mat')
testlist = cell(2,1);
v = 1;

trainannot = struct(); traincount = 0;
testannot = struct(); testcount = 0;
combinedannot = struct(); comcount = 0;
vc = 0;
while v <= length(merged_annot)
    
    num_imgs = merged_annot(v).num_imgs;
    videoname = merged_annot(v).name;
    
    if isgood(v)
        
        [tubes,cc] = verifyTubes(merged_annot(v).tubes,num_imgs);
        vc = vc +cc;
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
    v=v+1;
    
end

fprintf('corrected %d tubes\n',vc);
save('../testlist','testlist');
annot = trainannot;
save('../trainAnnot.mat','annot');
annot = testannot;
save('../testAnnot.mat','annot')
annot = combinedannot;
save('../finalAnnots.mat','annot')

function [newtubes,cc] = verifyTubes(tubes, num_imgs)
cc = 0;tc = 0;
newtubes = struct();
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
           disp('erororororor') 
    end
end
