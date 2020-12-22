var exec = require('cordova/exec');

exports.isAvailable = function(success, error) {
  exec(success, error, "SignInWithApple", "isAvailable", []);
};

exports.signin = function(arg0, success, error) {
  exec(success, error, "SignInWithApple", "signin", [arg0]);
};
