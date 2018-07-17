%%%%%%%%%%%%%%%%%% Panda Head Meme Generator Demo %%%%%%%%%%%%%%%%%%%%%%%%%

%% Description Section

% The Screen-captured Jacky Cheung picture comes from 
% https://www.zhihu.com/question/58800555/answer/159127385
% The Panda Head Meme will be generated from this picture by using facial
% recognition. The title image is produced by this MATLAB script
%
% The Panda Head Template was obtained here: 
% https://blog.csdn.net/CHIMO_HS/article/details/78090622

% Author: https://github.com/chouj

%% Code Section

% load the picture
videoFrame = imread('.\GeShen.png');
figure;
s1=subplot(3,3,1);
imshow(videoFrame);
title('Original Pic'); % show the original screen-captured picture

% Face Detector Created
faceDetector = vision.CascadeObjectDetector();

% "roi" means region of interested. Here it is recognized facial area.
roi = step(faceDetector, videoFrame);

% The facial area is cropped and transfered into gray scale.
f=imcrop(videoFrame,roi);
gray=rgb2gray(f);


s2=subplot(3,3,2);
imshow(gray,[]);
title('Face Recognition');% show the recognized facial area.

% Within the facial area, detect left eye of Jacky
leyedetector = vision.CascadeObjectDetector('ClassificationModel','LeftEyeCart');
leyebbox=step(leyedetector,f);
%figure;imshow(imcrop(f,leyebbox(1,:)));

% Detect right eye of Jacky
reyedetector = vision.CascadeObjectDetector('ClassificationModel','RightEyeCart');
reyebbox=step(reyedetector,f);

% Detect nose of Jacky
nosedetector = vision.CascadeObjectDetector('ClassificationModel','Nose');
nosebbox=step(nosedetector,f);

% Detect mouth of Jacky
mdetector = vision.CascadeObjectDetector('ClassificationModel','Mouth','ScaleFactor',1.5,'MaxSize',[100 70]);
mbbox=step(mdetector,f);

% Edge Gaussian blurring to get rid of some noises. Not necessary.
logic=zeros(size(gray)); % for combine detected eyes, nose and mouth into one picture.

clear PSF
leye=imcrop(gray,leyebbox);
PSF = fspecial('gaussian',round(size(leye,1)/10),10);
leyeTapered  = edgetaper(leye,PSF);
logic(leyebbox(1,2):leyebbox(1,2)+leyebbox(1,4),leyebbox(1,1):leyebbox(1,1)+leyebbox(1,3))=leyeTapered;

reyedetector = vision.CascadeObjectDetector('ClassificationModel','RightEyeCart');
reyebbox=step(reyedetector,f);
clear PSF
reye=imcrop(gray,reyebbox(1,:));
PSF = fspecial('gaussian',round(size(reye,1)/10),10);
reyeTapered  = edgetaper(reye,PSF);
logic(reyebbox(1,2):reyebbox(1,2)+reyebbox(1,4),reyebbox(1,1):reyebbox(1,1)+reyebbox(1,3))=reyeTapered;

nosedetector = vision.CascadeObjectDetector('ClassificationModel','Nose');
nosebbox=step(nosedetector,f);
clear PSF
nose=imcrop(gray,nosebbox);
PSF = fspecial('gaussian',round(size(nose,1)/10),10);
noseTapered  = edgetaper(nose,PSF);
logic(nosebbox(1,2):nosebbox(1,2)+nosebbox(1,4),nosebbox(1,1):nosebbox(1,1)+nosebbox(1,3))=noseTapered;

mdetector = vision.CascadeObjectDetector('ClassificationModel','Mouth','ScaleFactor',1.5,'MaxSize',[100 70]);
mbbox=step(mdetector,f);
clear PSF
m=imcrop(gray,mbbox(end,:));
PSF = fspecial('gaussian',round(size(m,1)/10),10);
mTapered  = edgetaper(m,PSF);
logic(mbbox(end,2):mbbox(end,2)+mbbox(end,4),mbbox(end,1):mbbox(end,1)+mbbox(end,3))=mTapered;

