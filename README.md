![Title Image](https://github.com/chouj/PandaHeadMemeGenerator/blob/master/GeshenMemeTitleImage.jpg?raw=true)

# PandaHeadMemeGenerator

## Description

Use MATLAB to achieve panda head meme auto-generation from your own facial photo.

## Features

 - Rotate the photo until a face can be recognized.
 - Eyes, nose and mouth are recognized separately after facial recognition
 - Show all the results of recognition at each step to let you choose the right one.
 - If facial symmetry axis is not vertical, calculate its angle and rotate the photo a little bit to enhance the accuracy of facial  recognition.
 - In order to obtain the best binarization of facial expression, a parameter can be adjusted mannually.

## Usage

### Function PandaHead
 - input_image: the file name and its associated path of facial photo from which the meme will be generated. It will be loaded by "imread", thus common pic formats are supported. For exmaple, 'E:\folder_one\kid.jpg'.
 - output_image: the filename for generated PandaHead meme. Its filename extension ".jpg" is required. For exmaple, 'E:\folder_one\kidmeme.jpg'. You can modified the last row of codes below to write it into other formats.
 - The title image in Github page can be produced by running PandaHeadMemeGeneratorDemo.m.

## Author 
https://github.com/chouj

