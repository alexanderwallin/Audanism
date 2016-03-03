
AudioContext = window.AudioContext || window.webkitAudioContext

module.exports = if AudioContext then new AudioContext else null
