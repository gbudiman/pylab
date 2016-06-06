function compute_min_levenshtein_distance(res, query) {
  var ldist = new Array();

  $.each(res, function(i, r) {
    var lev = window.Levenshtein;
    var english = r.english.join('/').substring(0, 32);

    var l_hanzi = Math.abs(lev.get(query, r.hanzi));
    var l_pinyin = Math.abs(lev.get(query, r.pinyin));
    var l_english = Math.abs(lev.get(query, english));
    var min_ldist = Math.min(l_hanzi, l_pinyin, l_english);

    ldist.push({ min_ldist: min_ldist, res_index: i });
  })

  return ldist;
}