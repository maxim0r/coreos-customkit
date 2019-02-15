#!/bin/sh
chvt 7
mplayer -vo fbdev2 -ao null -fs -noconsolecontrols $@
