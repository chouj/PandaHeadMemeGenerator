function PandaHeadGenerator(input_image,input_template,output_meme,varargin)

% Use Face Recognition to Generate PandaHead Meme from a Facial Photo
%
% Features:
%
% - Photo Orientation Detection: Rotate the photo until a face can be 
%   recognized.
%
% - Eyes, nose and mouth are recognized separately after facial recognition
%
% - All the results of recognition at each step will be shown to let you 
%   choose the right one.
%
% - If facial symmetry axis is not vertical, calculate its angle and
%   rotate the photo a little bit to enhance the accuracy of facial
%   recognition.
%
% - Gray style, 4-level gray (pixelate style) or binarization style (black 
%   and white) can be choosen by using optional parameter "mode" (see 
%   Usage).
%
% - In order to obtain the best effect of facial expression, a
%   parameter can be adjusted manually and repeatedly until satisfied.
%
% - At most two rows of text can be added below PandaHead to make it a
%   final meme. The default font is Microsoft YaHei.
%
% Usage:
%
% - input_image: the file name and its associated path of facial photo from
%   which the meme will be generated. It will be loaded by "imread", thus
%   common pic formats are supported. For exmaple, 'E:\folder_one\kid.jpg'.
%   In addition, high-resolution picture is preferred.
%
% - input_template: the file name and its associated path of template of 
%   Panda Head. It can be downloaded here: 
%   https://github.com/chouj/PandaHeadMemeGenerator/blob/master/xm.png
%
% - output_image: the filename for generated PandaHead meme. Its filename
%   extension ".jpg" is required. For exmaple, 'E:\folder_one\kidmeme.jpg'.
%   You can modified associated codes below to write it into other 
%   formats.
%
% - parameter/value pairs: 'mode', 'gray'. Default output mode is gray 
%   style. 
%
% - 'mode', 'pixelate': pixelate style (4-level gray).
%
% - 'mode', 'b&w' only black and white (binarizatoin). 
%
% - parameter/value pairs: 'textrow1', string. Add first phrase below 
%   panda head.
%
% - 'textrow1',string : Add another sentence.
%
% Example:
%     PandaHeadGenerator(...
%        'c:\o3.jpg',...
%        'c:\users\lenovo\downloads\xm.png',...
%        '.\me',...
%        'mode','gray',...
%        'textrow1','°á×©¹¤ÈËµÄ',...
%        'textrow2','ÃÕÖ®Î¢Ð¦');
%
% The title image in Github page can be produced by running 
%   PandaHeadMemeGeneratorDemo.m.
%   https://github.com/chouj/PandaHeadMemeGenerator/blob/master/PandaHeadMemeGeneratorDemo.m
%
% Author:
%   https://github.com/chouj
%   JUL 31 2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Inputs
error(nargchk(3, 9, nargin));

p = inputParser;

p.addRequired('input_image',@(x)validateattributes(x,{'char'},{'nonempty'},'PandaHeadGenerator','input_image',1));
p.addRequired('input_template',@(x)validateattributes(x,{'char'},{'nonempty'},'PandaHeadGenerator','input_template',2));
p.addRequired('output_meme',@(x)validateattributes(x,{'char'},{'nonempty'},'PandaHeadGenerator','output_meme',3));

defaultmode = 'gray';
p.addParameter('mode',defaultmode,@(x)any(validatestring(x,{'gray','pixelate','b&w'})));

p.addParameter('textrow1',@(x)validateattributes(x,{'char'},{'nonempty'},'PandaHeadGenerator','textrow1',7));
p.addParameter('textrow2',@(x)validateattributes(x,{'char'},{'nonempty'},'PandaHeadGenerator','textrow1',9));

p.parse(input_image,input_template,output_meme,varargin{:});

if exist(p.Results.input_image)==2&exist(p.Results.input_template)==2
    
    [o1,o2,o3]=fileparts(p.Results.output_meme);
    if isempty(o3)==1
        fileoutput=[p.Results.output_meme,'.jpg'];
    elseif strcmp(o3,'jpg')~=1
        fileoutput=[o1,o2,'.jpg'];
    else
        fileoutput=p.Results.output_meme;
    end
    
