<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>Onitsha Defense FINAL - Meshack</title>
<style>
  body{margin:0; background:#05070a; color:#fff; font-family:monospace; overflow:hidden; text-align:center}
  canvas{background:#111a0f; display:block; margin:0 auto; border:2px solid #00ff88; max-width:100vw; max-height:65vh;}
  #hud{display:flex; justify-content:space-around; padding:8px; background:#0a0e13; border-bottom:1px solid #00ff88; font-size:12px;}
  #reloadBar{height:6px; background:#222; margin:4px auto; width:90%; max-width:800px; border-radius:10px; overflow:hidden; display:none;}
  #reloadFill{height:100%; width:0%; background:#00ff88; transition:width 0.1s;}
  #joy{position:fixed; bottom:12px; left:12px; display:flex; gap:6px;}
  #shootBtn{position:fixed; bottom:12px; right:12px; width:88px; height:88px; border-radius:50%; background:#ff3b30; color:#fff; border:3px solid #000; font-weight:bold; font-size:14px;}
  .ctrl{background:#00ff88; color:#000; border:0; border-radius:8px; padding:10px 12px; font-weight:bold;}
  @keyframes shake{0%,100%{transform:translate(0)} 25%{transform:translate(-3px,2px)} 75%{transform:translate(3px,-2px)}}
</style>
</head>
<body>
<div id="hud">
  <span>❤️ <b id="hp">100</b></span>
  <span>🔫 <b id="ammo">30</b>/90</span>
  <span>💀 <b id="kills">0</b></span>
  <span>⭐ <b id="wave">1</b></span>
  <span id="musicBtn" onclick="toggleMusic()" style="cursor:pointer;">🎵 ON</span>
</div>
<div id="reloadBar"><div id="reloadFill"></div></div>
<canvas id="game" width="800" height="500"></canvas>
<div style="padding:4px; font-size:9px; color:#666;">TAP ONCE FOR MUSIC | R to Reload | Joystick + RED FIRE</div>

<div id="joy">
  <button class="ctrl" ontouchstart="keys['a']=true" ontouchend="keys['a']=false">◀️</button>
  <button class="ctrl" ontouchstart="keys['w']=true" ontouchend="keys['w']=false">🔼</button>
  <button class="ctrl" ontouchstart="keys['d']=true" ontouchend="keys['d']=false">▶️</button>
  <button class="ctrl" ontouchstart="keys['s']=true" ontouchend="keys['s']=false">🔽</button>
  <button class="ctrl" onclick="tryReload()" style="background:#ffcc00;">RELOAD R</button>
</div>
<button id="shootBtn">FIRE</button>

<script>
let audioCtx, musicOn=true, musicLoop, reloading=false, reserveAmmo=90;
function initAudio(){ if(!audioCtx) audioCtx=new (window.AudioContext||window.webkitAudioContext)(); }
function playSound(type){
  if(!audioCtx) return; const
