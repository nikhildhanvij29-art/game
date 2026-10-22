<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Spider Hero: City Run</title>
<style>
  * { box-sizing: border-box; }
  body { margin:0; background:#071426; color:#fff; font-family:Arial, sans-serif; }
  header { padding:14px 20px; display:flex; justify-content:space-between; align-items:center;
           background:#0d213b; border-bottom:1px solid #24476b; gap:12px; flex-wrap:wrap; }
  h1 { margin:0; font-size:clamp(20px,3vw,30px); }
  header p { margin:5px 0 0; color:#bdd5ee; font-size:14px; }
  .hud { display:flex; gap:12px; align-items:center; flex-wrap:wrap; }
  .pill { background:#183657; padding:9px 13px; border-radius:10px; font-weight:bold; }
  main { max-width:1200px; margin:18px auto; padding:0 14px; }
  .game-wrap { position:relative; border:2px solid #315779; border-radius:14px; overflow:hidden;
               box-shadow:0 16px 45px #0008; background:#8ed0ff; }
  canvas { display:block; width:100%; height:auto; background:#8ed0ff; }
  .overlay { position:absolute; inset:0; display:flex; align-items:center; justify-content:center;
             background:#03101dbb; text-align:center; padding:20px; }
  .panel { max-width:440px; background:#102944f2; border:1px solid #5480a8; border-radius:16px; padding:24px; }
  .panel h2 { margin-top:0; font-size:28px; }
  button { border:0; border-radius:9px; background:#ef3038; color:white; padding:12px 18px;
           font-size:16px; font-weight:bold; cursor:pointer; }
  button:hover { background:#ff4d54; }
  .help { display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:10px; margin-top:14px; }
  .help div { background:#102944; border:1px solid #24476b; border-radius:10px; padding:12px; color:#d8e9fa; }
  .note { color:#9fb9d3; font-size:13px; line-height:1.5; }
  kbd { background:#243f5d; padding:3px 7px; border-radius:5px; border:1px solid #55718e; }
</style>
</head>
<body>
<header>
  <div><h1>🕸️ Spider Hero: City Run</h1><p>A small superhero-inspired browser game</p></div>
  <div class="hud">
    <div class="pill">Score: <span id="score">0</span></div>
    <div class="pill">Health: <span id="health">❤️❤️❤️</span></div>
    <button id="restartTop" type="button">Restart</button>
  </div>
</header>
<main>
  <div class="game-wrap">
    <canvas id="game" width="1000" height="560" aria-label="Superhero city game"></canvas>
    <div class="overlay" id="overlay">
      <div class="panel">
        <h2 id="overlayTitle">Ready to swing?</h2>
        <p id="overlayText">Run across the city, collect golden web tokens, and avoid the rooftop obstacles.</p>
        <p><kbd>←</kbd> <kbd>→</kbd> move &nbsp; <kbd>↑</kbd> or <kbd>Space</kbd> jump / web swing</p>
        <button id="startBtn" type="button">Start Game</button>
      </div>
    </div>
  </div>
  <div class="help">
    <div><strong>Move</strong><br><kbd>←</kbd> / <kbd>→</kbd> or <kbd>A</kbd> / <kbd>D</kbd></div>
    <div><strong>Jump / Web swing</strong><br><kbd>↑</kbd> or <kbd>Space</kbd></div>
    <div><strong>Goal</strong><br>Collect gold tokens and dodge obstacles.</div>
  </div>
  <p class="note">This is an original, simple 2D demo—not an official Spider-Man game. It uses canvas drawings and does not require image downloads or extra JavaScript libraries.</p>
</main>
<script>
(() => {
  const canvas = document.getElementById('game');
  const ctx = canvas.getContext('2d');
  const scoreEl = document.getElementById('score');
  const healthEl = document.getElementById('health');
  const overlay = document.getElementById('overlay');
  const overlayTitle = document.getElementById('overlayTitle');
  const overlayText = document.getElementById('overlayText');
  const startBtn = document.getElementById('startBtn');

  const W = canvas.width, H = canvas.height, ground = 475;
  let keys = {}, running = false, score = 0, health = 3, frame = 0;
  let hero, tokens, obstacles, skyline, speed;

  function reset() {
    score = 0; health = 3; frame = 0; speed = 4;
    hero = { x: 120, y: ground - 58, w: 36, h: 58, vx: 0, vy: 0, grounded: true, invulnerable: 0 };
    tokens = []; obstacles = [];
    skyline = [];
    let x = 0;
    while (x < W + 200) {
      const bw = 45 + Math.random() * 80, bh = 100 + Math.random() * 210;
      skyline.push({x, w:bw, h:bh, shade:Math.floor(35 + Math.random()*45)});
      x += bw + 4;
    }
    updateHud();
  }
  function updateHud() {
    scoreEl.textContent = score;
    healthEl.textContent = '❤️'.repeat(Math.max(0, health)) + '♡'.repeat(3 - Math.max(0, health));
  }
  function start() {
    reset(); running = true; overlay.style.display = 'none'; requestAnimationFrame(loop);
  }
  function endGame() {
    running = false;
    overlayTitle.textContent = health <= 0 ? 'Game over!' : 'Paused';
    overlayText.textContent = `Final score: ${score}. Press play to try again.`;
    startBtn.textContent = 'Play Again';
    overlay.style.display = 'flex';
  }

  function drawCity() {
    const sky = ctx.createLinearGradient(0,0,0,H);
    sky.addColorStop(0,'#58b5f4'); sky.addColorStop(1,'#d6f1ff');
    ctx.fillStyle = sky; ctx.fillRect(0,0,W,H);
    // Sun and distant skyline
    ctx.fillStyle = '#fff4b0'; ctx.beginPath(); ctx.arc(830,85,36,0,Math.PI*2); ctx.fill();
    ctx.fillStyle = '#a0c9e7';
    skyline.forEach((b,i) => {
      const bx = ((b.x - frame*0.45) % (W+180) + W+180) % (W+180) - 90;
      ctx.fillRect(bx, ground-b.h, b.w, b.h);
      ctx.fillStyle = '#d9ecfa';
      for (let wy=ground-b.h+14; wy<ground-15; wy+=24) {
        for (let wx=bx+8; wx<bx+b.w-7; wx+=18) {
          ctx.fillRect(wx,wy,7,10);
        }
      }
      ctx.fillStyle = `rgb(${b.shade},${b.shade+20},${b.shade+35})`;
    });
    // Street
    ctx.fillStyle = '#38485b'; ctx.fillRect(0,ground,W,H-ground);
    ctx.fillStyle = '#e8e8c9'; ctx.fillRect(0,ground+45,W,4);
    ctx.fillStyle = '#f8d65c';
    for(let x=-(frame*speed%100); x<W; x+=100) ctx.fillRect(x,ground+65,48,5);
    // Rooftop / foreground edge
    ctx.fillStyle = '#25364b'; ctx.fillRect(0,ground-8,W,12);
  }

  function drawHero() {
    const x=hero.x, y=hero.y;
    if (hero.invulnerable>0 && Math.floor(frame/5)%2===0) return;
    // web line during a jump
    if (!hero.grounded) {
      ctx.strokeStyle='#fff'; ctx.lineWidth=2;
      ctx.beginPath(); ctx.moveTo(x+hero.w/2,y+5); ctx.lineTo(x+hero.w/2+80,Math.max(0,y-125)); ctx.stroke();
    }
    // legs
    ctx.lineCap='round'; ctx.lineWidth=9; ctx.strokeStyle='#123e85';
    ctx.beginPath(); ctx.moveTo(x+13,y+39); ctx.lineTo(x+7,y+55); ctx.moveTo(x+24,y+39); ctx.lineTo(x+31,y+53); ctx.stroke();
    // torso
    ctx.fillStyle='#e82d3b'; ctx.beginPath(); ctx.roundRect(x+6,y+19,25,27,8); ctx.fill();
    ctx.fillStyle='#174e9b'; ctx.fillRect(x+8,y+33,21,12);
    // arms
    ctx.strokeStyle='#e82d3b'; ctx.lineWidth=7;
    ctx.beginPath(); ctx.moveTo(x+8,y+25); ctx.lineTo(x-1,y+36); ctx.moveTo(x+29,y+25); ctx.lineTo(x+38,y+15); ctx.stroke();
    // head
    ctx.fillStyle='#e82d3b'; ctx.beginPath(); ctx.ellipse(x+19,y+11,14,15,0,0,Math.PI*2); ctx.fill();
    ctx.strokeStyle='#7b1722'; ctx.lineWidth=1.5; ctx.beginPath(); ctx.ellipse(x+19,y+11,14,15,0,0,Math.PI*2); ctx.stroke();
    // eyes
    ctx.fillStyle='white'; ctx.beginPath(); ctx.ellipse(x+13,y+10,4,6,-.3,0,Math.PI*2); ctx.ellipse(x+25,y+10,4,6,.3,0,Math.PI*2); ctx.fill();
    ctx.strokeStyle='#20202a'; ctx.lineWidth=1.5; ctx.beginPath(); ctx.moveTo(x+18,y+24); ctx.lineTo(x+20,y+24); ctx.stroke();
  }

  function spawnThings() {
    if (frame % 78 === 0) {
      tokens.push({x:W+20,y:ground-65-Math.random()*115,r:12,taken:false});
    }
    if (frame % 115 === 0) {
      obstacles.push({x:W+20,y:ground-32,w:24+Math.random()*18,h:32});
    }
  }
  function drawThings() {
    tokens.forEach(t => {
      if(t.taken) return;
      ctx.fillStyle='#ffcc32'; ctx.strokeStyle='#fff2a1'; ctx.lineWidth=3;
      ctx.beginPath(); ctx.arc(t.x,t.y,t.r,0,Math.PI*2); ctx.fill(); ctx.stroke();
      ctx.fillStyle='#a85d00'; ctx.font='bold 15px Arial'; ctx.textAlign='center'; ctx.fillText('★',t.x,t.y+5);
    });
    obstacles.forEach(o => {
      ctx.fillStyle='#6f3444'; ctx.fillRect(o.x,o.y,o.w,o.h);
      ctx.fillStyle='#f06b52'; ctx.fillRect(o.x+4,o.y+5,o.w-8,5);
    });
  }
  function update() {
    frame++; speed = Math.min(8,4+score/200);
    if(keys.ArrowLeft||keys.a) hero.vx=-4.4;
    else if(keys.ArrowRight||keys.d) hero.vx=4.4;
    else hero.vx*=.78;
    if((keys.ArrowUp||keys[' ']||keys.w) && hero.grounded) {
      hero.vy=-12; hero.grounded=false;
    }
    hero.x += hero.vx;
    hero.x = Math.max(0,Math.min(W-hero.w,hero.x));
    hero.vy += .58; hero.y += hero.vy;
    if(hero.y+hero.h >= ground) { hero.y=ground-hero.h; hero.vy=0; hero.grounded=true; }
    if(hero.invulnerable>0) hero.invulnerable--;
    spawnThings();
    tokens.forEach(t => {
      t.x -= speed;
      if(!t.taken && Math.abs((hero.x+hero.w/2)-t.x)<t.r+18 && Math.abs((hero.y+hero.h/2)-t.y)<t.r+24) {
        t.taken=true; score+=10; updateHud();
      }
    });
    obstacles.forEach(o => {
      o.x -= speed;
      if(hero.invulnerable===0 && hero.x+hero.w-5>o.x && hero.x+5<o.x+o.w && hero.y+hero.h>o.y) {
        health--; hero.invulnerable=75; updateHud();
        if(health<=0) endGame();
      }
    });
    tokens=tokens.filter(t=>t.x>-40&&!t.taken);
    obstacles=obstacles.filter(o=>o.x>-60);
  }
  function draw() {
    drawCity(); drawThings(); drawHero();
    ctx.fillStyle='#09233cdd'; ctx.fillRect(15,15,250,42);
    ctx.fillStyle='#fff'; ctx.font='bold 18px Arial'; ctx.textAlign='left';
    ctx.fillText('WEB TOKENS: '+score,28,42);
  }
  function loop() {
    if(!running) return;
    update(); draw();
    if(running) requestAnimationFrame(loop);
  }
  document.addEventListener('keydown', e => {
    const k=e.key===' ' ? ' ' : e.key.length===1 ? e.key.toLowerCase() : e.key;
    if(['ArrowLeft','ArrowRight','ArrowUp',' '].includes(k)) e.preventDefault();
    keys[k]=true;
  });
  document.addEventListener('keyup', e => {
    const k=e.key===' ' ? ' ' : e.key.length===1 ? e.key.toLowerCase() : e.key;
    keys[k]=false;
  });
  startBtn.addEventListener('click',start);
  document.getElementById('restartTop').addEventListener('click',start);
  reset(); draw();
})();
</script>
</body>
</html>

