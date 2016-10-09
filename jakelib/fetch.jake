'use strict';

var download = require('download');
var fs = require('fs');
var getPackageName = require('./common').getPackageName;
var os = require('os');
var pkg = require('../package.json');

var WebRTCUrl = pkg.config.webrtc.url;
var WebRTCRev = pkg.config.webrtc.revision;
var ChromiumUrl = pkg.config.chromium.url;

namespace('fetch', function () {
  task('precompiled', ['download'], function () {
  });

  task('download', {async: true}, function () {
    var url = pkg.config.url + '/' + pkg.version + '/' + getPackageName();

    console.log('Downloading', url);
    download(url, '.')
      .then(function () {
        var task = jake.Task['fetch:extract'];

        task.addListener('complete', function () {
          console.log('Done');
          complete();
        });

        task.invoke();
      })
      .catch(function (err) {
        var task = jake.Task['fetch:source'];

        console.log('Failed, building libwebrtc from source.');
        task.addListener('complete', function () {
          complete();
        });

        task.invoke();
      });
  });

  task('extract', {async: true}, function () {
    var packageName = getPackageName();

    console.log('Extracting', packageName);
    jake.exec('tar xf ' + packageName, function () {
      fs.unlinkSync(packageName);
      complete();
    });
  });

  task('submodules', {async: true}, function () {
    console.log('Updating submodules...');
    jake.exec(['git submodule init', 'git submodule update'], {printStdout: true}, function () {
      complete();
    });
  });

  task('configure', ['fetch:submodules'], {async: true}, function () {
    console.log('Configuring gclient to fetch WebRTC code');
    process.env.PATH = process.cwd() + '/Dependencies/depot_tools:' + process.env.PATH;
    jake.exec('gclient config --name src ' + WebRTCUrl, {printStdout: true}, function () {
      complete();
    });
  });

  task('sync', ['fetch:configure'], {async: true}, function () {
    console.log('Retrieving WebRTC source code');
    jake.exec('gclient sync --revision ' + WebRTCRev + ' -n -D', {printStdout: true}, function () {
      complete();
    });
  });

  task('chromium', ['fetch:sync'], {async: true}, function () {
    console.log('Retrieving Chromium dependencies');
    jake.exec('git clone ' + ChromiumUrl + ' src/chromium/src', { breakOnError: false, printStdout: true }, function () {
      complete();
    });
  });

  task('clang', ['fetch:chromium'], {async: true}, function () {
    console.log('Updating clang');
    jake.exec('python src/chromium/src/tools/clang/scripts/update.py', {printStdout: true}, function () {
      complete();
    });
  });

  task('links', ['fetch:clang'], {async: true}, function () {
    console.log('Creating symbolic links');
    jake.exec('python src/setup_links.py', {printStdout: true}, function () {
      complete();
    });
  });

  task('source', [
    'links',
    'build:default'
  ], function () {
  });
});
