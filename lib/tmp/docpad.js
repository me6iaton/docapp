// Generated by CoffeeScript 1.8.0
(function() {
  var Docpad, configDefaults;

  Docpad = require('docpad');

  console.log("childProcess yo");

  console.log(process.version);

  console.log(process.versions);

  console.log(process.cwd());

  configDefaults = {
    rootPath: '/var/www/atom/docapp'
  };

  Docpad.createInstance(configDefaults, function(err, docpadInstance) {
    if (err) {
      return console.log(err.stack);
    }
    return docpadInstance.action("generate", function(err, result) {
      if (err) {
        return console.log(err.stack);
      }
      return console.log("OK");
    });
  });

}).call(this);

//# sourceMappingURL=docpad.js.map