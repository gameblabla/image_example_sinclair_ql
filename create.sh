#!/bin/sh
rm main.win
qxltool -w -W main.win 8 QXL Label
qxltool -w -c "wr MAIN MAIN" main.win
qxltool -w -c "wr IMGZX0 IMGZX0" main.win
qxltool -w -c "wr boot boot" main.win
