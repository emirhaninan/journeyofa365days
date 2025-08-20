(function(){
  try {
    // Theme toggle
    var storageKey = 'theme-preference';
    var root = document.documentElement;
    var saved = localStorage.getItem(storageKey);
    if (saved) root.setAttribute('data-theme', saved);
    var btn = document.getElementById('themeToggle');
    if (btn) {
      btn.addEventListener('click', function(){
        var current = root.getAttribute('data-theme') || '';
        var next = current === 'dark' ? 'light' : 'dark';
        root.setAttribute('data-theme', next);
        localStorage.setItem(storageKey, next);
      });
    }

    // Simple search filter on homepage
    var search = document.getElementById('searchDays');
    if (search) {
      var list = document.getElementById('dayList');
      var items = list ? Array.prototype.slice.call(list.querySelectorAll('.post-list-item')) : [];
      var filter = function(q){
        var query = (q||'').toLowerCase();
        items.forEach(function(item){
          var t = (item.getAttribute('data-title') || item.textContent || '').toLowerCase();
          var show = t.indexOf(query) !== -1;
          item.style.display = show ? '' : 'none';
        });
      };
      search.addEventListener('input', function(e){ filter(e.target.value); });
    }
  } catch (e) {}
})();


