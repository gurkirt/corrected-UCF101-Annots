
clc
clear all

actions = {'Basketball','BasketballDunk','Biking','CliffDiving','CricketBowling',...
        'Diving','Fencing','FloorGymnastics','GolfSwing','HorseRiding','IceDancing',...
        'LongJump','PoleVault','RopeClimbing','SalsaSpin','SkateBoarding','Skiing',...
        'Skijet','SoccerJuggling','Surfing','TennisSwing','TrampolineJumping',...
        'VolleyballSpiking','WalkingWithDog'};
    
results = load('../results/peng-eccv16.mat'); % load('../results/saha-bmvc-detections.mat');
pengdetection = results.xmldata;
results = load('../results/saha-bmvc-detections.mat');
sahadetection = results.xmldata;
results = load('../results/rgb-fastflow-detections.mat');
fastflowDetections = results.xmldata;
results = load('../results/rgb-flow-detections.mat');
slowflowDetections  = results.xmldata;
load('../testlist.mat')

%% LOAD bmvc annot and eval above detections
annot = load('../annot_bmvc.mat');
mAPs = zeros(200,6); new = 0; count = 0;
% load('temp.mat');
for iou_th = [0.2,0.5:0.05:0.95]
    [smAP,smIoU,sacc,sAP] = get_PR_curve(annot.videos, sahadetection, testlist, actions,  iou_th);
    [ffmAP,ffmIoU,ffacc,ffAP] = get_PR_curve(annot.videos, fastflowDetections, testlist, actions,  iou_th);
    [sfmAP,sfmIoU,sfacc,sfAP] = get_PR_curve(annot.videos, slowflowDetections, testlist, actions,  iou_th);
    [pmAP,pmIoU,pacc,pAP] = get_PR_curve(annot.videos, pengdetection, testlist, actions,  iou_th);
    count = count + 1;
    mAPs(count,:) = [new,iou_th, smAP, ffmAP, sfmAP,pmAP];
    fprintf('IOU-TH %.2f SAHA %0.3f FASTFLOW %0.3f SLOWFLOW %0.3f PENG %0.3fN\n',iou_th,smAP,ffmAP,sfmAP,pmAP);
end 
% save('temp.mat','mAPs','count');
%% LOAD new annots and eval above detections
annot = load('../finalAnnots.mat'); new = 1;
for iou_th = [0.2,0.5:0.05:0.95]
    [smAP,smIoU,sacc,sAP] = get_PR_curve(annot.annot, sahadetection, testlist, actions,  iou_th);
    [ffmAP,ffmIoU,ffacc,ffAP] = get_PR_curve(annot.annot, fastflowDetections, testlist, actions,  iou_th);
    [sfmAP,sfmIoU,sfacc,sfAP] = get_PR_curve(annot.annot, slowflowDetections, testlist, actions,  iou_th);
    [pmAP,pmIoU,pacc,pAP] = get_PR_curve(annot.annot, pengdetection, testlist, actions,  iou_th);
    count = count + 1;
    mAPs(count,:) = [new,iou_th, smAP, ffmAP, sfmAP,pmAP];
    fprintf('IOU-TH %.2f SAHA %0.3f FASTFLOW %0.3f SLOWFLOW %0.3f PENG %0.3f N\n',iou_th,smAP,ffmAP,sfmAP,pmAP);
end 
mAPs(count+1:end,:) = [];
save('mAPs.mat','mAPs');
