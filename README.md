# FaceUnity Beauty Extension Get Started

> How to Quickly Set Up FaceUnity Beauty Extension Android Sample Project
>
> Other Language: [**简体中文**](README.zh.md)

---

## 1. Environment Preparation

- Minimum compatibility with Android 5.0 (SDK API Level 21).
- Flutter SDK 2.10 or higher.
- Real devices running Android 5.0 or higher.

---

## 2. Running Examples

##### 2.1 Obtain Agora App ID -------- [Obtain Agora App ID](https://docs.agora.io/en/video-calling/reference/manage-agora-account?platform=ios#get-the-app-id)

> - Obtain App ID and App certificate
>
>   ![xxx](https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/github_readme/market-place/Market-Place-1.png)

##### 2.2 Enter [FaceUnity Beauty](https://console.agora.io/marketplace/extension/introduce?serviceName=faceunity-ar-en) and click "Contact Us" to obtain an exclusive certificate file

![xxx](https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/github_readme/market-place/FaceUnity/FaceUnity-EN-1.png)

- Provide the package name bound to the license during the application and change "applicationId" in the [**android/app/build.gradle**](android/app/build.gradle) file of the project to your own bound package name.

![xxx](https://web-cdn.agora.io/docs-files/1679457359046)

##### 2.3 Fill in the required Agora App ID, token, and FaceUnity certificate file name in [**lib/main.dart**](lib/main.dart) of the project.

![xxx](https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/github_readme/market-place/FaceUnity/FaceUnity_flutter_3.png)


##### 2.4 Copy the necessary resource files to the [**Resource/**](Resource/) directory of the project.

* [Click here to download the resource file package required for the demo-v8.11.1](https://download.agora.io/marketplace/release/Agora_Marketplace_FaceUnity_v8.11.1_Extension_for_Resource.tar.gz)

![xxx](https://web-cdn.agora.io/docs-files/1673335775613)

##### 2.5 Copy the iOS FaceUnity Beauty License `authpack.h` file content to the project's [lib/authpack.dart](lib/authpack.dart) `gAuthPackage`.

![xxx](https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/github_readme/market-place/FaceUnity/FaceUnity_flutter_2.png)

##### 2.6 Download the **android-release.aar** file of the extension and copy it to the [**android/libs/**](android/libs/)directory of the project.

* [Click here to download the extension aar required for Android demo-v8.11.1](https://download.agora.io/marketplace/release/Agora_Marketplace_FaceUnity_v8.11.1_Extension_for_Android_v4.3.2-1.tar.gz)
* [Click here to download the extension framework required for IOS demo-v8.11.1](https://download.agora.io/marketplace/release/Agora_Marketplace_FaceUnity_v8.11.1_Extension_for_iOS_v4.3.2-1.tar.gz)

<img src="https://web-cdn.agora.io/docs-files/1673335651833" alt="xxx" style="zoom:50%;" />

##### 2.7 Open the project with your favor IDE(Android Studio or VS Code), connect to an Android device (not emulator), and run the project.

---

## 3. Project Introduction

### 3.1 Overview

> This project shows how to quickly integrate Agora Marketplace FaceUnity beauty extension through simple API calls.

### 3.2 Project File Structure

```
├── android
│   |
│   └── libs // The FaceUnity plugin's aar
│   └── build.gradle //Gradle file
├── .gitignore
├── ios
|__ Resource // The beauty resources files
```
---
### 3.3 Demo Effect

> <img src="https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/github_readme/market-place/FaceUnity/FaceUnity-effect-3.jpg.jpg" width="300" height="640">
> <img src="https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/github_readme/market-place/FaceUnity/FaceUnity-effect-4.jpg.jpg" width="300" height="640">
>
> ---
>
> * enableExtension: Enable/Disable Extension
> * enableAITracking: Enable Face Detection Display Results
> * setComposer: Set Beauty Effect
> * setSticker: Set Sticker Effect
> * ENABLELIGHTMAKEUP: Enable/Disable Lightmakeup Effect


---

## 4. FAQ

### How to Obtain Agora App ID?

> Obtain Agora App ID at：[Obtain Agora App ID](https://docs.agora.io/en/video-calling/reference/manage-agora-account?platform=ios#get-the-app-id)

### No Beauty Effect Appeared After Program Running?

> 1、The extension dynamic library is not saved in the correct location or not imported.
> 2、The files in the Xiangxin resource package are not saved in the correct location or some files are missing.
> 3、The certificate file is inconsistent with the app package name, resulting in authentication failure.

### Want to Learn about Other Agora Marketplace Extensions?

> Agora Marketplace Homepage: https://www.agora.io/en/agora-extensions-marketplace/

### Encounter Problems During Integration, How to Contact Agora for Assistance?

> Solution 1: If you are already using Agora service or in contact with Agora sales or service, you can contact them directly.
>
> Solution 2: Email [support@agora.io](mailto:support@agora.io) for consultation.

---
