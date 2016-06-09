//var ngram_list_table = $('#ngram-list-table');
var ngram_list_table_body = $('#ngram-list-table-body');
var ngram_memo_table = $('#ngram-memo-table');
var ngram_details = $('#ngram-details');
var ngram_details_hanzi = $('#ngram-details-hanzi');
var ngram_add = $('#ngram-add');

ngram_add.on('click', function() { ngram_add.hide(); });
ngram_add.on('click', add_ngram_to_memo);

function already_in_memo(x) {
  var handle_selector = '[data-handle-id="' + x + '"]';
  return ngram_memo_table.find(handle_selector).length > 0;
}

function make_ngram_interactive(x) {
  ngram_details_hanzi.empty();
  x.make_hanzi_interactive(ngram_details_hanzi);
}

function launch_structural_query(x) {
  $.ajax({
    url: '/search/structural/' + x,
    method: 'GET'
  }).done(function(res) {
    update_hanzi_debug_table(x, res);
  })
}

function ngram_details_conditionally_show_add_button() {
  if (ngram_details_hanzi.text().trim().length > 0) {
    var handle_id = ngram_details.attr('data-handle-id');

    if (already_in_memo(handle_id)) {
      ngram_add.hide();
    } else {
      ngram_add.show();
    }
  } else {
    ngram_add.hide();
  }
}

function memo_cell_deletion() {
  return $('<td>')
           .append($('<span>')
                     .addClass('glyphicon glyphicon-remove')
                     .css('visibility', 'hidden'))
           .on('click', remove_memo_cell);
}

function remove_memo_cell() {
  $(this).parent().remove();
  ngram_details_conditionally_show_add_button();
}

function reveal_memo_remove() {
  $(this).find('.glyphicon-remove').css('visibility', 'visible');
}

function hide_memo_remove() {
  $(this).find('.glyphicon-remove').css('visibility', 'hidden');
}

function add_ngram_to_memo() {
  var handle_id = $(this).parent().parent().parent().attr('data-handle-id');
  var handle_selector = '[data-handle-id="' + handle_id + '"]';

  if (!already_in_memo(handle_id)) {
    var clone = ngram_list_table_body
                  .find(handle_selector)
                  .clone(false)
                  .append(memo_cell_deletion())
                  .on('click', add_to_ngram_details)
                  .on('mouseover', reveal_memo_remove)
                  .on('mouseout',  hide_memo_remove);

    $.each(clone.find('[data-toggle="ngram-tooltip"]'), function() {
      $(this)
        .attr('title', $(this).attr('data-original-title'))
        .tooltip({
          container: 'body',
          html: true,
          placement: 'top'
         })
    });

    ngram_memo_table.prepend(clone);
  }
}