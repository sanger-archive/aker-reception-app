import $ from 'jquery'

import 'gasparesganga-jquery-loading-overlay/dist/loadingoverlay.js'

// Class that uses a jQuery Loading Overlay plugin on a single node.
// LoadingOverlay docs can be found at https://gasparesganga.com/labs/jquery-loading-overlay/
class LoadingOverlay {
  constructor (node, params) {
    this.$node = $(node)
    this.params = params || {}

    // Event Handlers
    this.show = this.show.bind(this)
    this.hide = this.hide.bind(this)
    this.update = this.update.bind(this)

    this.attachListeners()
  }

  attachListeners () {
    $(document).on('showLoadingOverlay', this.show)
    $(document).on('hideLoadingOverlay', this.hide)
    if (this.params.progress) $(document).on('updateLoadingOverlay', this.update)
  }

  show () {
    this.$node.LoadingOverlay('show', this.params)
  }

  hide () {
    this.$node.LoadingOverlay('hide')
  }

  // Params is an object containing progress as an integer
  // e.g. { progress: 33 }
  update (e, params) {
    this.$node.LoadingOverlay('progress', params.progress)
  }
}

export default LoadingOverlay

$(document).ready(function () {
  $(document).trigger('registerComponent.builder', { 'LoadingOverlay': LoadingOverlay })
})
