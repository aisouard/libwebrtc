import os
import sys
import vs_toolchain

if sys.platform == 'win32':
    vs_toolchain.GetToolchainDir()
    os.environ['PATH'] += os.pathsep + os.environ['GYP_MSVS_OVERRIDE_PATH'] + '\\VC\\bin'

execfile('src/webrtc/build/merge_libs.py')
