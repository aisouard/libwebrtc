'use strict';

var os = require('os');
var getPackageName = require('./common').getPackageName;

task('package', {async: true}, function () {
  var packageName = getPackageName();

  console.log('Creating ' + packageName + '...');
  if (os.platform() !== 'win32') {
    jake.exec('tar cfz ' + packageName + ' include lib', function () {
      complete();
    });
  }
});
