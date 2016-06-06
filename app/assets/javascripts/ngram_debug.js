var ngram_debug = $('#ngram-debug');

function update_ngram_debug(query, res) {
  ngram_debug.empty();

  var ldist = compute_min_levenshtein_distance(res, query);
  debug_levenshtein_sorted(res, ldist);
}

function debug_levenshtein_sorted(res, ldist) {
  $.each(ldist.sort(function(a, b) { return a.min_ldist - b.min_ldist }), function(_junk, i) {
    var r = res[i.res_index];
    var english = r.english.join('/').substring(0, 32);

    ngram_debug.append([r.hanzi, r.pinyin, english].join('<br />') + '<br />');
  })
}