% load the photo which meme will be generated from into workspace
img =imread(p.Results.input_image);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Low-pass filtering to make photo smooth
% Code modified from http://www.ilovematlab.cn/thread-285080-1-1.html
fR=img(:,:,1);
fG=img(:,:,2);
fB=img(:,:,3);
f=1/9*ones(3);
filtered_fR=imfilter(fR,f);
filtered_fG=imfilter(fG,f);
filtered_fB=imfilter(fB,f);
x_filtered=cat(3,filtered_fR,filtered_fG,filtered_fB);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Keep rotating the photo 90 degree counterclockwise until a face is
% recognized. A simple method to detect photo's orientation.

% creates a detector to detect objects using the Viola-Jones algorithm.
faceDetector = vision.CascadeObjectDetector(); 

roi=[]; % roi=region of interested, here it is facial area.
rnum=0; % indicate how many times the photo has been rotated.
while isempty(roi)==1
    if rnum<=3 % stop after rotated 3 times
        roi = step(faceDetector, x_filtered); % face recognition
        if isempty(roi)==1
            x_filtered=rot90(x_filtered); % if failed, then rotate the photo
            rnum=rnum+1;
        end
    end
end
% The procedure won't proceed if no face has been recognized.

figure;
subplot(2,3,1);
imshow(x_filtered); % show the original photo after orientation detection
title('Original Pic');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If more than one facial recognition result pops up, show them for
% selecting. Choose the accurate and perfect one and input its num.
if size(roi,1)>1
f0=figure;
for i=1:size(roi,1)
    subplot(1,size(roi,1),i);
    imshow(imcrop(x_filtered,roi(i,:)));
    title(['FaceDetection ',num2str(i)]);
end
s=input('Choose face detection, enter its number: ','s');
if isempty(s)
    s=input('Re-enter: ','s');
end
s=str2num(s);close(f0)
else
    s=1;
end

f=imcrop(x_filtered,roi(s,:));
gray=rgb2gray(f);

% l=logical(gray);

subplot(2,3,2);
imshow(f); % show detected face
title('Face Recognition');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate angle of facial symmetry axis

% left eye recognition
leyedetector = vision.CascadeObjectDetector('ClassificationModel','LeftEyeCart','MaxSize',size(gray));
leyebbox=step(leyedetector,f);
if isempty(leyebbox)==0
    f1=figure;
    for i=1:size(leyebbox,1)
        subplot(1,size(leyebbox,1),i);
        imshow(imcrop(f,leyebbox(i,:)));
        title(['LeftEyeDetection ',num2str(i)]);
    end
    l=input('Choose correct left eye detection and enter its number. If no one is correct, enter ''0'': ','s');
    if isempty(l)
        l=input('Re-enter: ','s');
    end
    l=str2num(l);
    if l>0
        close(f1)
    elseif l==0
        close(f1)
        leyedetector = vision.CascadeObjectDetector('ClassificationModel','LeftEye','MaxSize',size(gray));
        leyebbox=step(leyedetector,f);
        f1=figure;
        for i=1:size(leyebbox,1)
           subplot(1,size(leyebbox,1),i);
            imshow(imcrop(f,leyebbox(i,:)));
            title(['LeftEyeDetection ',num2str(i)]);
        end
        l=input('Choose correct left eye detection and enter its number: ','s');
        if isempty(l)
            l=input('Re-enter: ','s');
        end
        l=str2num(l);
        close(f1)
    end
else
    leyedetector = vision.CascadeObjectDetector('ClassificationModel','LeftEye','MaxSize',size(gray));
    leyebbox=step(leyedetector,f);
    f1=figure;
    for i=1:size(leyebbox,1)
       subplot(1,size(leyebbox,1),i);
        imshow(imcrop(f,leyebbox(i,:)));
        title(['LeftEyeDetection ',num2str(i)]);
    end
    l=input('Choose correct left eye detection and enter its number: ','s');
    if isempty(l)
        l=input('Re-enter: ','s');
    end
    l=str2num(l);
    close(f1)
