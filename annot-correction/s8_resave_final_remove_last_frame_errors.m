function s8_resave_final_remove_last_frame_errors()

load('testnames.mat')
load('newAnnotats.mat')
load('checkpoint_improved_after_remaining.mat')
testlist = cell(2,1);
v = 1;

trainannot = struct(); traincount = 0;
testannot = struct(); testcount = 0;
combinedannot = struct(); comcount = 0;
vc = 0;
doCheck = 1;
load('final-merged-check.mat')

v = 1;

while v <= length(merged_annot)
    
    num_imgs = merged_annot(v).num_imgs;
    videoname = merged_annot(v).name;
    
    if isgood(v)
        tubes = merged_annot(v).tubes;
        
        if isfield(tubes,'ef')
            [tubes,cc1] = verifyTubes(tubes,num_imgs,v,videoname);
            if isfield(tubes,'ef')
                [tubes,cc2] = verifysfef(tubes,num_imgs,v,videoname);
                [tubes,cc3] = verifyboxes(tubes,num_imgs,v,videoname);
                
                if ~isempty(cc3)>0
                    tubes = correctboxes(tubes,num_imgs,v,videoname,cc3);
                    vc = vc+1;
                end
                
                [tubes,cc4] = verifyTubes(tubes,num_imgs,v,videoname);
            end
        end
        merged_annot(v).tubes = tubes;
        
        if (cc4+cc3+cc2+cc1)>0
            save('final-merged-check.mat','v','merged_annot')
        end

        
    end
    v=v+1;
end

save('final-merged-check.mat','v','merged_annot')
fprintf('corrected %d tubes\n',vc);


function [newtubes,cc] = verifyTubes(tubes, num_imgs,v,videoname)
cc = 0;tc = 0;
newtubes = struct();

for t = 1 : length(tubes)
    ef = tubes(t).ef;
    sf = tubes(t).sf;
    if ef>sf && (ef-sf)>2
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
        if ~isfield(tubes(t),'class')
            tubes(t).class = 24;
        end
        newtubes(tc).class = tubes(t).class;
    else
        fprintf('%d %s\n',v,videoname);
    end
end

function [newtubes,cc] = verifysfef(tubes, num_imgs,v,videoname)
cc = 0;tc = 0;
newtubes = struct();
for t = 1 : length(tubes)
    
    ef = tubes(t).ef;
    
    if ef>num_imgs
        tubes(t).ef = num_imgs;
        ef = num_imgs;
    end
    
    sf = tubes(t).sf;
    numboxes = size(tubes(t).boxes,1);
    fdiff = ef-sf+1-numboxes;
    
    if fdiff<0
        tc = tc +1;
        newtubes(tc).ef = tubes(t).ef;
        newtubes(tc).sf = tubes(t).sf;
        newtubes(tc).boxes = tubes(t).boxes;
        fdiff = abs(fdiff);
        newtubes(tc).boxes = tubes(t).boxes(1:end-fdiff+1,:);
        
    else
        tc = tc +1;
        newtubes(tc).ef = tubes(t).ef;
        newtubes(tc).sf = tubes(t).sf;
        newtubes(tc).boxes = tubes(t).boxes;
        newtubes(tc).class = tubes(t).class;
    end
    
end

function [tubes,tss] = verifyboxes(tubes, num_imgs,v,videoname)

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
        
        if xmax>320 && xmax<345
            xmax = 320;
        end
        if xmin<1 && xmin>-20
            xmin=1;
        end
        
        if ymax>240 && ymax<261
            ymax = 240;
        end
        if ymin<1 && ymin>-20
            ymin=1;
        end
        
        if xmin<1 || xmin>310 || xmax<1 || xmax>320 || ymin<1 || ymin>230 || ymax<1 || ymax>240
            cc = cc +1;
            fprintf('we have problem in %s xmin %d xmax %d ymin %d ymax %d sf %d ef %d imgnum %d\n',videoname,xmin,xmax,ymin,ymax,sf,ef,imgnum);
        end
        bb(1) = xmin;bb(2)=ymin;
        bb(3) = xmax-xmin;
        bb(4) = ymax-ymin;
        newboxes(kk,:) = bb;
    end
    if cc==0
        tubes(t).boxes = newboxes;
    else
        tubes(t).boxes = newboxes;
        tss = [tss;t];
    end
    
end

