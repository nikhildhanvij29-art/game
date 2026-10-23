<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<title>Oggy: Warrior Adventure</title>
<style>
* { box-sizing: border-box; }
body {
  margin: 0; background: #101426; color: white;
  font-family: Arial, sans-serif; text-align: center;
  overflow: hidden; touch-action: none;
}
h2 { margin: 10px 0 5px; color: #ffd166; }
#hud { display:flex; justify-content:space-around; padding:8px; font-weight:bold; }
canvas {
  display:block; width:100%; max-width:900px; height:auto;
  margin:auto; background:#263b65; border:2px solid #64748b;
}
.controls {
  max-width:650px; margin:12px auto; display:flex;
  justify-content:space-around; gap:8px; padding:0 8px;
}
button {
  border:0; border-radius:14px; padding:17px 12px;
  background:#293b60; color:white; font-size:17px;
  font-weight:bold; min-width:60px; touch-action:none;
  box-shadow:0 4px #111827;
}
button:active { background:#e76f51; transform:translateY(2px); }
#message { color:#ffd166; min-height:22px; }
</style>
</head>
<body>
<h2>⚔ OGGY: WARRIOR ADVENTURE</h2>
<div id="hud">
  <span>❤️ Health: <b id="health">100</b></span>
  <span>⭐ Score: <b id="score">0</b></span>
  <span>💀 Enemies: <b id="kills">0</b></span>
</div>

<canvas id="game" width="900" height="440"></canvas>
<div id="message">Defeat the monsters! Protect Oggy's kingdom.</div>

<div class="controls">
  <button id="left">◀</button>
  <button id="right">▶</button>
  <button id="jump">⬆ Jump</button>
  <button id="attack">⚔ Attack</button>
</div>
<button id="restart">↻ Restart Game</button>

<script>
const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");
const $ = id => document.getElementById(id);

let keys = {};
let score = 0, kills = 0, health = 100;
let gameOver = false, lastAttack = 0, spawnTimer = 0;
let camera = 0, frame = 0;

const hero = {
  x: 110, y: 300, w: 48, h: 70,
  vx: 0, vy: 0, speed: 4, grounded: false,
  facing: 1, attacking: 0, invincible: 0
};
let enemies = [];

function spawnEnemy() {
  enemies.push({
    x: camera + 850 + Math.random() * 180,
    y: 320, w: 42, h: 50,
    hp: 2, alive: true, hit: 0
  });
}

function reset() {
  score = 0; kills = 0; health = 100;
  camera = 0; frame = 0; spawnTimer = 0;
  gameOver = false; enemies = [];
  Object.assign(hero, {
    x:110, y:300, vx:0, vy:0, facing:1,
    grounded:false, attacking:0, invincible:0
  });
  $("message").textContent =
    "Defeat the monsters! Protect Oggy's kingdom.";
}

function attack() {
  if (gameOver) return;
  const now = Date.now();
  if (now - lastAttack < 350) return;
  lastAttack = now;
  hero.attacking = 12;

  for (const e of enemies) {
    if (!e.alive) continue;
    const dx = e.x - hero.x;
    const inFront = dx * hero.facing > -5;
    if (Math.abs(dx) < 95 && inFront) {
      e.hp--;
      e.hit = 8;
      e.x += hero.facing * 22;
      if (e.hp <= 0) {
        e.alive = false;
        kills++;
        score += 100;
      }
    }
  }
}

function bindButton(id, key) {
  const el = $(id);
  const down = e => {
    e.preventDefault();
    keys[key] = true;
    if (key === "attack") attack();
    if (key === "jump" && hero.grounded && !gameOver) {
      hero.vy = -12;
      hero.grounded = false;
    }
  };
  const up = e => {
    e.preventDefault();
    keys[key] = false;
  };
  el.addEventListener("pointerdown", down);
  el.addEventListener("pointerup", up);
  el.addEventListener("pointercancel", up);
  el.addEventListener("pointerleave", up);
}

bindButton("left", "left");
bindButton("right", "right");
bindButton("jump", "jump");
bindButton("attack", "attack");

window.addEventListener("keydown", e => {
  if (["ArrowLeft","ArrowRight","ArrowUp"," "].includes(e.key))
    e.preventDefault();
  keys[e.key] = true;
  if (e.key === " " || e.key === "j") attack();
  if ((e.key === "ArrowUp" || e.key === "w") &&
      hero.grounded && !gameOver) {
    hero.vy = -12;
    hero.grounded = false;
  }
});
window.addEventListener("keyup", e => keys[e.key] = false);
$("restart").addEventListener("click", reset);

function drawBackground() {
  const sky = ctx.createLinearGradient(0,0,0,440);
  sky.addColorStop(0,"#172554");
  sky.addColorStop(1,"#60a5fa");
  ctx.fillStyle = sky;
  ctx.fillRect(0,0,900,440);

  // Distant mountains
  ctx.fillStyle = "#334155";
  for(let i=0;i<7;i++) {
    let x = ((i*180-camera*0.2)%1100+1100)%1100-100;
    ctx.beginPath();
    ctx.moveTo(x,350); ctx.lineTo(x+90,140);
    ctx.lineTo(x+190,350); ctx.fill();
  }

  // Ground
  ctx.fillStyle="#365314";
  ctx.fillRect(0,370,900,70);
  ctx.fillStyle="#84cc16";
  ctx.fillRect(0,370,900,7);

  // Ground markings
  ctx.fillStyle="#4d7c0f";
  for(let i=0;i<30;i++) {
    const x = ((i*47-camera)%950+950)%950;
    ctx.fillRect(x,390+(i%3)*12,22,3);
  }
}

function drawHero() {
  const x = hero.x-camera, y=hero.y;
  ctx.save();
  ctx.translate(x+hero.w/2,y+hero.h/2);
  if(hero.facing<0) ctx.scale(-1,1);

  // Legs
  ctx.fillStyle="#172554";
  ctx.fillRect(-15,18,12,24);
  ctx.fillRect(5,18,12,24);
  ctx.fillStyle="#111827";
  ctx.fillRect(-19,37,19,7);
  ctx.fillRect(4,37,19,7);

  // Blue cartoon body
  ctx.fillStyle="#168aad";
  ctx.beginPath(); ctx.ellipse(0,5,24,28,0,0,Math.PI*2); ctx.fill();

  // Face
  ctx.fillStyle="#f1c27d";
  ctx.beginPath(); ctx.ellipse(0,-17,22,21,0,0,Math.PI*2); ctx.fill();

  // Eyes
  ctx.fillStyle="white";
  ctx.beginPath(); ctx.ellipse(-8,-20,7,9,0,0,Math.PI*2); ctx.fill();
  ctx.beginPath(); ctx.ellipse(8,-20,7,9,0,0,Math.PI*2); ctx.fill();
  ctx.fillStyle="#111827";
  ctx.beginPath(); ctx.arc(-6,-19,3,0,Math.PI*2); ctx.fill();
  ctx.beginPath(); ctx.arc(10,-19,3,0,Math.PI*2); ctx.fill();

  // Helmet
  ctx.fillStyle="#fbbf24";
  ctx.beginPath(); ctx.arc(0,-26,22,Math.PI,Math.PI*2); ctx.fill();
  ctx.fillRect(-22,-27,44,5);

  // Sword
  ctx.save();
  if(hero.attacking>0) ctx.rotate(-0.9);
  ctx.fillStyle="#d1d5db";
  ctx.fillRect(19,-10,42,7);
  ctx.fillStyle="#fbbf24";
  ctx.fillRect(16,-13,6,15);
  ctx.fillStyle="#92400e";
  ctx.fillRect(8,-10,10,7);
  ctx.restore();

  ctx.restore();
}

function drawEnemy(e) {
  const x=e.x-camera;
  if(x < -70 || x > 970) return;

  ctx.fillStyle=e.hit>0?"#fff":"#991b1b";
  ctx.beginPath();
  ctx.ellipse(x+21,e.y+23,22,26,0,0,Math.PI*2);
  ctx.fill();

  ctx.fillStyle="#fca5a5";
  ctx.fillRect(x+5,e.y+7,9,7);
  ctx.fillRect(x+25,e.y+7,9,7);
  ctx.fillStyle="#111827";
  ctx.fillRect(x+9,e.y+10,5,5);
  ctx.fillRect(x+27,e.y+10,5,5);

  ctx.fillStyle="#111827";
  ctx.fillRect(x+5,e.y+42,12,9);
  ctx.fillRect(x+26,e.y+42,12,9);

  // Enemy health bar
  ctx.fillStyle="#111827"; ctx.fillRect(x,e.y-9,42,5);
  ctx.fillStyle="#ef4444"; ctx.fillRect(x,e.y-9,42*e.hp/2,5);
}

function update() {
  if(gameOver) return;
  frame++;

  hero.vx=0;
  if(keys.left || keys.ArrowLeft || keys.a) {
    hero.vx=-hero.speed; hero.facing=-1;
  }
  if(keys.right || keys.ArrowRight || keys.d) {
    hero.vx=hero.speed; hero.facing=1;
  }

  hero.x += hero.vx;
  hero.vy += 0.55;
  hero.y += hero.vy;

  if(hero.y+hero.h>=370) {
    hero.y=370-hero.h;
    hero.vy=0; hero.grounded=true;
  }
  hero.x=Math.max(camera,Math.min(camera+780,hero.x));

  camera=Math.max(0,hero.x-250);
  if(hero.attacking>0) hero.attacking--;
  if(hero.invincible>0) hero.invincible--;

  spawnTimer++;
  if(spawnTimer>95) {
    spawnEnemy();
    spawnTimer=0;
  }

  for(const e of enemies) {
    if(!e.alive) continue;
    if(e.hit>0) e.hit--;

    if(Math.abs(e.x-hero.x)<450) {
      e.x += e.x>hero.x ? -1.15 : 1.15;
    }

    if(Math.abs(e.x-hero.x)<42 &&
       Math.abs(e.y-hero.y)<58 &&
       hero.invincible===0) {
      health-=10;
      hero.invincible=55;
      hero.vy=-5;
      if(health<=0) {
        health=0;
        gameOver=true;
        $("message").textContent="Game Over! Press Restart to play again.";
      }
    }
  }

  enemies=enemies.filter(e=>e.alive && e.x>camera-150);
  $("health").textContent=health;
  $("score").textContent=score;
  $("kills").textContent=kills;
}

function render() {
  drawBackground();
  for(const e of enemies) drawEnemy(e);
  if(hero.invincible===0 || frame%8<4) drawHero();

  if(gameOver) {
    ctx.fillStyle="rgba(0,0,0,0.65)";
    ctx.fillRect(0,0,900,440);
    ctx.fillStyle="#ffd166";
    ctx.textAlign="center";
    ctx.font="bold 44px Arial";
    ctx.fillText("GAME OVER",450,205);
    ctx.font="22px Arial";
    ctx.fillText("Score: "+score,450,245);
  }
}

function loop() {
  update();
  render();
  requestAnimationFrame(loop);
}
loop();
</script>
</body>
</html>