end
leyelocation=[leyebbox(l,1)+round(leyebbox(l,3)/2),leyebbox(l,2)+round(leyebbox(l,4)/2)];

% right eye recognition
reyedetector = vision.CascadeObjectDetector('ClassificationModel','RightEyeCart','MaxSize',size(gray));
reyebbox=step(reyedetector,f);
if isempty(reyebbox)==0
    f2=figure;
    for i=1:size(reyebbox,1)
        subplot(1,size(reyebbox,1),i);
        imshow(imcrop(f,reyebbox(i,:)));
        title(['RightEyeDetection ',num2str(i)]);
    end
    r=input('Choose correct right eye detection and enter its number. If no one is correct, enter ''0'': ','s');
    if isempty(r)
        r=input('Re-enter: ','s');
    end
    r=str2num(r);
    if r>0
        close(f2)
    elseif r==0
        close(f2)
        reyedetector = vision.CascadeObjectDetector('ClassificationModel','RightEye','MaxSize',size(gray));
        reyebbox=step(reyedetector,f);
        f2=figure;
        for i=1:size(reyebbox,1)
           subplot(1,size(reyebbox,1),i);
            imshow(imcrop(f,reyebbox(i,:)));
            title(['RightEyeDetection ',num2str(i)]);
        end
        r=input('Choose correct right eye detection and enter its number: ','s');
        if isempty(r)
            r=input('Re-enter: ','s');
        end
        r=str2num(r);
        close(f2)
    end
else
    reyedetector = vision.CascadeObjectDetector('ClassificationModel','RightEye','MaxSize',size(gray));
    reyebbox=step(reyedetector,f);
    f2=figure;
    for i=1:size(reyebbox,1)
       subplot(1,size(reyebbox,1),i);
        imshow(imcrop(f,reyebbox(i,:)));
        title(['RgihtEyeDetection ',num2str(i)]);
    end
    r=input('Choose correct right eye detection and enter its number: ','s');
    if isempty(r)
        r=input('Re-enter: ','s');
    end
    r=str2num(r);close(f2)
end

reyelocation=[reyebbox(r,1)+round(reyebbox(r,3)/2),reyebbox(r,2)+round(reyebbox(r,4)/2)];

if reyelocation(2)<leyelocation(2)
    angle=atan(-(reyelocation(2)-leyelocation(2))/(reyelocation(1)-leyelocation(1)));
else
    angle=-(atan((reyelocation(2)-leyelocation(2))/(reyelocation(1)-leyelocation(1))));
end
angle=angle*180/pi;

if abs(angle)>10
    disp('Facial symmetry axis is not vertical. The angle is larger than 10 degree.');
    disp('Image are going to be rotated, hence eyes detection will be reconducted');

ff=imrotate(f,-(angle));
ff(ff==0)=255;

subplot(2,3,3);imshow(ff); %show rotated face
title('Face after rotated');

clear gray leyebbox reyebbox
gray=rgb2gray(ff);
logic=zeros(size(gray));

% re-recognition of left eye
leyedetector = vision.CascadeObjectDetector('ClassificationModel','LeftEyeCart','MaxSize',size(gray));
leyebbox=step(leyedetector,ff);
if isempty(leyebbox)==0
    f1=figure;
    for i=1:size(leyebbox,1)
        subplot(1,size(leyebbox,1),i);
        imshow(imcrop(ff,leyebbox(i,:)));
        title(['LeftEyeDetection ',num2str(i)]);
    end
    s=input('Choose correct left eye detection and enter its number. If no one is correct, enter ''0'': ','s');
    if isempty(s)
        s=input('Re-enter: ','s');
    end
    s=str2num(s);
    if s>0
        close(f1)
    elseif s==0
        close(f1)
        leyedetector = vision.CascadeObjectDetector('ClassificationModel','LeftEye','MaxSize',size(gray));
        leyebbox=step(leyedetector,ff);
        f1=figure;
        for i=1:size(leyebbox,1)
           subplot(1,size(leyebbox,1),i);
            imshow(imcrop(ff,leyebbox(i,:)));
            title(['LeftEyeDetection ',num2str(i)]);
        end
        s=input('Choose correct left eye detection and enter its number: ','s');
        if isempty(s)
            s=input('Re-enter: ','s');
        end
        s=str2num(s);
        close(f1)
    end