s3=subplot(3,3,3);
imshow(logic,[])
title([{'Eyes, Nose, Mouth Detection'},{'After Tapered'}]);
% show detected eyes, nose and mouth after EdgeTapered

% remove the area where its value is zero
for i=1:size(logic,1);temp=find(logic(i,:)>0);if isempty(temp)==0;xmin(i)=min(temp);xmax(i)=max(temp);else xmin(i)=nan;xmax(i)=nan;end;end
for i=1:size(logic,2);temp=find(logic(:,i)>0);if isempty(temp)==0;ymin(i)=min(temp);ymax(i)=max(temp);else ymin(i)=nan;ymax(i)=nan;end;end
cropf=imcrop(logic,[min(xmin) min(ymin) max(xmax)-min(xmin)+1 max(ymax)-min(ymin)+1]);

% Change black background into white
d=cropf;
d(d==0)=max(d(:));
d=d/max(d(:));

% Increase brightness
dd=d+0.6; % "0.6" can be modified here or use imadjust(); to adjust
dd(dd>1)=1;

s4=subplot(3,3,4);
imshow(dd,[]);
title(s4,[{'Cropped and Brightness Adjustment'},{'Gray Style'}]);
% Gray style obtained

% 4-level gray
ddd=mat2gray(dd);
dddd=ones(size(dd));
dddd(ddd<0.25)=0;dddd(ddd>=0.25&ddd<0.5)=0.25;dddd(ddd>=0.5&ddd<0.75)=0.5;dddd(ddd>=0.75)=0.75;

% 8-level gray
% dddd(ddd<0.125)=0;dddd(ddd>=0.125&ddd<0.25)=0.125;dddd(ddd>=0.25&ddd<0.375)=0.25;dddd(ddd>=0.375&ddd<0.5)=0.375;
% dddd(ddd>=0.5&ddd<0.625)=0.5;dddd(ddd>=0.625&ddd<0.75)=0.625;dddd(ddd>=0.75&ddd<0.875)=0.75;dddd(ddd>=0.875)=0.875;

s5=subplot(3,3,5);
imshow(dddd,[]);
title([{'Pixelate'},{'4-level Gray'}]);
% pixelate obtained

% Binarization: only black and white
% db=im2bw(d,graythresh(d));
db=im2bw(d,0.3);

s6=subplot(3,3,6);imshow(db);
title('Binarization');

% T
xm=imread('.\xm.png');
newxm=imresize(xm,1.75*size(cropf,1)/size(xm,1)); % Modify size of the panda head template according to size of recognized face.
newxm=rgb2gray(newxm);
nnewxm=newxm(4:end-3,4:end-3); %remove dark boundary of panda head template
nnewxm=double(nnewxm)./255;

% put grayscale face in the center of template
nnewxm(round(size(nnewxm,1)/2)-floor(size(cropf,1)/2):round(size(nnewxm,1)/2)-floor(size(cropf,1)/2)+size(cropf,1)-1,...
    round(size(nnewxm,2)/2)-floor(size(cropf,2)/2):round(size(nnewxm,2)/2)-floor(size(cropf,2)/2)+size(cropf,2)-1)=mat2gray(dd);
s7=subplot(3,3,7);imshow(nnewxm);

% put 4-level face image in the center of template
nnewxm(round(size(nnewxm,1)/2)-floor(size(cropf,1)/2):round(size(nnewxm,1)/2)-floor(size(cropf,1)/2)+size(cropf,1)-1,...
    round(size(nnewxm,2)/2)-floor(size(cropf,2)/2):round(size(nnewxm,2)/2)-floor(size(cropf,2)/2)+size(cropf,2)-1)=mat2gray(dddd);
s8=subplot(3,3,8);imshow(nnewxm);

% put binarized face image in the center of template
nnewxm(round(size(nnewxm,1)/2)-floor(size(cropf,1)/2):round(size(nnewxm,1)/2)-floor(size(cropf,1)/2)+size(cropf,1)-1,...
    round(size(nnewxm,2)/2)-floor(size(cropf,2)/2):round(size(nnewxm,2)/2)-floor(size(cropf,2)/2)+size(cropf,2)-1)=db;
s9=subplot(3,3,9);imshow(nnewxm);