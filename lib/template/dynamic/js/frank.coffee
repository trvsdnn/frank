# -----------------------------------------------
#
#  This is pretty gross; Gotta love what those
#  JS libraries do for you
#
#  -


# Easing function borrowed from jQuery.easing
easeInOutQuad: t, b, c, d =>
  ((t/=d/2) < 1) and (c/2*t*t + b) or (-c/2 * ((--t)*(t-2) - 1) + b)

# Expand / Collapse help info
expanded: false
expanding: false
slide: el, end, duration, start, now =>
  now ||= 0.001
  start ||= parseInt(document.defaultView.getComputedStyle(el,null).getPropertyValue('left'))
  el.style.left = Math.round(start + (end-start) * easeInOutQuad(now, 0, 1, duration)) + 'px'
  
  now += 30
  if now < duration
    setTimeout(
      => slide(el, end, duration, start, now)
      30 )
  else
    expanding: false

expand: =>
  document.getElementById('tooltip').style.display = 'none';
  slide( document.getElementById('header'), 75, 600)
  slide( document.getElementById('help'), 525, 600)
  
collapse: =>
  document.getElementById('tooltip').style.display = 'block';
  slide( document.getElementById('header'), 300, 600)
  slide( document.getElementById('help'), 300, 600)

toggle: e =>
  return false if expanding
  expanded = !expanded
  expanding: true
  if expanded then expand() else collapse()
  false
  
init: =>
  document.addEventListener('click', toggle, false)
  
window.onload: init