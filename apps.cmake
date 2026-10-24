# Apps that `load-apps` installs on the iPhone. All are native Swift, XcodeGen-based
# (<DIR>/project.yml), built with the scheme named after the app.
#
# Each entry: "<name>|<dir>|<bundle id>|<launch ON or OFF>"
# Comment an entry out to drop it from load-apps. Add a line to include another app.
set(MAGIC_APPS
  "MagicCalculator|MagicCalculator|com.rahulbhatt.MagicCalculator|OFF"
  "MagicNotes|MagicNotes|com.rahulbhatt.MagicNotes|ON"
)