else
    leyedetector = vision.CascadeObjectDetector('ClassificationModel','LeftEye','MaxSize',size(gray));
    leyebbox=step(leyedetector,ff);
    f1=figure;
    for i=1:size(leyebbox,1)
       subplot(1,size(leyebbox,1),i);
        imshow(imcrop(ff,leyebbox(i,:)));
        title(['LeftEyeDetection ',num2str(i)]);
    end
    s=input('Choose correct left eye detection and enter its number: ','s');
    if isempty(s)
        s=input('Re-enter: ','s');
    end
    s=str2num(s);close(f1)
end
leye=imcrop(gray,leyebbox(s,:));
logic(leyebbox(s,2):leyebbox(s,2)+leyebbox(s,4),leyebbox(s,1):leyebbox(s,1)+leyebbox(s,3))=leye;

% Re-recognition of right eye
reyedetector = vision.CascadeObjectDetector('ClassificationModel','RightEyeCart','MaxSize',size(gray));
reyebbox=step(reyedetector,ff);
if isempty(reyebbox)==0
    f2=figure;
    for i=1:size(reyebbox,1)
        subplot(1,size(reyebbox,1),i);
        imshow(imcrop(ff,reyebbox(i,:)));
        title(['RightEyeDetection ',num2str(i)]);
    end
    s=input('Choose correct right eye detection and enter its number. If no one is correct, enter ''0'': ','s');
    if isempty(s)
        s=input('Re-enter: ','s');
    end
    s=str2num(s);
    if s>0
        close(f2)
    elseif s==0
        close(f2)
        reyedetector = vision.CascadeObjectDetector('ClassificationModel','RightEye','MaxSize',size(gray));
        reyebbox=step(reyedetector,ff);
        f2=figure;
        for i=1:size(reyebbox,1)
           subplot(1,size(reyebbox,1),i);
            imshow(imcrop(ff,reyebbox(i,:)));
            title(['RightEyeDetection ',num2str(i)]);
        end
        s=input('Choose correct right eye detection and enter its number: ','s');
        if isempty(s)
            s=input('Re-enter: ','s');
        end
        s=str2num(s);close(f2)
    end
else
    reyedetector = vision.CascadeObjectDetector('ClassificationModel','RightEye','MaxSize',size(gray));
    reyebbox=step(reyedetector,ff);
    f2=figure;
    for i=1:size(reyebbox,1)
       subplot(1,size(reyebbox,1),i);
        imshow(imcrop(ff,reyebbox(i,:)));
        title(['RgihtEyeDetection ',num2str(i)]);
    end
    s=input('Choose correct right eye detection and enter its number: ','s');
    if isempty(s)
        s=input('Re-enter: ','s');
    end
    s=str2num(s);close(f2);
end
reye=imcrop(gray,reyebbox(s,:));
logic(reyebbox(s,2):reyebbox(s,2)+reyebbox(s,4),reyebbox(s,1):reyebbox(s,1)+reyebbox(s,3))=reye;

% Nose recognition
nosedetector = vision.CascadeObjectDetector('ClassificationModel','Nose','MaxSize',size(gray));
nosebbox=step(nosedetector,ff);
f3=figure;
for i=1:size(nosebbox,1)
    subplot(1,size(nosebbox,1),i);
    imshow(imcrop(ff,nosebbox(i,:)));
    title(['NoseDetection ',num2str(i)]);
end

s=input('Choose correct nose detection, enter its number: ','s');
if isempty(s)
    s=input('Re-enter: ','s');
