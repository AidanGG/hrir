## PulseAudio virtual surround HRIR builder

This script builds a 7.1 HRIR for PulseAudios
[module-virtual-surround-sink](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/#module-virtual-surround-sink)
from the LISTEN Database.

### Dependencies
* GNU Octave
* FFMpeg

### Usage
Select a measurement data set by listening to different demo sounds
[here](http://recherche.ircam.fr/equipes/salles/listen/sounds.html).
Ideally, the demo sound should listen like a noise that moves in a circle
around your head.

Then download and extract the measurement data from the
[LISTEN Database](http://recherche.ircam.fr/equipes/salles/listen/download.html).

Adjust the variables "azim" and "elev" in the script to configure your
preferred speaker locations and set the filename of the measurement data to use.

Finally, run `octave build_hrir.m`.
This will produce a file `hrir.wav` in the current directory.
