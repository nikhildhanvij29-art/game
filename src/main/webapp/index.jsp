<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>The Last Flame - Anime Short</title>
<style>
* { box-sizing: border-box; }
body {
  margin: 0; background: #080d20; color: white;
  font-family: Arial, sans-serif; text-align: center;
}
header { padding: 18px; color: #ffcc70; }
h1 { margin-bottom: 5px; letter-spacing: 3px; }
#screen {
  position: relative; overflow: hidden;
  width: 100%; max-width: 900px; height: 480px;
  margin: auto; background: linear-gradient(#171b45,#7c2d55,#f59e0b);
}
canvas { width: 100%; height: 100%; display: block; }
#caption {
  position: absolute; bottom: 15px; left: 5%;
  width: 90%; padding: 13px; border-radius: 8px;
  background: rgba(0,0,0,.78); font-size: 17px;
  line-height: 1.5; min-height: 55px;
}
.controls { margin: 18px; }
button {
  padding: 12px 20px; margin: 5px; border: none;
  border-radius: 8px; font-weight: bold;
  background: #f59e0b; color: #111827; cursor: pointer;
}
button:disabled { opacity: .4; }
#sceneTitle { color: #fbbf24; }
</style>
</head>
<body>
<header>
  <h1>THE LAST FLAME</h1>
  <p>An original anime short film</p>
</header>

<div id="screen">
  <canvas id="art" width="900" height="480"></canvas>
  <div id="caption">A thousand years ago, darkness swallowed the kingdom...</div>
</div>

<h3 id="sceneTitle">Scene 1: The Fallen Kingdom</h3>
<div class="controls">
  <button onclick="previousScene()" id="prev">◀ Previous</button>
  <button onclick="playPause()" id="play">▶ Play Movie</button>
  <button onclick="nextScene()" id="next">Next ▶</button>
</div>
<p id="counter">Scene 1 of 5</p>

<script>
const canvas = document.getElementById("art");
const ctx = canvas.getContext("2d");

const scenes = [
  {
    title: "The Fallen Kingdom",
    caption: "Narrator: A thousand years ago, darkness swallowed the kingdom of Aetheria.",
    sky: ["#101735","#71364f","#f59e0b"],
    hero: false, enemy: true
  },
  {
    title: "The Boy with the Flame",
    caption: "Kai: I may be the last warrior... but I will not let my home fall!",
    sky: ["#172554","#7c3aed","#f97316"],
    hero: true, enemy: false
  },
  {
    title: "The Shadow Appears",
    caption: "Shadow King: Your little flame cannot defeat eternal darkness!",
    sky: ["#020617","#312e81","#991b1b"],
    hero: true, enemy: true
  },
  {
    title: "Awakening",
    caption: "Kai: This power is not for revenge. It is for everyone I love!",
    sky: ["#172554","#be123c","#fbbf24"],
    hero: true, enemy: true
  },
  {
    title: "A New Dawn",
    caption: "Narrator: When the sun returned, a new legend was born. Kai: Our story starts today!",
    sky: ["#38bdf8","#f9a8d4","#fef3c7"],
    hero: true, enemy: false
  }
];

let current = 0, timer = null, playing = false, tick = 0;

function polygon(points, color) {
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.moveTo(points[0][0], points[0][1]);
  for (let i=1;i<points.length;i++)
    ctx.lineTo(points[i][0], points[i][1]);
  ctx.closePath();
  ctx.fill();
}

