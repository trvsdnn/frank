(function(){
  var collapse, easeInOutQuad, expand, expanded, expanding, init, slide, toggle;
  // -----------------------------------------------
  //
  //  This is pretty gross; Gotta love what those
  //  JS libraries do for you
  //
  //  -
  // Easing function borrowed from jQuery.easing
  easeInOutQuad = function easeInOutQuad(t, b, c, d) {
    return ((t /= d / 2) < 1) && (c / 2 * t * t + b) || (-c / 2 * ((--t) * (t - 2) - 1) + b);
  };
  // Expand / Collapse help info
  expanded = false;
  expanding = false;
  slide = function slide(el, end, duration, start, now) {
    now = now || 0.001;
    start = start || parseInt(document.defaultView.getComputedStyle(el, null).getPropertyValue('left'));
    el.style.left = Math.round(start + (end - start) * easeInOutQuad(now, 0, 1, duration)) + 'px';
    now += 30;
    return now < duration ? setTimeout(function() {
      return slide(el, end, duration, start, now);
    }, 30) : expanding = false;
  };
  expand = function expand() {
    document.getElementById('tooltip').style.display = 'none';
    slide(document.getElementById('header'), 75, 600);
    return slide(document.getElementById('help'), 525, 600);
  };
  collapse = function collapse() {
    document.getElementById('tooltip').style.display = 'block';
    slide(document.getElementById('header'), 300, 600);
    return slide(document.getElementById('help'), 300, 600);
  };
  toggle = function toggle(e) {
    if (expanding) {
      return false;
    }
    expanded = !expanded;
    expanding = true;
    expanded ? expand() : collapse();
    return false;
  };
  init = function init() {
    return document.addEventListener('click', toggle, false);
  };
  window.onload = init;
})();