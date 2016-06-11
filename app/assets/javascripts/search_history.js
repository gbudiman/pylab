var search_box = $('#search-box');
var search_box_button = $('#search-box-button');
var search_history_list = $('#search-history-list');
var animation_duration = 250;

function update_search_history(query, count) {
  var new_entry = generate_search_history_entry(query, count);

  search_history_list
    .find('[data-query="' + query + '"]')
    .hide(animation_duration, function() { $(this).remove() });
  
  search_history_list.prepend(new_entry);
  new_entry.show(animation_duration);
}

function generate_search_history_entry(query, count) {
  return $('<li>')
           .addClass('search-history-entry')
           .attr('data-query', query)
           .append(function() { return history_entry_text(query); })
           .append(function() { return result_count(count); })
           .append(history_entry_remove_button)
           .on('mouseover',  function() { trigger_dynamic_remove_button($(this), true)  })
           .on('mouseout',   function() { trigger_dynamic_remove_button($(this), false) })
           .hide();
}

function reciprocate_query() {
  search_box.val($(this).text());
  search_box_button.trigger('click');
}

function result_count(n) {
  return $('<span>')
           .addClass('small')
           .text(' (' + n.toLocaleString() + ')')
}

function history_entry_text(query) {
  return $('<span>')
           .addClass('search-history-entry-text')
           .text(query)
           .on('click', reciprocate_query);
}

function history_entry_remove_button() {
  return $('<span>')
           .addClass('dynamic-remove-button')
           .addClass('pull-right')
           .addClass('glyphicon glyphicon-remove')
           .on('click', remove_entry)
           .hide();
}

function remove_entry() {
  $(this).parent()
           .hide(animation_duration, function() { $(this).remove() });
}

function trigger_dynamic_remove_button(el, _enable) {
  var t = el.find('.dynamic-remove-button');

  if (_enable) {
    t.show();
  } else {
    t.hide();
  }
}