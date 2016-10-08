'use strict';

var os = require('os');
var pkg = require('../package.json');

function getPackageName() {
  var version = pkg.version;
  var platform = os.platform();
  var arch = os.arch();
  var nodever = process.version;
  var suffix = (platform === 'windows') ? '.zip' : '.tar.gz';

  return pkg.config.filename
      .replace('{VERSION}', version)
      .replace('{PLATFORM}', platform)
      .replace('{ARCH}', arch)
      .replace('{NODEVER}', nodever) + suffix;
}

module.exports = {
  getPackageName: getPackageName
};
