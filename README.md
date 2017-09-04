# DailyMemories

By building this sample app, we will go through 3 ways of adding machine learning to your apps:

1. [*master*] **Core ML**  to classify scene detection from an image
2. [*add-face-detection*] **Vision**  to perform face detection in an image
3. [*add-facial-expression-classification*] **coremltools** + **Core ML** to use a custom machine learning model for facial expression recognition from an image

Each of these parts of the sample app correspond to a branch in this repository

# Part 1 - Using Core ML to classify scene from image

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
