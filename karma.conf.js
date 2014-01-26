// Karma configuration
// Generated on Fri Jan 24 2014 09:41:26 GMT-0700 (MST)

module.exports = function(config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: '',


    // frameworks to use
    frameworks: ['jasmine', 'browserify'],


    // list of files / patterns to load in the browser
    files: [
        'app/bower_components/es5-shim/es5-shim.js',
        'app/bower_components/es5-shim/es5-sham.js',
        'app/bower_components/console-polyfill/index.js',
        'test/react-with-test-utils.js',
        'app/*.coffee',
        'test/**/*.coffee'
    ],


    // list of files to exclude
    exclude: [
        'app/main.coffee'
    ],


    preprocessors: {
        'app/*.coffee': ['browserify'],
        'test/**/*.coffee': ['browserify'],
    },


    browserify: {
        extensions: ['.coffee'],
        transform: ['coffeeify'],
        watch: true,   // Watches dependencies only (Karma watches the tests)
        debug: true,   // Adds source maps to bundle
        noParse: ['test/react-with-test-utils.js'] // Don't parse some modules
    },

    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress', 'osx'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    //browsers: ['IE6 - WinXP', 'Chrome', 'Firefox', 'Opera', 'Safari'],
    //browsers: ['IE6 - WinXP'],
    browsers: ['Firefox'],


    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false
  });
};