function drawCharacter(x, y, color, isHero) {
  // Anime-style hair
  ctx.fillStyle = isHero ? "#111827" : "#080808";
  ctx.beginPath();
  ctx.arc(x,y-35,24,Math.PI,Math.PI*2);
  ctx.fill();
  polygon([[x-24,y-34],[x-27,y-60],[x-5,y-48],
           [x+5,y-67],[x+20,y-43],[x+26,y-30]], "#111827");

  // Face
  ctx.fillStyle = "#f5c9a5";
  ctx.beginPath();
  ctx.ellipse(x,y-30,17,21,0,0,Math.PI*2);
  ctx.fill();

  // Eyes
  ctx.fillStyle = "#111827";
  ctx.beginPath(); ctx.ellipse(x-7,y-32,3,5,0,0,Math.PI*2); ctx.fill();
  ctx.beginPath(); ctx.ellipse(x+7,y-32,3,5,0,0,Math.PI*2); ctx.fill();

  // Body and cloak
  polygon([[x-15,y-10],[x+15,y-10],[x+25,y+45],
           [x-25,y+45]],color);
  polygon([[x-13,y-5],[x-45,y+40],[x-22,y+35]],"#1e293b");

  // Legs
  ctx.fillStyle="#111827";
  ctx.fillRect(x-18,y+42,13,24);
  ctx.fillRect(x+5,y+42,13,24);

  // Magical sword
  if(isHero) {
    ctx.save();
    ctx.translate(x+20,y+4);
    ctx.rotate(-0.45+Math.sin(tick/8)*0.15);
    ctx.fillStyle="#67e8f9";
    ctx.fillRect(0,-48,6,53);
    ctx.fillStyle="#fbbf24";
    ctx.fillRect(-7,0,20,5);
    ctx.restore();
  } else {
    ctx.fillStyle="#a855f7";
    ctx.beginPath();
    ctx.arc(x,y-10,30+Math.sin(tick/5)*5,0,Math.PI*2);
    ctx.fill();
    ctx.fillStyle="#111827";
    ctx.beginPath();
    ctx.arc(x,y-15,19,0,Math.PI*2);
    ctx.fill();
    ctx.fillStyle="#f87171";
    ctx.fillRect(x-10,y-19,6,4);
    ctx.fillRect(x+5,y-19,6,4);
  }
}

function draw() {
  tick++;
  const s = scenes[current];
  const grad = ctx.createLinearGradient(0,0,0,480);
  s.sky.forEach((c,i)=>grad.addColorStop(i/2,c));
  ctx.fillStyle=grad;
  ctx.fillRect(0,0,900,480);

  // Moon / sun
  ctx.fillStyle="#fff0bd";
  ctx.beginPath();
  ctx.arc(700,100,45,0,Math.PI*2);
  ctx.fill();

  // Distant mountains
  polygon([[0,320],[150,170],[270,320],[420,190],
           [600,330],[760,180],[900,320],[900,480],[0,480]],"#283354");

  // Ruined castle
  ctx.fillStyle="#151b32";
  ctx.fillRect(370,210,160,150);
  ctx.fillRect(390,160,30,70);
  ctx.fillRect(475,145,32,85);
  for(let i=0;i<4;i++) {
    ctx.fillRect(375+i*42,195,20,15);
  }

  // Ground
  ctx.fillStyle="#111827";
  ctx.fillRect(0,380,900,100);

  // Animated magical particles
  for(let i=0;i<45;i++) {
    const x=(i*127+tick*(i%3+1))%900;
    const y=(i*71+tick*1.5)%390;
    ctx.fillStyle=i%2?"#fbbf24":"#67e8f9";
    ctx.globalAlpha=.3+(i%5)/7;
    ctx.fillRect(x,y,3,3);
  }
  ctx.globalAlpha=1;

  if(s.hero) drawCharacter(350+Math.sin(tick/12)*8,330,"#2563eb",true);
  if(s.enemy) drawCharacter(650,330,"#7e22ce",false);

  document.getElementById("caption").textContent=s.caption;
  document.getElementById("sceneTitle").textContent=
    "Scene "+(current+1)+": "+s.title;
  document.getElementById("counter").textContent=
    "Scene "+(current+1)+" of "+scenes.length;
  document.getElementById("prev").disabled=current===0;
  document.getElementById("next").disabled=current===scenes.length-1;
  requestAnimationFrame(draw);
}

function showScene(index) {
  current=Math.max(0,Math.min(scenes.length-1,index));
  if(playing) {
    clearInterval(timer);
    timer=setInterval(autoNext,6000);
  }
}
function nextScene() {
  if(current<scenes.length-1) showScene(current+1);
  else stopMovie();
}
function previousScene() { showScene(current-1); }
function autoNext() {
  if(current<scenes.length-1) showScene(current+1);
  else stopMovie();
}
function playPause() {
  if(playing) {
    playing=false; clearInterval(timer);
    document.getElementById("play").textContent="▶ Resume Movie";
  } else {
    if(current===scenes.length-1) current=0;
    playing=true;
    document.getElementById("play").textContent="⏸ Pause Movie";
    timer=setInterval(autoNext,6000);
  }
}
function stopMovie() {
  playing=false; clearInterval(timer);
  document.getElementById("play").textContent="▶ Replay Movie";
}
draw();
</script>
</body>
</html>

