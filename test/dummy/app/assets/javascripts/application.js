// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= rails-ujs
//= require activestorage
//= require mr519_gen/application
//= require_tree .

$(function () {
  $('.grid-stack').gridstack({
    resizable: {
              handles: 'e, w'
          }
  });
  var self = this;
  this.grid = $('.grid-stack').data('gridstack');
  $('.grid-stack').on('added', function(event, items) {
    // add anijs data to gridstack item
    for (var i = 0; i < items.length; i++) {
      $(items[i].el[0]).attr('data-anijs', 'if: added, do: swing animated, after: $removeAnimations, on: $gridstack');
    }
    AniJS.run();
    self.gridstackNotifier = AniJS.getNotifier('gridstack');
    // fire added event!
    self.gridstackNotifier.dispatchEvent('added');
  });
  $('#add-widget').click(function() {
    addNewWidget();
  });
  function addNewWidget() {
    var grid = $('.grid-stack').data('gridstack');
    grid.addWidget($('<div><div class="grid-stack-item-content"></div></div>'), 0, 0, Math.floor(1 + 3 * Math.random()),1, true);
  }
  var animationHelper = AniJS.getHelper();
  //Defining removeAnimations to remove existing animations
  animationHelper.removeAnimations = function(e, animationContext){
    $('.grid-stack-item').attr('data-anijs', '');
  };
});
