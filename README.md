## PulseAudio virtual surround HRIR builder

This script builds a 7.1 surround HRIR for PulseAudios
[module-virtual-surround-sink](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/#module-virtual-surround-sink).

### Dependencies
* GNU Octave
* FFMpeg

### Usage
Download a HRIR database from a source of your choice. Currently supported are:

#### LISTEN Database
Select a measurement data set by listening to different demo sounds
[here](http://recherche.ircam.fr/equipes/salles/listen/sounds.html).
Ideally, the demo sound should listen like a noise that moves in a circle
around your head.

Then download and extract the measurement data from the
[LISTEN Database](http://recherche.ircam.fr/equipes/salles/listen/download.html).

#### Measurements from TU Berlin
Download a .mat-File from [TU-Berlin](https://dev.qu.tu-berlin.de/projects/measurements/repository).

#### Script settings
Adjust the variables "azim" and "elev" in the script to configure your
preferred speaker locations and set the filename of the measurement data to use.
See comments in the script as well.

Finally, run `octave build_hrir.m`.
This will produce a file `hrir.wav` in the current directory.
