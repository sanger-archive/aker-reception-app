window.ManifestCSVWarnings = {};

var warnings = [];
var visibleWarnings = [];

ManifestCSVWarnings.addWarning = function(warningType) {
  if (!warnings.includes(warningType)) {
    warnings.push(warningType);
  }
  ManifestCSVWarnings.showWarnings();
};

ManifestCSVWarnings.showWarnings = function() {
  var warningDiv = $('#warning-messages');
  warnings.forEach( function(warning) {
    if (!visibleWarnings.includes(warning)) {
      if (warning == "hmdmc") {
        warningDiv.append(
            ["<strong>HMDMC Alert</strong>",
            "<p>You have added human material without an HMDMC number. ",
            "If you intended to do this, please confirm during the next step.</p>"].join(''));
      } else if (warning == "sciname-taxon") {
        warningDiv.append(
          ["<strong>Duplicate Data</strong>",
          "<p>The scientific name included in the manifest has been ignored, as ",
          "this is determined by the Taxon ID.</p><p>If the scientific name is ",
          "incorrect, please <a href='https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi' target='_blank' class='alert-link'>find the appropriate Taxon ID</a> and try again.</p>"].join(''));
      }
    }
    visibleWarnings.push(warning);
  });
  warningDiv.toggleClass('hidden', false);
};

ManifestCSVWarnings.clearWarnings = function() {
  warnings = [];
  visibleWarnings = [];
  var warningDiv = $('#warning-messages');
  warningDiv.toggleClass('hidden', true);
  warningDiv.html('');
};

// Get rid of the warnings when switching between labware tabs
$(document).on("turbolinks:load", function() {
  $('a[role="tab"]').click(function() {
    ManifestCSVWarnings.clearWarnings();
  });
});
