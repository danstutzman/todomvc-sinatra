// Karma configuration
// Generated on Fri Jan 24 2014 09:41:26 GMT-0700 (MST)

module.exports = function(config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: '',


    // frameworks to use
    frameworks: ['mocha', 'browserify'],


    // list of files / patterns to load in the browser
    files: [
      'js/*.js',
      'js/*.coffee',
      'test/**/*.js',
      'test/**/*.coffee'
    ],


    // list of files to exclude
    exclude: [
      
    ],


    preprocessors: {
        'test/**/*.coffee': ['browserify'],
        'test/**/*.js': ['browserify']
    },


    browserify: {
        extensions: ['.coffee'],
        transform: ['coffeeify'],
        watch: true,   // Watches dependencies only (Karma watches the tests)
        debug: true,   // Adds source maps to bundle
        noParse: ['jquery'] // Don't parse some modules
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


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera (has to be installed with `npm install karma-opera-launcher`)
    // - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
    // - PhantomJS
    // - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
    browsers: ['IE6 - WinXP', 'Chrome', 'Firefox', 'Opera', 'Safari'],


    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false
  });
};
