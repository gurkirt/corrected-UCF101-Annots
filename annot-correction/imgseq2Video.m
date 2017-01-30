img_path = '/mnt/sun-alpha/compare_phillipe_and_our_ucf101_annot/images';
save_path = '/mnt/jupiter-alpha/check_annot/videos';

if ~exist(save_path,'dir')
    mkdir(save_path);
end
actionList = dir(img_path);
for i=3:length(actionList)
    action = actionList(i).name;
    %fprintf('%s\n',action);
    
    img_path_1 = [img_path '/' action];
    videoList = dir(img_path_1);
    for j=3:length(videoList)
        videoName = videoList(j).name;
        %fprintf('%s\n',videoName);
        imgpath = [img_path '/' action '/' videoName];
        savepath = [save_path '/' action];
        if ~exist(savepath,'dir')
            mkdir(savepath);
        end
        %command = sprintf('ffmpeg -start_number 1 -i %s/%%05d.jpg -vcodec mpeg4 %s/%s.avi', imgpath, savepath, videoName);
        command = sprintf('ffmpeg -f image2 -i %s/%%05d.jpg -vcodec mpeg4 %s/%s.avi', imgpath, savepath, videoName);
        % ffmpeg -f image2 -i image%d.jpg -vcodec mpeg4 -b 800k video.avi
        
        %disp(command);
        system(command);
        fprintf('done writign video %s\n', command);
        %pause;
    end
    
    
end



% command = sprintf('ffmpeg -i %s.avi %s/%%05d.ppm >/dev/null', video_path,im_path_ppm);


%where n is the start of the sequence of stills.

%command = sprintf('ffmpeg -i %s.avi %s/%%05d.ppm >/dev/null', video_path,im_path_ppm);
