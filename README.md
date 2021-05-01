# obs-participants-lottery

> A lottery script for OBS

Made 2021 by Arttu Ylhävuori (AY). Licensed under [GPL-3.0 License](https://github.com/areee/obs-participants-lottery/blob/main/LICENSE).

- The source code is based on [the countdown script of OBS Studio](https://github.com/obsproject/obs-studio/blob/master/UI/frontend-plugins/frontend-tools/data/scripts/countdown.lua). It's licensed under [GPL-2.0 License](https://github.com/obsproject/obs-studio/blob/master/COPYING).
- Changes:
  - `run_lottery` function made by AY
  - Removed unneeded variables
  - Renamed some functions & variables based on the lottery idea
  - Removed all unnecessary commenting

## Features
- The script is available in English, Finnish and Swedish
- Add participant names of a meeting
- Automatically draw participants into a new order
- Draw again by clicking the _Start again_ button
- Change the name list layout by updating the _Names per row_ field

## Screenshots

![A scripts view in OBS showing a loaded participants lottery file.](https://raw.githubusercontent.com/areee/obs-participants-lottery/main/screenshots/image1.png)

_Image 1: A scripts view (Tools -> Scripts) with default settings when participants-lottery-en.lua is added._

![Example names shown as an output in OBS scene.](https://raw.githubusercontent.com/areee/obs-participants-lottery/main/screenshots/image2.png)

_Image 2: The final result in a scene._
