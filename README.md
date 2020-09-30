# P7

## Adjust the Webcam Setting using FFmpeg

### Open Terminal
cd Desktop/ffmpeg-4.3.1-2020-09-21-full_build/bin

### to list the video device:
ffmpeg -list_devices true -f dshow -i dummy -hide_banner

### to change the camera setting
ffmpeg -f dshow -show_video_device_dialog true -i video="Device name"

in our case, "Device name" supposed to be "HD USB Camera"

so 
ffmpeg -f dshow -show_video_device_dialog true -i video="HD USB Camera"
and then press enter

https://www.addictivetips.com/windows-tips/access-advanced-settings-for-the-integrated-webcam-on-windows-10/
