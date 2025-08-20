(function(){
  try {
    // Only TTS pronunciation for speak buttons
    var wordCards = Array.prototype.slice.call(document.querySelectorAll('.word-card'));
    wordCards.forEach(function(card){
      var speakBtn = card.querySelector('.btn.speak');
      if (speakBtn && 'speechSynthesis' in window) {
        speakBtn.addEventListener('click', function(){
          try {
            var text = speakBtn.getAttribute('data-text') || '';
            if (!text) return;
            var utt = new SpeechSynthesisUtterance(text);
            utt.lang = 'zh-CN';
            var voices = window.speechSynthesis.getVoices() || [];
            var zh = voices.find(function(v){ return v.lang && v.lang.toLowerCase().indexOf('zh') === 0; });
            if (zh) utt.voice = zh;
            window.speechSynthesis.speak(utt);
          } catch (e) {}
        });
      }
    });
  } catch (e) {}
})();


