var ngram_list_table = $('#ngram-list-table');
var hanzi_truncation_limit = 6;
var english_truncation_limit = 32;
var ngram_details = $('#ngram-details');
var ngram_details_hanzi = $('#ngram-details-hanzi');
var ngram_details_pinyin = $('#ngram-details-pinyin');
var ngram_details_english = $('#ngram-details-english');

function update_ngram_list(query, res) {
  ngram_list_table.empty();

  var ldist = compute_min_levenshtein_distance(res, query);
  ngram_list_populate_rows(res, ldist);
}

function ngram_list_populate_rows(res, ldist) {
  $.each(ldist.sort(function(a, b) { return a.min_ldist - b.min_ldist }), function(_junk, i) {
    var r = res[i.res_index];
    ngram_list_table.append(ngram_row(r));
  })

  $('[data-toggle="ngram-tooltip"]').tooltip({
    placement: 'top',
    html: true,
    container: 'body'
  });

  $('.ngram-row').first().trigger('click');
}

function ngram_row(r) {
  return $('<tr class="ngram-row">')
           .append(hanzi_cell(r))
           .append(english_cell(r))
           .attr('data-details', JSON.stringify(r))
           .attr('data-handle-id', r.hanzi)
           .on('click', add_to_ngram_details);
}

function hanzi_cell(r) {
  return $('<td>')
           .text(truncate_hanzi(r))
           .attr('data-toggle', 'ngram-tooltip')
           .attr('title', mouseover_hanzi(r));
}

function english_cell(r) {
  return $('<td>')
           .text(truncate_english(r))
           .attr('data-toggle', english_over_limit(r) ? 'ngram-tooltip' : '')
           .attr('title', mouseover_english(r));
}

function add_to_ngram_details() {
  var d = JSON.parse($(this).attr('data-details'));
  ngram_details.attr('data-details', $(this).attr('data-details'));
  ngram_details.attr('data-handle-id', $(this).attr('data-handle-id'));

  ngram_details_hanzi.text(d.hanzi);
  ngram_details_pinyin.text(d.pinyin);
  ngram_details_english.empty();
  $.each(d.english, function(i, x) {
    ngram_details_english.append('<li>' + x + '</li>');
  });
  ngram_details_conditionally_show_add_button();
}

function truncate_english(x) {
  var joined = x.english.join('/');
  return english_over_limit(x) ? joined.substring(0, 30) + '..' : joined;
}

function truncate_hanzi(x) {
  return hanzi_over_limit(x) ? x.hanzi.substring(0, 3) + '..' : x.hanzi;
}

function hanzi_over_limit(x) {
  return x.hanzi.length > hanzi_truncation_limit;
}

function english_over_limit(x) {
  return x.english.join('/').length > english_truncation_limit;
}

function mouseover_hanzi(x) {
  return x.hanzi + '<br />(' + x.pinyin + ')';
}

function mouseover_english(x) {
  if (x.english.length > 1) {
    var s = $('<ol>');

    $.each(x.english, function(i, entry) {
      $('<li>')
        .text(entry)
        .addClass('ngram-mouseover-list')
      .appendTo(s);
    });

    // WHY???
    return '<ol>' + s.html() + '</ol>';
  } else {
    return x.english;
  }
}