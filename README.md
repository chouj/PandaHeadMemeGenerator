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

## Usage

### Function PandaHeadGenerator.m

 - input_image: the file name and its associated path of facial photo from which the meme will be generated. It will be loaded by "```imread```", thus common pic formats are supported. For exmaple, '```E:\folder_one\kid.jpg```'. In addition, high-resolution picture is preferred.
 - input_template: the file name and its associated path of template of Panda Head. It can be downloaded here: https://github.com/chouj/PandaHeadMemeGenerator/blob/master/xm.png
 - output_image: the filename for generated PandaHead meme. Its filename extension "```.jpg```" is required. For exmaple, '```E:\folder_one\kidmeme.jpg```'. You can modified associated codes to write it into other formats.
 - optional parameter/value pairs: ```'mode', 'gray'```. Default output mode is gray style. 
 - ```'mode', 'pixelate'```: pixelate style (4-level gray).
 - ```'mode', 'b&w'``` only black and white (binarizatoin). 
 - optional parameter/value pairs: ```'textrow1', string```. Add first phrase below panda head.
 - ```'textrow1',string``` : Add another sentence.
 
### Example
```
     PandaHeadGenerator(...
        'c:\o3.jpg',...
        'c:\users\lenovo\downloads\xm.png',...
        '.\me',...
        'mode','gray',...
        'textrow1','搬砖工人的',...
        'textrow2','谜之微笑');
 ```
 
 ###### The title image in Github page can be produced by running ```PandaHeadMemeGeneratorDemo.m```.

## Author 
https://github.com/chouj

