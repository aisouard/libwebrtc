'use strict';

var os = require('os');
var fs = require('fs-extra');

namespace('build', function () {
  task('generate', {async: true}, function () {
    var opts = 'use_gold=false is_debug=false rtc_include_tests=false';

    process.env.PATH = process.cwd() + '/Dependencies/depot_tools:' + process.env.PATH;
    process.chdir('src');
    jake.exec('gn gen out/Default --args=\'' + opts + '\'', function () {
      complete();
    });
  });

  task('ninja', ['build:generate'], {async: true}, function () {
    var packages = 'libjingle_peerconnection field_trial_default metrics_default';

    console.log('Building WebRTC...');
    jake.exec('ninja -C out/Default ' + packages, { printStdout: true }, function () {
      complete();
    });
  });

  task('merge', ['build:ninja'], {async: true}, function () {
    var prefix = os.platform() !== 'windows' ? 'lib' : '';
    var suffix = os.platform() === 'windows' ? '.lib' : '.a';
    var path = '../lib/' + prefix + 'webrtc' + suffix;

    console.log('Merging libraries...');

    if (!fs.existsSync('../lib')) {
      fs.mkdir('../lib');
    }

    jake.exec('python webrtc/build/merge_libs.py out/Default ' + path, function () {
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
