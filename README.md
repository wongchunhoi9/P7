# P7
========================
### Left Screen 
Loop (1 hour)fill up the screen (512px white) in one hours 
### Right Screen:  
Loop (10mins)
turn on one pixel per second, 300pixel to turn on in 5 mins ,  5 RED : 0 White to 2 Red :3 White
turn on one pixel per second, 300 pixel to turn on in 6th-10th min, Black background,  random red & white pixel turn on for 300 times
### Middle screen 
loop (45mins)
mode 1: Webcam image
mode 2: Webcam Image (threshold)
mode 3: draw lines per 3 seconds, one minute reset


=========================

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
