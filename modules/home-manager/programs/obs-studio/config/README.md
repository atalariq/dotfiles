# Recording templates

Import a directory under `profiles/` through **Profile > Import**, then select
it. Import `scenes.json` through **Scene Collection > Import**. OBS writes its
own copies; these templates never replace existing profiles or scene collections.

Both profiles record H.264 in MKV at 1920×1080, 30 fps and 48 kHz stereo.
Select the output directory in Settings before recording. Try VAAPI first on
AMD hardware; choose the render device in Settings > Output and check that H.264
encoding works. Use the x264 profile if the hardware encoder is unavailable.
The templates contain no device paths, portal restore tokens or stream keys.

Select a monitor in the portal for **Screen** and a window for **Code**. Each
source fits inside the 16:9 canvas without stretching a 16:10 display. Add a
camera yourself to the optional **Camera** scene, then resize it with Fit to
Screen or a smaller overlay. No camera is opened by the template.

Add desktop output and microphone sources using the devices you want to record.
In Advanced Audio Properties, enable tracks **1+2** for desktop and **1+3** for
microphone. Disable their other tracks. Track 1 is a convenient mixed preview;
tracks 2 and 3 remain separate for editing. Verify meters before recording and
headphone monitoring to avoid feedback. Device and mixer setup is intentionally
manual rather than assuming host-specific audio names.

Record five minutes, check sync, inspect all three tracks and import the MKV
into your editor. Use **File > Remux Recordings** when a consumer requires MP4.
Move Transition is installed but not forced onto scene changes. GPU Screen
Recorder remains available for quick capture; OBS is for composed recordings.
