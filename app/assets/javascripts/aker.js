(function(self) {
  self.Aker = self.Aker || {};

  self.Aker.claim = function(submissionIds, collectionId, stampId) {
    $.post({
      url: '/claim_submissions/claim',
      data: {
        submission_ids: submissionIds,
        collection_id: collectionId,
        stamp_id: stampId
      },
      success: function() {
        window.location.reload(true);
      }
    });
  };
})(window);