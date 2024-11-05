# Silicon-Based Digital Human SDK [[中文]](./README.md)

## I. Product Introduction

2D digital human virtual human SDK that can be driven in real-time through voice.

### 1. Suitable Scenarios

Low deployment cost: No need for customers to provide technical teams for cooperation, supports low-cost and rapid deployment on various terminals and large screens; Small network dependency: Can be implemented in various scenarios such as subway, bank, and government virtual assistant self-service; Diverse functions: Can meet the diverse needs of video, media, customer service, finance, radio and television and other industries according to customer needs.

### 2. Core Functions

Provide customized AI anchors, smart customer service and other multi-scene image rentals, support customers to deploy quickly and operate at low cost; Exclusive image customization: Support custom exclusive virtual assistant images, optional low-cost or deep image generation; Broadcast content customization: Support custom exclusive broadcast content, used in training, broadcasting and other scenarios; Real-time interactive Q&A: Support real-time dialogue, can also customize exclusive Q&A database, can meet consulting inquiries, voice chat, virtual companions, vertical scene customer service questions and other needs.<br><br>

## II. SDK Integration

### 1. Supported Systems and Hardware Versions

| Item                  | Description                                                  |
| :-------------------- | :----------------------------------------------------------- |
| System                | Supports Android 7.0+ (API Level 24) to Android 13 (API Level 33) system. |
| CPU Architecture      | armeabi-v7a, arm64-v8a                                       |
| Hardware Requirements | Requires devices with 4-core CPU or higher, 4GB memory or higher, and available storage space of 500MB or higher. |
| Network               | Supports WIFI and mobile networks. If using cloud-based Q&A database, the device bandwidth (for the actual bandwidth of digital humans) is expected to be 10mbps or higher. |
| Development IDE       | Android Studio Giraffe 2022.3.1 Patch 2                      |
| Memory Requirements   | Memory available for digital humans >= 400MB                 |

### 2. SDK Integration

add the following configuration in build.gradle:

```gradle
dependencies {
    // reference SDK project
    implementation project(":duix-sdk")
    // The SDK uses exoplayer to handle audio (required)
    implementation 'com.google.android.exoplayer:exoplayer:2.14.2'

    // Cloud Q&A interface uses SSE component (optional)
    implementation 'com.squareup.okhttp3:okhttp-sse:4.10.0'

    ...
}
```

Permission requirements, add the following configuration in AndroidManifest.xml:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

</manifest>
```

<br>

## III. SDK Invocation and API Description

### 1. Initialize SDK

Build the DUIX object and add callback events in the render page onCreate() stage:

```kotlin
duix = DUIX(mContext, baseDir, modelDir, mDUIXRender) { event, msg, info ->
    when (event) {
        ai.guiji.duix.sdk.client.Constant.CALLBACK_EVENT_INIT_READY -> {
            initOK()
        }

        ai.guiji.duix.sdk.client.Constant.CALLBACK_EVENT_INIT_ERROR -> {

        }
        // ...

    }
}
// Asynchronous callback result
duix?.init()
```

DUIX object construction instructions:

| Parameter | Type       | Description                                                  |
| :-------- | :--------- | :----------------------------------------------------------- |
| context   | Context    | System context                                               |
| baseDir   | String     | Stores configuration files for model driving, need to manage it yourself. You can unzip the compressed file to external storage and provide the folder path |
| modelDir  | String     | Stores model files Folder, need to manage it yourself. You can unzip the compressed file to external storage and provide the folder path |
| render    | RenderSink | Rendering data interface, the SDK provides a default rendering component that inherits from this interface, or you can implement it yourself |
| callback  | Callback   | Various callback events handled by the SDK                   |

Refer to the LiveActivity demo example

### 2. Get SDK model initialization status

```kotlin
object : Callback {
        fun onEvent(event: String, msg: String, info: Object) {
        when (event) {
            "init.ready" -> {
                // SDK model initialization successful
            }

            "init.error" -> {
                // Initialization failed
                Log.e(TAG, "init error: $msg")
            }
            // ...

        }
    }
}
```

### 3. Digital Human Avatar Display

Use the RenderSink interface to accept rendering frame data; the SDK provides an implementation of this interface, DUIXRenderer.java. You can also implement the interface yourself to customize rendering. The definition of RenderSink is as follows:

```java
/**
 * Rendering pipeline, returns rendering data through this interface
 */