end
s=str2num(s);
nose=imcrop(gray,nosebbox(s,:));
logic(nosebbox(s,2):nosebbox(s,2)+nosebbox(s,4),nosebbox(s,1):nosebbox(s,1)+nosebbox(s,3))=nose;
close(f3);

% Mouth recognition
mdetector = vision.CascadeObjectDetector('ClassificationModel','Mouth','ScaleFactor',1.5,'MaxSize',size(gray));
mbbox=step(mdetector,ff);
f4=figure;
for i=1:size(mbbox,1)
    subplot(1,size(mbbox,1),i);
    imshow(imcrop(ff,mbbox(i,:)));
    title(['MouthDetection ',num2str(i)]);
end

s=input('Choose correct mouth detection, enter its number: ','s');
if isempty(s)
    s=input('Re-enter: ','s');
end
s=str2num(s);
mouth=imcrop(gray,mbbox(s,:));
logic(mbbox(s,2):mbbox(s,2)+mbbox(s,4),mbbox(s,1):mbbox(s,1)+mbbox(s,3))=mouth;
close(f4)

else
    gray=rgb2gray(f);
    logic=zeros(size(gray));
    leye=imcrop(gray,leyebbox(l,:));
    logic(leyebbox(l,2):leyebbox(l,2)+leyebbox(l,4),leyebbox(l,1):leyebbox(l,1)+leyebbox(l,3))=leye;
    reye=imcrop(gray,reyebbox(r,:));
    logic(reyebbox(r,2):reyebbox(r,2)+reyebbox(r,4),reyebbox(r,1):reyebbox(r,1)+reyebbox(r,3))=reye;

% nose recognition
nosedetector = vision.CascadeObjectDetector('ClassificationModel','Nose','MaxSize',size(gray));
nosebbox=step(nosedetector,f);
f3=figure;
for i=1:size(nosebbox,1)
    subplot(1,size(nosebbox,1),i);
    imshow(imcrop(f,nosebbox(i,:)));
    title(['NoseDetection ',num2str(i)]);
end

s=input('Choose correct nose detection, enter its number: ','s');
if isempty(s)
    s=input('Re-enter: ','s');
end
s=str2num(s);
nose=imcrop(gray,nosebbox(s,:));
logic(nosebbox(s,2):nosebbox(s,2)+nosebbox(s,4),nosebbox(s,1):nosebbox(s,1)+nosebbox(s,3))=nose;
close(f3);

% mouth recognition
mdetector = vision.CascadeObjectDetector('ClassificationModel','Mouth','ScaleFactor',1.5,'MaxSize',size(gray));
mbbox=step(mdetector,f);
f4=figure;
for i=1:size(mbbox,1)
    subplot(1,size(mbbox,1),i);
    imshow(imcrop(f,mbbox(i,:)));
    title(['MouthDetection ',num2str(i)]);
end

s=input('Choose correct mouth detection, enter its number: ','s');
if isempty(s)
    s=input('Re-enter: ','s');
end
s=str2num(s);
mouth=imcrop(gray,mbbox(s,:));
logic(mbbox(s,2):mbbox(s,2)+mbbox(s,4),mbbox(s,1):mbbox(s,1)+mbbox(s,3))=mouth;
close(f4)

end

% remove the area where its value is zero
for i=1:size(logic,1);temp=find(logic(i,:)>0);if isempty(temp)==0;xmin(i)=min(temp);xmax(i)=max(temp);else xmin(i)=nan;xmax(i)=nan;end;end
for i=1:size(logic,2);temp=find(logic(:,i)>0);if isempty(temp)==0;ymin(i)=min(temp);ymax(i)=max(temp);else ymin(i)=nan;ymax(i)=nan;end;end
cropf=imcrop(logic,[min(xmin) min(ymin) max(xmax)-min(xmin)+1 max(ymax)-min(ymin)+1]);

% Change black background into white
d=cropf;
d(d==0)=max(d(:));
d=d/max(d(:));

