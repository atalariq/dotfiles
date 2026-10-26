{
  animation_curve_close = "0.08,0.92,0,1";
  animation_curve_focus = "0.46,1.0,0.29,1";
  animation_curve_move = "0.46,1.0,0.29,1";
  animation_curve_opacity_fade_in = "0.46,1.0,0.29,1";
  animation_curve_opacity_fade_out = "0.5,0.5,0.5,0.5";
  animation_curve_open = "0.46,1.0,0.29,1";
  animation_curve_tag = "0.46,1.0,0.29,1";
  animation_duration_close = 250;
  animation_duration_focus = 250;
  animation_duration_move = 250;
  animation_duration_open = 250;
  animation_duration_tag = 250;
  animation_fade_in = 1;
  animation_fade_out = 1;
  animation_type_close = "slide";
  animation_type_open = "zoom";
  animations = 1;
  axis_bind_apply_timeout = 200;
  axis_scroll_factor = 1.0;
  blur = 0;
  blur_layer = 0;
  blur_optimized = 1;
  blur_params_brightness = 0.9;
  blur_params_contrast = 0.9;
  blur_params_noise = 0.02;
  blur_params_num_passes = 2;
  blur_params_radius = 4;
  blur_params_saturation = 1.2;
  border_px = 1;
  border_radius = 16;
  center_when_single_stack = 1;
  circle_layout = "tile,monocle";
  cursor_hide_timeout = 0;
  cursor_size = 24;
  default_master_count = 1.0;
  default_master_factor = 0.65;
  disable_trackpad = 0;
  drag_corner = 4;
  drag_lock = 1;
  drag_tile_to_tile = 1;
  drag_warp_cursor = 1;
  dwindle_drop_simple_split = 1;
  dwindle_horizontal_split = 1;
  dwindle_preserve_split = 0;
  dwindle_smart_resize = 0;
  dwindle_smart_split = 0;
  dwindle_split_ratio = 0.5;
  dwindle_vertical_split = 1;
  edge_scroller_pointer_focus = 0;
  enable_floating_snap = 1;
  enable_hotarea = 0;
  exchange_cross_monitor = 0;
  fade_in_begin_opacity = 0.5;
  fade_out_begin_opacity = 0.5;
  focus_cross_monitor = 0;
  focus_cross_tag = 0;
  focus_on_activate = 1;
  focused_opacity = 1.0;
  gap_inner_horizontal = 2;
  gap_inner_vertical = 2;
  gap_outer_horizontal = 4;
  gap_outer_vertical = 4;
  hotarea_corner = 2;
  hotarea_size = 10;
  idle_inhibit_ignore_visible = 0;
  layer_animation_type_close = "slide";
  layer_animation_type_open = "slide";
  layer_animations = 1;
  layer_shadows = 0;
  new_is_master = 0;
  no_border_when_single = 0;
  no_radius_when_single = 1;
  numlock_on = 0;
  overview_gap_inner = 12;
  overview_gap_outer = 20;
  repeat_delay = 350;
  repeat_rate = 30;
  scratchpad_cross_monitor = 1;
  scroller_default_proportion = 1.0;
  scroller_default_proportion_single = 1.0;
  scroller_focus_center = 0;
  scroller_prefer_center = 0;
  scroller_prefer_overspread = 1;
  scroller_proportion_preset = "0.5,0.8,1.0";
  scroller_structs = 8;
  shadow_only_floating = 0;
  shadows = 0;
  shadows_blur = 15;
  shadows_position_x = 0;
  shadows_position_y = 0;
  shadows_size = 10;
  single_scratchpad = 0;
  sloppy_focus = 1;
  smart_gaps = 0;
  snap_distance = 20;
  swipe_min_threshold = 1;
  tag_animation_direction = 1;
  tap_and_drag = 1;
  tap_to_click = 1;
  trackpad_click_method = 2;
  trackpad_disable_while_typing = 1;
  trackpad_left_handed = 0;
  trackpad_middle_button_emulation = 1;
  trackpad_natural_scrolling = 1;
  trackpad_scroll_method = 1;
  unfocused_opacity = 1.0;
  view_current_to_back = 0;
  warp_cursor = 0;
  xkb_rules_layout = "us";
  xkb_rules_options = "ctrl:swap_rwin_rctl";
  xwayland_persistence = 1;
  zoom_end_ratio = 0.8;
  zoom_initial_ratio = 0.4;
  tag_rule = [
    "id:1,layout_name:tile"
    "id:2,layout_name:vertical_scroller"
    "id:3,layout_name:vertical_scroller"
    "id:4,layout_name:monocle"
    "id:5,layout_name:monocle"
    "id:6,layout_name:monocle"
    "id:7,layout_name:monocle"
    "id:8,layout_name:monocle"
    "id:9,layout_name:monocle"
  ];
  layer_rule = [
    "no_animation:1,no_shadow:1,layer_name:fyi"
    "no_animation:1,no_shadow:1,layer_name:swaync"
    "no_animation:1,no_shadow:1,layer_name:mako"
    "no_blur:1,no_animation:1,layer_name:selection"
  ];
  window_rule = [
    "no_animation:1,is_floating:1,is_overlay:1,no_animation:1,app_id:slurp"
    "allow_csd:1,no_animation:1,is_floating:1,is_overlay:1,no_animation:1,app_id:com.gabm.satty"
    "is_floating:1,is_overlay:1,app_id:xdg-desktop-portal"
    "is_floating:1,is_overlay:1,app_id:xdg-desktop-portal-gtk"
    "is_floating:1,is_overlay:1,app_id:xdg-desktop-portal-gnome"
    "is_floating:1,is_overlay:1,is_global:1,width:1080,height:720,app_id:termfilechooser"
    "is_floating:1,is_overlay:1,is_global:1,width:1080,height:720,title:termfilechooser"
    "is_floating:1,is_overlay:1,is_global:1,width:1080,height:720,app_id:termfilechooser,title:termfilechooser"
    "is_floating:1,is_overlay:1,is_global:1,is_open_silent:1,width:300,height:200,offset_x:98,offset_y:-98,app_id:it.catboy.ripdrag"
    "is_floating:1,is_overlay:1,is_global:1,is_open_silent:1,width:300,height:200,offset_x:98,offset_y:-98,app_id:dragon-drop"
    "is_floating:1,is_overlay:1,app_id:Pinentry-gtk"
    "is_floating:1,is_overlay:1,app_id:pinentry"
    "is_floating:1,is_overlay:1,app_id:pinentry-qt"
    "is_floating:1,is_overlay:1,app_id:polkit-gnome-authentication-agent-1"
    "is_floating:1,is_overlay:1,app_id:org.gnome.PolicyKit1.AuthenticationAgent"
    "is_floating:1,is_overlay:1,title:Open File"
    "is_floating:1,is_overlay:1,title:Open Files"
    "is_floating:1,is_overlay:1,title:Select a File"
    "is_floating:1,is_overlay:1,title:Choose wallpaper"
    "is_floating:1,is_overlay:1,title:Open Folder"
    "is_floating:1,is_overlay:1,title:Save As"
    "is_floating:1,is_overlay:1,title:Save File"
    "is_floating:1,is_overlay:1,title:Library"
    "is_floating:1,is_overlay:1,title:Print"
    "no_swallow:1,app_id:org.gnome.Nautilus"
    "no_swallow:1,app_id:thunar"
    "no_swallow:1,app_id:nemo"
    "no_swallow:1,app_id:files"
    "allow_csd:1,app_id:firefox"
    "allow_csd:1,app_id:firefox-esr"
    "allow_csd:1,app_id:librewolf"
    "allow_csd:1,app_id:zen-browser"
    "allow_csd:1,app_id:chromium"
    "allow_csd:1,app_id:google-chrome"
    "allow_csd:1,app_id:helium-browser"
    "allow_csd:1,app_id:brave-browser"
    "allow_csd:1,app_id:microsoft-edge"
    "is_floating:1,is_overlay:1,is_global:1,is_open_silent:1,width:540,height:360,offset_x:98,offset_y:-98,title:Picture in picture"
    "is_floating:1,width:1280,height:720,app_id:mpv"
    "is_floating:1,app_id:vlc"
    "is_floating:1,app_id:org.gnome.Nautilus"
    "is_floating:1,app_id:thunar"
    "is_floating:1,app_id:nemo"
    "is_floating:1,app_id:org.kde.dolphin"
    "is_floating:1,app_id:pcmanfm"
    "is_floating:1,app_id:files"
    "is_floating:1,force_fake_maximize:1,app_id:zoom"
    "force_fake_maximize:1,app_id:jetbrains-idea"
    "force_fake_maximize:1,app_id:jetbrains-pycharm"
    "is_floating:1,is_overlay:1,title:win0,app_id:jetbrains-idea"
    "is_floating:1,is_overlay:1,title:win0,app_id:jetbrains-pycharm"
    "force_fake_maximize:1,app_id:code"
    "force_fake_maximize:1,app_id:codium"
    "force_fake_maximize:1,app_id:obsidian"
    "force_fake_maximize:1,app_id:zotero"
    "force_fake_maximize:1,app_id:anki"
    "force_fake_maximize:1,app_id:logseq"
    "force_fake_maximize:1,app_id:libreoffice-writer"
    "force_fake_maximize:1,app_id:libreoffice-calc"
    "force_fake_maximize:1,app_id:libreoffice-impress"
    "force_fake_maximize:1,app_id:libreoffice-draw"
    "is_floating:1,is_overlay:1,app_id:libreoffice,title:Navigator"
    "is_floating:1,is_overlay:1,app_id:libreoffice,title:Styles"
    "is_floating:1,app_id:imv"
    "is_floating:1,app_id:swayimg"
    "allow_csd:1,force_fake_maximize:1,app_id:gimp"
    "force_fake_maximize:1,app_id:org.inkscape.Inkscape"
    "is_floating:1,width:800,height:600,app_id:pavucontrol"
    "is_floating:1,width:800,height:600,app_id:org.pulseaudio.pavucontrol"
    "is_floating:1,width:600,height:500,app_id:blueman-manager"
    "is_floating:1,width:600,height:500,app_id:org.blueman.Manager"
    "is_floating:1,app_id:nm-connection-editor"
    "is_floating:1,app_id:org.gnome.baobab"
    "is_floating:1,app_id:qdirstat"
    "is_floating:1,force_fake_maximize:1,app_id:org.gnome.SystemMonitor"
    "is_floating:1,force_fake_maximize:1,app_id:io.missioncenter.MissionCenter"
    "is_floating:1,app_id:org.gnome.Calculator"
    "is_floating:1,app_id:qalculate-gtk"
    "is_floating:1,app_id:org.gnome.FileRoller"
    "is_floating:1,app_id:ark"
    "force_fake_maximize:1,app_id:steam"
    "is_floating:1,is_overlay:1,app_id:steam,title:Steam Guard"
    "is_floating:1,is_overlay:1,app_id:steam,title:Steam - Self Updater"
    "is_floating:1,is_overlay:1,app_id:steam,title:Friends List"
    "no_blur:1,no_animation:1,app_id:steam_app_.*"
    "force_tearing:1,no_animation:1,no_border:1,no_shadow:1,no_radius:1,title:steam_app_.*"
    "is_floating:1,force_fake_maximize:1,app_id:lutris"
    "is_floating:1,is_overlay:1,app_id:lutris,title:Lutris"
    "is_floating:1,is_overlay:1,title:Wine System Tray"
    "is_floating:1,no_animation:1,no_border:1,no_shadow:1,no_radius:1,allow_shortcuts_inhibit:1,app_id:osu"
    "is_floating:1,no_animation:1,no_border:1,no_shadow:1,no_radius:1,force_tearing:1,app_id:Ryujinx"
    "is_floating:1,no_animation:1,no_border:1,no_shadow:1,no_radius:1,force_tearing:1,app_id:yuzu"
    "is_floating:1,no_animation:1,no_border:1,no_shadow:1,no_radius:1,force_tearing:1,app_id:suyu"
    "is_floating:1,no_animation:1,no_border:1,no_shadow:1,no_radius:1,force_tearing:1,app_id:rpcs3"
    "is_floating:1,no_animation:1,no_border:1,no_shadow:1,no_radius:1,force_tearing:1,app_id:PPSSPP"
    "is_floating:1,no_animation:1,no_border:1,no_shadow:1,no_radius:1,force_tearing:1,app_id:dolphin-emu"
    "is_floating:1,no_animation:1,no_border:1,no_shadow:1,no_radius:1,force_tearing:1,app_id:pcsx2"
    "is_floating:1,no_animation:1,no_border:1,no_shadow:1,no_radius:1,force_tearing:1,app_id:retroarch"
    "force_fake_maximize:1,app_id:at.yrlf.wl_mirror"
    "is_floating:1,app_id:one.alynx.showmethekey"
    "is_floating:1,is_overlay:1,app_id:showmethekey-gtk"
    "is_floating:1,is_overlay:1,force_fake_maximize:1,app_id:dev.noctalia.Noctalia,title:Noctalia Settings"
    "is_named_scratchpad:1,width:1080,height:720,app_id:scratchpad"
  ];
  gesturebind = [
    "NONE,left,3,viewtoright"
    "NONE,right,3,viewtoleft"
    "NONE,Up,3,focusdir,down"
    "NONE,Down,3,focusdir,up"
    "NONE,left,4,viewtoright_have_client"
    "NONE,right,4,viewtoleft_have_client"
    "NONE,Up,4,toggleoverview"
  ];
  axisbind = [
    "SUPER,Up,viewtoleft_have_client"
    "SUPER,Down,viewtoright_have_client"
    "ALT,UP,focusdir,up"
    "ALT,DOWN,focusdir,down"
    "ALT+SHIFT,UP,focusdir,left"
    "ALT+SHIFT,DOWN,focusdir,right"
  ];
  bind = [
    "SUPER,minus,toggle_scratchpad"
    "SUPER,grave,toggle_named_scratchpad,scratchpad,none,kitty --app-id=scratchpad"
  ];
  mousebind = [
    "SUPER,btn_left,moveresize,curmove"
    "SUPER,btn_right,moveresize,curresize"
  ];
  key_mode = {
    common = {
      bind = "SUPER+SHIFT,R,reload_config";
    };
    default = {
      bind = [
        "SUPER,Return,spawn_on_empty,kitty,1"
        "SUPER+SHIFT,Return,spawn,kitty"
        "SUPER,W,spawn_on_empty,brave-origin,2"
        "SUPER+SHIFT+ALT,q,quit"
        "SUPER,Tab,focuslast"
        "SUPER,Left,focusdir,left"
        "SUPER,Right,focusdir,right"
        "SUPER,Up,focusdir,up"
        "SUPER,Down,focusdir,down"
        "SUPER,h,focusdir,left"
        "SUPER,l,focusdir,right"
        "SUPER,k,focusdir,up"
        "SUPER,j,focusdir,down"
        "SUPER+SHIFT,Up,exchange_client,up"
        "SUPER+SHIFT,Down,exchange_client,down"
        "SUPER+SHIFT,Left,exchange_client,left"
        "SUPER+SHIFT,Right,exchange_client,right"
        "SUPER+SHIFT,k,exchange_client,up"
        "SUPER+SHIFT,j,exchange_client,down"
        "SUPER+SHIFT,h,exchange_client,left"
        "SUPER+SHIFT,l,exchange_client,right"
        "SUPER+SHIFT,Space,togglefloating"
        "SUPER,g,toggleglobal"
        "SUPER,o,toggleoverlay"
        "SUPER+SHIFT,f,togglefullscreen"
        "SUPER,m,togglemaximizescreen"
        "SUPER,i,minimized"
        "SUPER+SHIFT,i,restore_minimized"
        "SUPER+SHIFT,C,centerwin"
        "SUPER+SHIFT,X,incgaps,1"
        "SUPER+SHIFT,Z,incgaps,-1"
        "SUPER+SHIFT,G,togglegaps"
        "SUPER+ALT,Space,switch_layout"
        "SUPER+ALT,t,setlayout,tile"
        "SUPER+ALT,s,setlayout,scroller"
        "SUPER+ALT,m,setlayout,monocle"
        "SUPER,x,switch_proportion_preset"
        "SUPER,Z,zoom"
        "SUPER+CTRL,h,setmfact,-0.05"
        "SUPER+CTRL,l,setmfact,+0.05"
        "SUPER+CTRL,j,incnmaster,-1"
        "SUPER+CTRL,k,incnmaster,+1"
        "SUPER,bracketleft,viewtoleft,0"
        "SUPER,bracketright,viewtoright,0"
        "SUPER+SHIFT,bracketleft,tagtoleft,0"
        "SUPER+SHIFT,bracketright,tagtoright,0"
        "SUPER,1,view,1,0"
        "SUPER,2,view,2,0"
        "SUPER,3,view,3,0"
        "SUPER,4,view,4,0"
        "SUPER,5,view,5,0"
        "SUPER,6,view,6,0"
        "SUPER,7,view,7,0"
        "SUPER,8,view,8,0"
        "SUPER,9,view,9,0"
        "SUPER+SHIFT,1,tag,1,0"
        "SUPER+SHIFT,2,tag,2,0"
        "SUPER+SHIFT,3,tag,3,0"
        "SUPER+SHIFT,4,tag,4,0"
        "SUPER+SHIFT,5,tag,5,0"
        "SUPER+SHIFT,6,tag,6,0"
        "SUPER+SHIFT,7,tag,7,0"
        "SUPER+SHIFT,8,tag,8,0"
        "SUPER+SHIFT,9,tag,9,0"
        "SUPER+ALT,1,tagsilent,1,0"
        "SUPER+ALT,2,tagsilent,2,0"
        "SUPER+ALT,3,tagsilent,3,0"
        "SUPER+ALT,4,tagsilent,4,0"
        "SUPER+ALT,5,tagsilent,5,0"
        "SUPER+ALT,6,tagsilent,6,0"
        "SUPER+ALT,7,tagsilent,7,0"
        "SUPER+ALT,8,tagsilent,8,0"
        "SUPER+ALT,9,tagsilent,9,0"
        "SUPER+ALT,comma,focusmon,left"
        "SUPER+ALT,period,focusmon,right"
        "SUPER+CTRL+SHIFT,comma,tagmon,left,0"
        "SUPER+CTRL+SHIFT,period,tagmon,right,0"
        "SUPER+ALT,bracketleft,focusmon,left"
        "SUPER+ALT,bracketright,focusmon,right"
        "SUPER+ALT+SHIFT,bracketleft,tagmon,left,1"
        "SUPER+ALT+SHIFT,bracketright,tagmon,right,1"
        "NONE,XF86AudioPrev,spawn,noctalia msg media prev"
        "NONE,XF86AudioPlay,spawn,noctalia msg media toggle"
        "NONE,XF86AudioNext,spawn,noctalia msg media next"
        "NONE,XF86KbdBrightnessDown,spawn,brightnessctl --device=*kbd_backlight set 1-"
        "NONE,XF86KbdBrightnessUp,spawn,brightnessctl --device=*kbd_backlight set 1+"
        "NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up"
        "NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down"
        "NONE,XF86AudioMute,spawn,noctalia msg volume-mute"
        "NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up"
        "NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down"
        "SUPER,Space,spawn,lookapp --toggle"
        "SUPER,A,spawn,lookapp --toggle"
        "SUPER,V,spawn,lookapp clipboard"
        "SUPER,E,spawn,lookapp --toggle"
        "SUPER,C,spawn,noctalia msg panel-toggle control-center"
        "SUPER,N,spawn,noctalia msg panel-toggle notifications"
        "SUPER,Y,spawn,noctalia msg panel-toggle wallpaper"
        "SUPER,Comma,spawn,noctalia msg settings-toggle"
        "SUPER,Escape,spawn,noctalia msg panel-toggle session"
        "SUPER,R,setkeymode,resize"
      ];
    };
    resize = {
      bind = [
        "NONE,Up,smartresizewin,up"
        "NONE,Down,smartresizewin,down"
        "NONE,Left,smartresizewin,left"
        "NONE,Right,smartresizewin,right"
        "NONE,K,resizewin,+0,-20"
        "NONE,J,resizewin,+0,+20"
        "NONE,H,resizewin,-20,+0"
        "NONE,L,resizewin,+20,+0"
        "NONE,C,centerwin"
        "NONE,Escape,setkeymode,default"
        "NONE,Q,setkeymode,default"
      ];
    };
  };
}
