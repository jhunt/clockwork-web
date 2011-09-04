$(function () {
  if (!console) { console = {log: function () {}}; }
  if (!console.log) { console.log = function () {}; }

  function section(n) { for (a = [], i = 0; i < 6 && n[i] > 0; i++) { a.push(n[i]); }; return a.join("."); }
  function next(n,h) { for (n[h-1]++, i = h; i < 6; i++) { n[i] = 0; }; return n; }
  var n = [0];
  $('.article h1, .article h2, .article h3').each(function (index,h) {
    n = next(n, parseInt(h.tagName[-1,1])); $(h).prepend(section(n) + '. '); });
});
// vim:ts=2:sts=2:sw=2:et