public interface RenderSink {

    // The buffer data in frame is arranged in bgr order
    void onVideoFrame(ImageFrame imageFrame);

}
```

Use DUIXRenderer and DUIXTextureView control to simply implement rendering display; this control supports transparency and can be freely set background and foreground:

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // ...
    mDUIXRender =
        DUIXRenderer(
            mContext,
            binding.glTextureView
        )

    binding.glTextureView.setEGLContextClientVersion(GL_CONTEXT_VERSION)
    binding.glTextureView.setEGLConfigChooser(8, 8, 8, 8, 16, 0) // Transparency
    binding.glTextureView.isOpaque = false           // Transparency
    binding.glTextureView.setRenderer(mDUIXRender)
    binding.glTextureView.renderMode =
        GLSurfaceView.RENDERMODE_WHEN_DIRTY      // Must be called after setting Render

    duix = DUIX(mContext, baseDir, modelDir, mDUIXRender) { event, msg, _ ->
    }
    // ...
}
```

### 4. Start Digital Human Broadcast

After initialization is successful, you can play audio to drive the image:

```kotlin
duix?.playAudio(wavPath)
```

Parameter description:

| Parameter | Type   | Description                                                  |
| :-------- | :----- | :----------------------------------------------------------- |
| wavPath   | String | Address or https network address of a 16k sample rate mono channel wav file |

Audio playback status and progress callback:

```kotlin
object : Callback {
    fun onEvent(event: String, msg: String, info: Object) {
        when (event) {
            // ...

            "play.start" -> {
                // Start playing audio
            }

            "play.end" -> {
                // Complete playing audio
            }
            "play.error" -> {
                // Audio playback exception
            }
            "play.progress" -> {
                // Audio playback progress
            }

        }
    }
}

```

### 5. Terminate Current Broadcast

Call this interface to terminate the broadcast when the digital human is broadcasting.

Function definition:

```
boolean stopAudio();
```

Example call:

```kotlin
duix?.stopAudio()
```

### 6. Play Action Interval

When the model supports playing action intervals, you can use this function to play multiple intervals; when there are multiple, it plays randomly.

Function definition:

```kotlin
void motion();
```

Example call:

```kotlin
duix?.motion()
```

### 7. Proguard Configuration

If the code uses obfuscation, please configure in proguard-rules.pro:

```pro
-keep class com.btows.ncnntest.** {*; }
-dontwarn com.squareup.okhttp3.**
-keep class com.squareup.okhttp3.** { *;}
```

<br>

## IV. Precautions

1. The basic configuration folder and the corresponding model folder storage path must be correctly configured to drive rendering.
2. The audio file to be played should not be too large; a large audio file import will consume a lot of CPU, causing drawing stuck.<br><br>

## V. Version Record

**3.0.4**

```text
1. Fixed the issue that the default low-precision float of gl on some devices caused the image to not be displayed properly.
```

**3.0.3**

```text
1. Optimized local rendering.
```

<br>

## VI. Other Related Third-Party Open Source Projects

| Module                                           | Description                                         |
| :----------------------------------------------- | :-------------------------------------------------- |
| [ExoPlayer](https://github.com/google/ExoPlayer) | Media player                                        |
| [okhttp](https://github.com/square/okhttp)       | Networking framework                                |
| [onnx](https://github.com/onnx/onnx)             | Artificial intelligence framework                   |
| [ncnn](https://github.com/Tencent/ncnn)          | High-performance neural network computing framework |