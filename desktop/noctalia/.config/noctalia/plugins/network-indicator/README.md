# NetworkIndicator Plugin for Noctalia

A compact Noctalia bar widget that displays current network upload (TX) and download (RX) activity, with optional live throughput values and a hover-activated graph panel.

## Features

- **TX/RX Activity Indicators**: Separate icons for upload (TX) and download (RX).
- **Active/Idle Coloring**: Icons switch between "active" and "silent" colors based on a configurable traffic threshold.
- **Optional Throughput Values**: Displays formatted TX/RX speeds as text (shown only when the bar is spacious and horizontal).
- **Vertical and Horizontal Layouts**: Stack TX/RX values on the left of the arrows, or place them side by side with arrows centered in between.
- **Unit Formatting**: Automatically switches between KB/s and MB/s, or can be configured to always display MB/s.
- **Custom Font**: Override the default font for speed values, with optional bold and italic styles.
- **Network Graph Panel**: Hover over the widget to open a live graph showing RX and TX history from the system monitor.
- **Theme Support**: Uses Noctalia theme colors by default, with optional custom colors.
- **Configurable Settings**: Provides a comprehensive set of user-adjustable options.

## Installation

This plugin is part of the `noctalia-plugins` repository.

## Configuration

Access the plugin settings in Noctalia to configure the following options:

- **Icon Type**: Select the icon style used for TX/RX: `arrow`, `arrow-bar`, `arrow-big`, `arrow-narrow`, `caret`, `chevron`, `chevron-compact`, `fold`.
- **Show Values**: Display formatted TX/RX speeds as numbers. Automatically hidden on vertical bars and when using "mini" density.
- **Force Megabytes**: Always display values in MB/s instead of switching to KB/s at low traffic levels.
- **Horizontal Layout**: Place TX and RX values side by side instead of stacked.
- **Minimum Width**: Set a minimum width for the widget to prevent resizing when values change.
- **Content Margin**: Horizontal padding on both sides of the widget content.
- **Show Active Threshold**: Set the traffic threshold in bytes per second (B/s) above which TX/RX is considered "active".
- **Vertical Spacing**: Adjust the spacing between the TX and RX elements.
- **Font Size Modifier**: Scale the text size.
- **Icon Size Modifier**: Scale the icon size.
- **Custom Font**: Override the default font with any installed font, with bold and italic options.
- **Custom Colors**: When enabled, configure TX Active, RX Active, RX/TX Inactive, Text, Font, and Background colors.

## Usage

- Add the widget to your Noctalia bar.
- Hover over the widget to open the network graph panel.
- Right-click the widget to access settings.
- Configure the plugin settings as required.

## Requirements

- Noctalia 4.7.6 or later.

## Technical Details

- The widget reads `SystemStatService.txSpeed` and `SystemStatService.rxSpeed`; the polling interval is determined by that service.
- The graph panel uses `SystemStatService.rxSpeedHistory` and `SystemStatService.txSpeedHistory` with `NGraph` from the Noctalia Shell.
- The panel opens on hover with a short delay and closes automatically when the cursor leaves the widget.
