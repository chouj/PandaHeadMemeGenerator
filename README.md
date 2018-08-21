![Title Image](https://github.com/chouj/PandaHeadMemeGenerator/blob/master/GeshenMemeTitleImage.jpg?raw=true)

# PandaHeadMemeGenerator

## Description

Use MATLAB to achieve panda head meme auto-generation from your own facial photo.

## Features

 - Rotate the photo until a face can be recognized.
 - Eyes, nose and mouth are recognized separately after facial recognition.
 - Show all the results of recognition at each step to let you choose the right one.
 - If facial symmetry axis is not vertical, calculate its angle and rotate the photo a little bit to enhance the accuracy of facial  recognition.
 - In order to obtain the best binarization of facial expression, a parameter can be adjusted mannually.
 - Gray style, 4-level gray (pixelate style) or binarization style (black and white) can be choosen by using optional parameter "mode" (See Usage).
 - At most two rows of text can be added below PandaHead to make it a final meme.

## Requirements

#### [Computer Vision System Toolbox](https://www.mathworks.com/products/computer-vision.html)

#### [export_fig](https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig)

## Usage

### Function PandaHeadGenerator.m

 - input_image: the file name and its associated path of facial photo from which the meme will be generated. It will be loaded by "```imread```", thus common pic formats are supported. For exmaple, '```E:\folder_one\kid.jpg```'. In addition, high-resolution picture is preferred.
 - input_template: the file name and its associated path of template of Panda Head. It can be downloaded here: https://github.com/chouj/PandaHeadMemeGenerator/blob/master/xm.png
 - output_image: the filename for generated PandaHead meme. Its filename extension "```.jpg```" is required. For exmaple, '```E:\folder_one\kidmeme.jpg```'. You can modified associated codes to write it into other formats.
 - optional parameter/value pairs: ```'mode', 'gray'```. Default output mode is gray style. 
 - ```'mode', 'pixelate'```: pixelate style (4-level gray).
 - ```'mode', 'b&w'``` only black and white (binarizatoin). 
 - optional parameter/value pairs: ```'textrow1', string```. Add first phrase below panda head.
 - ```'textrow2',string``` : Add another sentence.
 
### Example
```matlab
     PandaHeadGenerator(...
        'c:\o3.jpg',...
        'c:\users\lenovo\downloads\xm.png',...
        '.\me',...
        'mode','gray',...
        'textrow1','搬砖工人的',...
        'textrow2','谜之微笑');
 ```

## Acknowledgement

[Image rotation by Matlab without using imrotate](https://stackoverflow.com/a/26974830)

[图像处理中的matlab使用](https://whuhan2013.github.io/blog/2016/12/19/gray-change-space/)

[对函数的输入进行检查和解析](https://zhuanlan.zhihu.com/p/25154612)

[Matlab图像处理-灰度变换](https://linxid.github.io/2018/04/21/Matlab%E5%9B%BE%E5%83%8F%E5%A4%84%E7%90%86-%E7%81%B0%E5%BA%A6%E5%8F%98%E6%8D%A2/)

[人脸检测与分割](http://www.ilovematlab.cn/thread-285080-1-1.html)

## Templates

[如何用PhotoShop制作真人头像表情包](https://blog.csdn.net/CHIMO_HS/article/details/78090622)

[如何用ps将朋友的照片制作成熊猫人表情包？](https://www.zhihu.com/question/58800555)

## Author 
https://github.com/chouj

###### The title image in Github page can be produced by running ```PandaHeadMemeGeneratorDemo.m```.

## Support Me

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/Mesoscale)
[![Donate](https://img.shields.io/badge/Donate-WeChat-brightgreen.svg)](https://github.com/chouj/donate-page/blob/master/simple/images/WeChatQR.jpg?raw=true)
[![Donate](https://img.shields.io/badge/Donate-AliPay-blue.svg)](https://github.com/chouj/donate-page/blob/master/simple/images/AlipayQR.jpg?raw=true)
