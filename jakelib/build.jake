'use strict';

var os = require('os');
var fs = require('fs-extra');
var exec = require('child_process').exec;
var execSync = require('child_process').execSync;

namespace('build', function () {
  task('generate', {async: true}, function () {
    var opts = 'use_gold=false is_debug=false rtc_include_tests=false';
    var pathSep = (os.platform() === 'win32') ? '\\' : '/';
    var envSep = (os.platform() === 'win32') ? ';' : ':';

    if (os.platform() === 'win32') {
      process.env.DEPOT_TOOLS_WIN_TOOLCHAIN = 0;
      process.env.PATH = process.cwd() + '/Dependencies/depot_tools;' + process.env.PATH;
      process.env.PATH = process.cwd() + '/Dependencies/depot_tools/python276_bin;' + process.env.PATH;
    } else {
      process.env.PATH = process.cwd() + '/Dependencies/depot_tools:' + process.env.PATH;
    }

    console.log('Generating WebRTC build files...' + 'gn gen out/Default --args=\'' + opts + '\'');

    process.chdir('src');
    exec('gn gen out/Default --args="' + opts + '"', function (error, stdout, stderr) {
      complete();
    });
  });

  task('ninja', ['build:generate'], {async: true}, function () {
    var packages = 'libjingle_peerconnection field_trial_default metrics_default';

    console.log('Building WebRTC...');
    jake.exec('ninja -C out/Default ' + packages, { printStdout: true, printStderr: true }, function () {
      complete();
    });
  });

  task('merge', ['build:ninja'], {async: true}, function () {
    var prefix = os.platform() !== 'win32' ? 'lib' : '';
    var suffix = os.platform() === 'win32' ? '.lib' : '.a';
    var path = '../lib/' + prefix + 'webrtc' + suffix;

    console.log('Merging libraries...');

    if (!fs.existsSync('../lib')) {
      fs.mkdir('../lib');
    }

    if (os.platform() === 'win32') {
      var output = execSync('python chromium/src/build/vs_toolchain.py get_toolchain_dir', { encoding: 'utf-8' });
      var matches = output.match(/vs_path = \"(.*)\"/);
      console.log(matches);

      process.env.PATH = matches[1] + '\\VC\\bin' + ';' + process.env.PATH;
    }

    jake.exec('python webrtc/build/merge_libs.py out/Default ' + path, { printStdout: true, printStderr: true }, function () {
      complete();
    });
  });

  task('include', ['build:merge'], function () {
    var fileList = new jake.FileList();
    var files;

    console.log('Copying include files...');
    if (!fs.existsSync('../include')) {
      fs.mkdir('../include');
    }

    fileList.include('webrtc/**/*.h');
    files = fileList.toArray();

    for (var file in files) {
      fs.copySync(files[file], '../include/' + files[file]);
    }
  });

  task('default', [
    'generate',
    'ninja',
    'merge',
    'include'
  ], function () {});
});
