# Redirect important paths to D drive to save C drive space
$env:PUB_CACHE = "D:\.pub-cache"
$env:GRADLE_USER_HOME = "D:\.gradle"

# Create directories if they don't exist
if (!(Test-Path $env:PUB_CACHE)) { New-Item -ItemType Directory -Path $env:PUB_CACHE -Force }
if (!(Test-Path $env:GRADLE_USER_HOME)) { New-Item -ItemType Directory -Path $env:GRADLE_USER_HOME -Force }

# Configure PATH with preference for D drive tools
$env:Path = "D:\Program Files\flutter\bin;D:\Program Files\Git\cmd;D:\Program Files\Android\Android Studio\jbr\bin;D:\Users\001\AppData\Local\Android\Sdk\platform-tools;" + $env:Path

# Set SDK Homes
$env:JAVA_HOME = "D:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_HOME = "D:\Users\001\AppData\Local\Android\Sdk"

# Flutter Mirrors for faster access in China
$env:PUB_HOSTED_URL = "https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL = "https://mirrors.tuna.tsinghua.edu.cn/flutter"
