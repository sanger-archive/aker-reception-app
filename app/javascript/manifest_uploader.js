import { uploadManifest } from 'csv_field_checker';

class ManifestUploader {
  constructor(node, params) {
    this.node     = $(node);
    this.params   = params;
    this.onChange = this.onChange.bind(this);

    this.attachHandlers();
  }

  attachHandlers() {
    this.node.on('change', this.onChange)
  }

  onChange() {
    uploadManifest(this.node[0].files[0], this.params.manifest_id);

    // Clearing the input allows the change event to fire again
    $(this).val(null);
  }
}

$(document).ready(function() {
  $(document).trigger('registerComponent.builder', { 'ManifestUploader': ManifestUploader });
});

export default ManifestUploader;