subplot(2,3,4);
imshow(d,[])
title('Eyes, Nose, Mouth Detection');
% show detected eyes, nose and mouth

% Increase brightness
dd=d+0.3;
dd(dd>1)=1;

f5=figure;
imshow(dd);
s=0; % parameter for brightness adjustment
while s~=2
    s=input('If not satisfied, enter a number within [0 1], otherwise enter ''2'': ','s');
    if isempty(s)
        s=input('Re-enter: ','s');
    end
    s=str2num(s);
    if s~=2
        dd=d+s;
        dd(dd>1)=1;
        imshow(dd,[]);
    end
end
close(f5)

switch p.Results.mode
    case 'gray'
        fff=dd;
        subplot(2,3,5);
        imshow(fff,[]);
        title('Gray Style');
    case 'pixelate'
        % 4-level gray
        ddd=mat2gray(dd);
        fff=ones(size(dd));
        fff(ddd<0.25)=0;fff(ddd>=0.25&ddd<0.5)=0.25;fff(ddd>=0.5&ddd<0.75)=0.5;fff(ddd>=0.75)=0.75;

        % 8-level gray
        % fff(ddd<0.125)=0;fff(ddd>=0.125&ddd<0.25)=0.125;fff(ddd>=0.25&ddd<0.375)=0.25;fff(ddd>=0.375&ddd<0.5)=0.375;
        % fff(ddd>=0.5&ddd<0.625)=0.5;fff(ddd>=0.625&ddd<0.75)=0.625;fff(ddd>=0.75&ddd<0.875)=0.75;fff(ddd>=0.875)=0.875;
        subplot(2,3,5);
        imshow(fff,[]);
        title([{'Pixelate'},{'4-level Gray'}]);
        % pixelate obtained
    case 'b&w'
        % Binarization: only black and white
        fff=im2bw(dd,graythresh(dd));
        f6=figure;
        imshow(fff);
        s=0; % parameter for effect of binarization
        while s~=2
            s=input('If not satisfied, enter a number within [0 1], otherwise enter ''2'': ','s');
            if isempty(s)
                s=input('Re-enter: ','s');
            end
            s=str2num(s);
            if s~=2
                fff=im2bw(dd,s);
                imshow(fff,[]);
            end
        end
        close(f6) 
        subplot(2,3,5);imshow(fff,[]);
        title('Binarization');
end

if abs(angle>10)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rotate it back !
% Code modified from https://stackoverflow.com/a/26974830
[rowsi,colsi,z]= size(fff); 
rads=2*pi*angle/360;  
%calculating array dimesions such that  rotated image gets fit in it exactly.
% we are using absolute so that we get  positve value in any case ie.,any quadrant.

rowsf=ceil(rowsi*abs(cos(rads))+colsi*abs(sin(rads)));                      
colsf=ceil(rowsi*abs(sin(rads))+colsi*abs(cos(rads)));                     

% define an array withcalculated dimensionsand fill the array  with zeros ie.,black  
C=ones([rowsf colsf]);

%calculating center of original and final image
xo=ceil(rowsi/2);                                                            
yo=ceil(colsi/2);

midx=ceil((size(C,1))/2);
midy=ceil((size(C,2))/2);

% in this loop we calculate corresponding coordinates of pixel of A 
% for each pixel of C, and its intensity will be  assigned after checking
% weather it lie in the bound of A (original image)
for i=1:size(C,1)
    for j=1:size(C,2)                                                       

         x= (i-midx)*cos(rads)+(j-midy)*sin(rads);                                       
         y= -(i-midx)*sin(rads)+(j-midy)*cos(rads);                             
         x=round(x)+xo;
         y=round(y)+yo;

         if (x>=1 && y>=1 && x<=size(fff,1) &&  y<=size(fff,2) ) 
              C(i,j,:)=fff(x,y,:);  
         end

    end
end

