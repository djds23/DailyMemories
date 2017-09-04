# DailyMemories

By building this sample app, we will go through 3 ways of adding machine learning to your apps:

1. [*master*] **Core ML**  to classify scene detection from an image
2. [*add-face-detection*] **Vision**  to perform face detection in an image
3. [*add-facial-expression-classification*] **coremltools** + **Core ML** to use a custom machine learning model for facial expression recognition from an image

Each of these parts of the sample app correspond to a branch in this repository

🚨 If you are debugging in the simulator instead of on an iOS11 device:

in the `takePhoto` function, change the `imagePickerController`'s `sourceType` to `.photoLibrary` 🚨

## Part 1 - Using Core ML to classify scene from image

1. Make sure you're on the `master` branch. If not,

    `git checkout master`

2. Download `GoogLeNetPlaces.mlmodel`: a machine learning model that can be used to detect the scene of an image from 205 categories

    https://developer.apple.com/machine-learning/

    Scroll down to **Places205-GoogleNet** section

    Click **Download Core ML File**

3. Import `GoogLeNetPlaces.mlmodel`

    Drag `GoogLeNetPlaces.mlmodel` from Downloads folder into the `DailyMemories` Xcode project

4. Ensure `GoogLeNetPlaces.mlmodel`'s Target Membership is **DailyMemories**

    In Xcode, select `GoogLeNetPlaces.mlmodel`

    In the `Utilities` `FileInspector` on the right panel, make sure **DailyMemories** is selected 

5. In `ViewController.swift`, starting in `classifyScene` method, fill in 1-5 where 
`// YOUR CODE GOES HERE` appears 

## Part 2 - Using Vision to perform face detection in an image

1. `git checkout add-face-detection`

2. In `ViewController.swift`, starting in `classifySceneAndDetectFace` method, fill in 1-3 where 
`// YOUR CODE GOES HERE` appears 

## Part 3 - Using a custom machine learning model for facial expression recognition from an image

Building off of the face detection, we are going to try to classify the facial expression of the face that was detected.

Facial expression classification uses a machine learning model where:

*input* = cropped image of face

*output* = facial expression (e.g. “Angry”, “Happy”, etc)

*Where do we get a Facial Expression Classification model?*

- Not included in Apple’s  .mlmodel offerings

- Need to use custom model and convert it to .mlmodel

  *Follow README in https://github.com/meghaphone/emotion-recognition-mlmodel*
  
  *At the end, you should have a `EmotiClassifier.mlmodel` locally (in your workspace's **emotion-recognition-mlmodel** folder*

1. `git checkout add-facial-expression-classification` 
2. Drag `EmotiClassifier.mlmodel` into Xcode project
3. Open `EmotiClassifier.mlmodel` and check `DailyMemories` to be included in Target Membership
4. In `ViewController.swift`, starting in `classifyFacialExpressionmethod`, fill in 1-5 where 
`// YOUR CODE GOES HERE` appears 
