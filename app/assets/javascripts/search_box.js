var search_box = $('#search-box');
var search_box_button = $('#search-box-button');

search_box.focus();
search_box.keypress(function(e) {
  if (e.which == 13) {
    search_box_button.trigger('click');
  }
})

search_box_button.on('click', function() {
  var query = search_box.val().trim();

  $.ajax({
    url: '/search/dictionary/' + query,
    method: 'GET',
    beforeSend: function() {
      search_control_enabled(false);
    }
  }).done(function(res) {
    update_ngram_list(query, res);
    search_control_enabled(true);
    update_search_history(query, res.length);
    clean_up();
  })
});

function search_control_enabled(status) {
  search_box.attr('disabled', !status);
}

function clean_up() {
  search_box.val('');
  search_box.focus();
}