function tubes = correctboxes(tubes,num_imgs,v,videoname, tss)

images_dir = ['/mnt/sun-alpha/datasets/UCF101/images/',videoname,'/'];
ind = 1;
for ii = 1: length(tss)
    t = tss(ii);
    ef = tubes(t).ef;
    sf = tubes(t).sf;
    newboxes = tubes(t).boxes;
    numboxes = size(tubes(t).boxes,1);
    
    checkR = 0;
    checkF = 0;
    for kk = 1 : numboxes
        imgnum = sf+kk-1;
        imgname = sprintf('%s%05d.jpg',images_dir,imgnum);
        bb = newboxes(kk,:);
        
        xmin = bb(1);
        xmax = bb(1)+bb(3);
        ymin = bb(2);
        ymax = bb(2)+bb(4);
        
        if xmax>320 && xmax<340
            xmax = 320;
        end
        if xmin<1 && xmin>-20
            xmin=1;
        end
        
        if ymax>240 && ymax<260
            ymax = 240;
        end
        if ymin<1 && ymin>-20
            ymin=1;
        end
        
        if xmin<1 || xmin>310 || xmax<1 || xmax>320 || ymin<1 || ymin>230 || ymax<1 || ymax>240
            
            
            fprintf('we have problem in %s XXX or YYY xmin %d xmax %d ymin %d ymax %d sf %d ef %d imgnum %d\n',videoname,xmin,xmax,ymin,ymax,sf,ef,imgnum);
            image = imread(imgname);
            hold off
            imshow(image);
            hold on
            rectangle('Position', newboxes(kk,:), 'EdgeColor','r','LineWidth',2.0 );
            prompt = {'Do you wnat to repeat(r)? are you statisfied (`y`)'};
            dlg_title = 'Input';
            num_lines = 1;
            defaultans = {'f'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            answer = answer{1};
            
            if answer == 'y'
                if xmax>320
                    xmax = 320;
                end
                if xmin<1
                    xmin=1;
                end
                
                if ymax>240
                    ymax = 240;
                end
                if ymin<1
                    ymin=1;
                end
                bb(1) = xmin;bb(2)=ymin;
                bb(3) = xmax-xmin;
                bb(4) = ymax-ymin;
                newboxes(kk,:) = bb;
                checkF = 1;
            elseif answer == 'f'
                checkF = 1;
                newboxes(kk,:) = [-1,-1,-1,-1];
            elseif answer == 'r'
                checkR = 1;
                newboxes(kk,:) = [1000,1000,1000,1000];
            else
                checkF = 1;
                prompt = {'Enter the new coordinates'};
                dlg_title = 'Input';
                num_lines = 1;
                defaultans = {[num2str(xmin),',',num2str(xmax),',',num2str(ymin),',',num2str(ymax)]};
                answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                answer = strsplit(answer{1},',');
                xmin = str2num(answer{1});
                xmax = str2num(answer{2});
                ymin = str2num(answer{3});
                ymax = str2num(answer{4});
                bb(1) = xmin;bb(2)=ymin;
                bb(3) = xmax-xmin;
                bb(4) = ymax-ymin;
                newboxes(kk,:) = bb;
            end
        end
    end
    if checkR
        torep = newboxes(:,1)<999;
        torep = torep';
        offset = find(torep);
        if isempty(offset)
            tubes(t).ef = 1;
            tubes(t).sf = 1;
            tubes(t).boxes = [];newboxes = [];
        else
            offset = offset(1);
            if offset>1
                sf = sf + offset-1;
                newboxes(1:offset-1,:) = [];
                tubes(t).sf = sf;
            end
            torep = fliplr(torep);
            offset = find(torep);
            offset = offset(1);
            if offset>1
                ef = ef-offset+1;
                newboxes(end-(offset-2):end,:) = [];
                tubes(t).ef = ef;
            end
        end
    end
    if checkF
        torep = newboxes(:,1)<1 | newboxes(:,1)>999;
        
        for kk = 1 : length(torep)
            if torep(kk)
                indexvector = 1:length(torep);
                indexvector = abs(indexvector - kk);
                indexvector(kk) = 1000;
                indexvector(torep) = 1000;
                [~,ind] = min(indexvector);
                newboxes(kk,:) = newboxes(ind,:);
            end
        end
        
    end
    
    tubes(t).boxes = newboxes;
    
end
