var hanzi_debug_row = $('#hanzi-debug-row');
var hanzi_debug_table = $('#hanzi-debug-table');

// function update_hanzi_debug_row(x) {
//   hanzi_debug_row
//     .empty()
//     .append(x.used_by.join(', '))
//     .append(" &laquo; ")
//     .append(x.char)
//     .append(" &raquo; ")
//     .append(x.components.join(', '));
// }

function update_hanzi_debug_table(caller, x) {
  var row_locator = 'tr[data-table-hanzi="' + x.char + '"]';

  if (hanzi_debug_table.find(row_locator).length == 0) {
    var td_caller = $('<td>'),
        td_char = $('<td>'),
        td_used_by = $('<td>'),
        td_components = $('<td>');

    caller.make_hanzi_interactive(td_caller, true);
    x.char.make_hanzi_interactive(td_char, true);
    x.used_by.join('').make_hanzi_interactive(td_used_by, true);
    x.components.join('').make_hanzi_interactive(td_components, true);

    hanzi_debug_table
      .append(
        $('<tr>')
          .attr('data-table-hanzi', x.char)
          .append(td_caller)
          .append(td_char)
          .append(td_used_by)
          .append(td_components)
          .on('dblclick', function() { $(this).remove(); } ));
  }
}

String.prototype.make_hanzi_interactive = function(_target) { 
  this.make_hanzi_interactive(_target, false); 
};

String.prototype.make_hanzi_interactive = function(_target, _with_tooltip) {
  var format_hanzi_interactive_tooltip = function(x) {
    var engf = $('<ol>');
    $.each(x.english, function(i, x) {
      engf.append($('<li>').text(x));
    });

    return x.pinyin
         + '<br />'
         + '<ol class="hanzi-interactive-list">' + engf.html() + '</ol>';
  };

  var expand_tooltip = function(x) {
    $.ajax({
      url: '/search/structural/' + x,
      method: 'GET'
    }).done(function(res) {
      $('.hanzi-interactive[data-lazy-update-id="' + x + '"')
        .attr('title', format_hanzi_interactive_tooltip(res))
        .tooltip('fixTitle');
    })
  };

  $.each(this.split(''), function(i, x) {
    _target
      .append($('<span>')
        .addClass('hanzi-interactive')
        .attr('data-toggle', _with_tooltip ? 'hanzi-tooltip' : '')
        .attr('data-lazy-update-id', _with_tooltip ? x : '')
        .text(x)
        .on('click', function() { launch_structural_query(x); }));

    if (_with_tooltip) {
      _target.find('[data-toggle="hanzi-tooltip"]').tooltip({
        container: 'body',
        placement: 'left',
        html: true
      });
      expand_tooltip(x);
    }
  })
};