% clear xmin xmax ymin ymax
% for i=1:size(C,1);temp=find(C(i,:)==0);if isempty(temp)==0;xmin(i)=min(temp);xmax(i)=max(temp);else xmin(i)=nan;xmax(i)=nan;end;end
% for i=1:size(C,2);temp=find(C(:,i)==0);if isempty(temp)==0;ymin(i)=min(temp);ymax(i)=max(temp);else ymin(i)=nan;ymax(i)=nan;end;end
% 
% clear cropf
% cropf=imcrop(C,[min(xmin) min(ymin) max(xmax)-min(xmin)+1 max(ymax)-min(ymin)+1]);

%figure;imshow(cropf);
else
    C=fff;
end

%load the Panda Head Template
xm=imread(p.Results.input_template);
newxm=imresize(xm,1.75*size(C,1)/size(xm,1)); %modify the size of template according to recognized facial area
newxm=rgb2gray(newxm);
nnewxm=newxm(4:end-3,4:end-3);
nnewxm=double(nnewxm)./255;

% put the facial area in the center of template
nnewxm(round(size(nnewxm,1)/2)-floor(size(C,1)/2):round(size(nnewxm,1)/2)-floor(size(C,1)/2)+size(C,1)-1,round(size(nnewxm,2)/2)-floor(size(C,2)/2):round(size(nnewxm,2)/2)-floor(size(C,2)/2)+size(C,2)-1)=mat2gray(C);

f7=figure;
imshow(nnewxm);
s=0; % this parameter determine the size of facial area
while s~=4
     s=input('If not satisfied, enter a number within (0 3], otherwise enter ''4'': ','s');
     if isempty(s)
         s=input('Re-enter: ','s');
     end
     s=str2num(s);
     if s~=4
          newxm=imresize(xm,s*size(C,1)/size(xm,1));
          newxm=rgb2gray(newxm);
          nnewxm=newxm(4:end-3,4:end-3);
          nnewxm=double(nnewxm)./255;
       
          nnewxm(round(size(nnewxm,1)/2)-floor(size(C,1)/2):round(size(nnewxm,1)/2)-floor(size(C,1)/2)+size(C,1)-1,round(size(nnewxm,2)/2)-floor(size(C,2)/2):round(size(nnewxm,2)/2)-floor(size(C,2)/2)+size(C,2)-1)=mat2gray(C);
          imshow(nnewxm);
     end
end
close(f7) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If there is meme text input, it will be added.
if nargin<=5 % no text input
    subplot(2,3,6);imshow(nnewxm);
    title('Meme Generated!')

    imwrite(nnewxm,fileoutput,'JPEG');
elseif nargin==7 % one row of text
    textarea=ones(round(size(nnewxm,1)/7),size(nnewxm,2));
    newmeme=[nnewxm;textarea];
    f8=figure('visible','off');
    imshow(newmeme);hold on
    text(size(textarea,2)/2,size(nnewxm,1)+size(textarea,1)/2,p.Results.textrow1,'fontsize',28/1560*size(newmeme,2),'fontname','Microsoft Yahei','fontweight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
    export_fig(f8,'-r300','-jpg',fileoutput);
    close(f8);
    subplot(2,3,6);
    final=imread(fileoutput);
    imshow(final,'border','tight');
    title('Meme Generated!')
elseif nargin==9 % two rows of text
    textarea=ones(round(size(nnewxm,1)/7*2),size(nnewxm,2));
    newmeme=[nnewxm;textarea];
    f8=figure('visible','off');
    imshow(newmeme);hold on
    text(size(textarea,2)/2,size(nnewxm,1)+size(textarea,1)/4,p.Results.textrow1,'fontsize',28/1560*size(newmeme,2),'fontname','Microsoft Yahei','fontweight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
    text(size(textarea,2)/2,size(nnewxm,1)+size(textarea,1)/4*2.7,p.Results.textrow2,'fontsize',28/1560*size(newmeme,2),'fontname','Microsoft Yahei','fontweight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
    export_fig(f8,'-r300','-jpg',fileoutput);
    close(f8);
    subplot(2,3,6);
    final=imread(fileoutput);
    imshow(final,'border','tight');
    title('Meme Generated!')
end

end
end
