var buildJSReport = function() {
  var allPassed = true;
  var report = {
    suites: _.map(jsApiReporter.suites(), function(suite) {
      var suitePassed = true
      var mySpecs = _.filter(jsApiReporter.specs(), function(spec) {
        return spec.fullName.indexOf(suite.description) === 0;
      });
      _.each(mySpecs, function(spec) {
        if (spec.status !== 'passed' && spec.status !== 'skipped') {
          suitePassed = false;
          allPassed = false;
        }
      });
      return {
        description: suite.description,
        passed: suitePassed,
        durationSec: 0,
        suites: [] // no sub-suites
      };
    }),
    durationSec: jsApiReporter.executionTime() / 1000,
    passed: allPassed
  };
  return report;
};

var jasmineEnv = jasmine.getEnv();
jasmineEnv.addReporter({
  jasmineDone: function() {
    try {
      var report = buildJSReport();
      window.jasmine.getJSReport = function() {
        return report;
      };
    } catch (e) {
      console.error(e);
    }
  }
});
