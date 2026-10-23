<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>3D Chhota Bheem Runner</title>
<style>
  * { box-sizing: border-box; }
  body {
    margin: 0;
    overflow: hidden;
    font-family: Arial, sans-serif;
    background: #87ceeb;
  }
  #hud {
    position: fixed;
    top: 15px;
    left: 15px;
    z-index: 5;
    color: white;
    background: #5b2600dd;
    padding: 12px 18px;
    border-radius: 12px;
    font-size: 18px;
    line-height: 1.7;
  }
  #help {
    position: fixed;
    bottom: 15px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 5;
    background: #ffffffdd;
    padding: 10px 16px;
    border-radius: 10px;
    text-align: center;
    width: max-content;
    max-width: 95%;
  }
  #overlay {
    position: fixed;
    inset: 0;
    z-index: 10;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #0008;
  }
  #panel {
    background: #fff4d4;
    padding: 28px;
    border-radius: 20px;
    text-align: center;
    max-width: 90%;
    box-shadow: 0 10px 40px #0005;
  }
  button {
    background: #e76f00;
    color: white;
    border: 0;
    border-radius: 10px;
    padding: 13px 22px;
    font-size: 17px;
    cursor: pointer;
  }
  button:hover { background: #b95100; }
</style>
</head>
<body>

<div id="hud">
  🏆 Score: <span id="score">0</span><br>
  🟡 Laddus: <span id="laddus">0</span>
</div>

<div id="overlay">
  <div id="panel">
    <h1>🦸 3D Chhota Bheem Adventure</h1>
    <p>Run through the village, collect laddus and avoid obstacles!</p>
    <p>Use A/D or ←/→ to move, SPACE or ↑ to jump.</p>
    <button id="start">Start Game</button>
  </div>
</div>

<div id="help">
  ⬅️ ➡️ Move &nbsp; | &nbsp; ⬆️ Jump &nbsp; | &nbsp; Collect laddus!
</div>

<script type="module">
import * as THREE from
  'https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js';

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x87ceeb);
scene.fog = new THREE.Fog(0x87ceeb, 35, 115);

const camera = new THREE.PerspectiveCamera(
  65, window.innerWidth / window.innerHeight, 0.1, 200
);
camera.position.set(0, 5, 10);
camera.lookAt(0, 1, -5);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
document.body.appendChild(renderer.domElement);

scene.add(new THREE.HemisphereLight(0xffffff, 0x557744, 2));

const sunlight = new THREE.DirectionalLight(0xffffff, 3);
sunlight.position.set(-5, 12, 8);
sunlight.castShadow = true;
scene.add(sunlight);

const mat = color => new THREE.MeshStandardMaterial({ color });

const grassMat = mat(0x55ad42);
const roadMat = mat(0x777777);
const whiteMat = mat(0xffffff);
const orangeMat = mat(0xff7900);
const skinMat = mat(0xd99557);
const greenMat = mat(0x168a42);
const shoeMat = mat(0x512b16);
const darkMat = mat(0x352116);
const goldMat = mat(0xffc928);

// Ground and road
const ground = new THREE.Mesh(
  new THREE.PlaneGeometry(200, 200), grassMat
);
ground.rotation.x = -Math.PI / 2;
ground.position.y = -0.12;
ground.receiveShadow = true;
scene.add(ground);

const road = new THREE.Mesh(
  new THREE.PlaneGeometry(7, 180), roadMat
);
road.rotation.x = -Math.PI / 2;
road.position.set(0, -0.05, -40);
road.receiveShadow = true;
scene.add(road);

// Road markings
const markings = [];
for (let z = 12; z > -110; z -= 8) {
  const line = new THREE.Mesh(
    new THREE.BoxGeometry(0.12, 0.025, 3),
    whiteMat
  );
  line.position.set(0, 0.01, z);
  scene.add(line);
  markings.push(line);
}

// Simple colorful village scenery
function createHouse(x, z, color) {
  const group = new THREE.Group();

  const house = new THREE.Mesh(
    new THREE.BoxGeometry(3, 2.5, 2.5),
    mat(color)
  );
  house.position.y = 1.2;
  house.castShadow = true;
  group.add(house);

  const roof = new THREE.Mesh(
    new THREE.ConeGeometry(2.4, 1.5, 4),
    mat(0x963b22)
  );
  roof.position.y = 3.15;
  roof.rotation.y = Math.PI / 4;
  roof.castShadow = true;
  group.add(roof);

  const door = new THREE.Mesh(
    new THREE.BoxGeometry(0.65, 1.35, 0.12),
    darkMat
  );
  door.position.set(0, 0.68, 1.3);
  group.add(door);

  group.position.set(x, 0, z);
  scene.add(group);
  return group;
}

function createTree(x, z) {
  const group = new THREE.Group();

  const trunk = new THREE.Mesh(
    new THREE.CylinderGeometry(0.2, 0.3, 1.6, 8),
    mat(0x75421e)
  );
  trunk.position.y = 0.8;
  group.add(trunk);

  const leaves = new THREE.Mesh(
    new THREE.SphereGeometry(1.15, 12, 10),
    mat(0x187a31)
  );
  leaves.position.y = 2.1;
  group.add(leaves);

  group.position.set(x, 0, z);
  scene.add(group);
  return group;
}

const scenery = [];
for (let i = 0; i < 12; i++) {
  const z = -i * 12;
  scenery.push(createHouse(-7, z, 0xe9b65c));
  scenery.push(createHouse(7, z - 5, 0xe5d1a0));
  scenery.push(createTree(-5, z - 5));
  scenery.push(createTree(5, z));
}

// Build a stylized cartoon hero from 3D shapes
const hero = new THREE.Group();
scene.add(hero);

function sphere(parent, radius, material, x, y, z,
                sx = 1, sy = 1, sz = 1) {
  const mesh = new THREE.Mesh(
    new THREE.SphereGeometry(radius, 16, 12), material
  );
  mesh.position.set(x, y, z);
  mesh.scale.set(sx, sy, sz);
  mesh.castShadow = true;
  parent.add(mesh);
  return mesh;
}

function limb(parent, radius, length, material, x, y, z) {
  const mesh = new THREE.Mesh(
    new THREE.CylinderGeometry(radius, radius, length, 12),
    material
  );
  mesh.position.set(x, y, z);
  mesh.castShadow = true;
  parent.add(mesh);
  return mesh;
}

// Legs and shoes
const legs = [];
for (const x of [-0.23, 0.23]) {
  const leg = limb(hero, 0.12, 0.48, skinMat, x, 0.5, 0);
  legs.push(leg);

  const shoe = new THREE.Mesh(
    new THREE.SphereGeometry(0.16, 12, 10), shoeMat
  );
  shoe.scale.set(1, 0.6, 1.5);
  shoe.position.set(x, 0.16, -0.08);
  hero.add(shoe);
}

// Green shorts
const shorts = new THREE.Mesh(
  new THREE.BoxGeometry(0.65, 0.32, 0.42), greenMat
);
shorts.position.y = 0.85;
shorts.castShadow = true;
hero.add(shorts);

// Orange shirt / body
const torso = new THREE.Mesh(
  new THREE.CylinderGeometry(0.3, 0.36, 0.8, 16),
  orangeMat
);
torso.position.y = 1.4;
torso.castShadow = true;
hero.add(torso);

// Arms
const arms = [];
for (const side of [-1, 1]) {
  const arm = limb(
    hero, 0.105, 0.64, skinMat, side * 0.43, 1.4, 0
  );
  arm.rotation.z = side * -0.18;
  arms.push(arm);

  sphere(hero, 0.12, skinMat, side * 0.45, 1.04, 0);
}

// Neck and head
limb(hero, 0.13, 0.22, skinMat, 0, 1.88, 0);

sphere(hero, 0.39, skinMat, 0, 2.22, 0, 1, 1.05, 0.9);

// Hair
sphere(hero, 0.36, darkMat, 0, 2.47, -0.02, 1.05, 0.55, 0.95);

// Eyes, facing the camera at positive Z
for (const x of [-0.14, 0.14]) {
  sphere(hero, 0.075, whiteMat, x, 2.25, 0.335);
  sphere(hero, 0.036, darkMat, x, 2.25, 0.397);
}

sphere(hero, 0.055, skinMat, 0, 2.13, 0.36, 1, 0.7, 0.8);
hero.position.set(0, 0, 3);

// Game objects
const objects = [];
const lanes = [-2, 0, 2];

function createLaddu(x, z) {
  const group = new THREE.Group();
  sphere(group, 0.32, goldMat, 0, 0, 0, 1, 0.85, 1);

  // Small golden dots
  for (let i = 0; i < 5; i++) {
    const dot = sphere(
      group, 0.045, mat(0xffe98a),
      Math.cos(i * 1.26) * 0.2,
      Math.sin(i * 1.26) * 0.16,
      0.2
    );
  }

  group.position.set(x, 0.9, z);
  scene.add(group);
  objects.push({ group, type: 'laddu', hit: false });
}

function createObstacle(x, z) {
  const group = new THREE.Group();

  const block = new THREE.Mesh(
    new THREE.BoxGeometry(1, 1.25, 0.8),
    mat(0xb74225)
  );
  block.position.y = 0.62;
  block.castShadow = true;
  group.add(block);

  const stripe = new THREE.Mesh(
    new THREE.BoxGeometry(1.02, 0.18, 0.83),
    goldMat
  );
  stripe.position.y = 0.7;
  group.add(stripe);

  group.position.set(x, 0, z);
  scene.add(group);
  objects.push({ group, type: 'obstacle', hit: false });
}

let score = 0;
let ladduCount = 0;
let speed = 0.24;
let running = false;
let jumping = false;
let jumpVelocity = 0;
let elapsed = 0;
let spawnTimer = 0;

const scoreEl = document.getElementById('score');
const laddusEl = document.getElementById('laddus');
const overlay = document.getElementById('overlay');
const panel = document.getElementById('panel');

function spawnObjects() {
  const lane = lanes[Math.floor(Math.random() * lanes.length)];
  const z = -75 - Math.random() * 15;

  if (Math.random() < 0.65) {
    createLaddu(lane, z);
    if (Math.random() < 0.6) createLaddu(lane, z - 4);
  } else {
    createObstacle(lane, z);
  }
}

function startGame() {
  for (const object of objects) scene.remove(object.group);
  objects.length = 0;

  score = 0;
  ladduCount = 0;
  speed = 0.24;
  elapsed = 0;
  spawnTimer = 0;
  hero.position.set(0, 0, 3);
  hero.rotation.set(0, 0, 0);
  jumping = false;
  jumpVelocity = 0;

  scoreEl.textContent = '0';
  laddusEl.textContent = '0';

  overlay.style.display = 'none';
  running = true;
}

function gameOver() {
  running = false;
  panel.innerHTML = `
    <h1>Game Over!</h1>
    <h2>🏆 Score: ${score}</h2>
    <p>🟡 Laddus collected: ${ladduCount}</p>
    <button id="restart">Play Again</button>
  `;
  overlay.style.display = 'flex';
  document.getElementById('restart').onclick = startGame;
}

document.getElementById('start').onclick = startGame;

function moveHero(direction) {
  if (!running) return;
  hero.position.x = THREE.MathUtils.clamp(
    hero.position.x + direction * 2, -2, 2
  );
}

function jump() {
  if (!running || jumping) return;
  jumping = true;
  jumpVelocity = 0.23;
}

window.addEventListener('keydown', event => {
  if (['ArrowLeft', 'ArrowRight', 'ArrowUp', ' '].includes(event.key)) {
    event.preventDefault();
  }

  if (event.repeat) return;

  if (event.key === 'ArrowLeft' || event.key.toLowerCase() === 'a') {
    moveHero(-1);
  }
  if (event.key === 'ArrowRight' || event.key.toLowerCase() === 'd') {
    moveHero(1);
  }
  if (event.key === 'ArrowUp' || event.key === ' ') jump();
});

// Simple touch controls
let touchStartX = null;
window.addEventListener('touchstart', event => {
  touchStartX = event.changedTouches[0].clientX;
}, { passive: true });

window.addEventListener('touchend', event => {
  if (touchStartX === null) return;
  const dx = event.changedTouches[0].clientX - touchStartX;

  if (Math.abs(dx) > 35) moveHero(dx > 0 ? 1 : -1);
  else jump();

  touchStartX = null;
}, { passive: true });

const clock = new THREE.Clock();

function animate() {
  requestAnimationFrame(animate);
  const dt = Math.min(clock.getDelta(), 0.05);

  if (running) {
    elapsed += dt;
    score += Math.floor(dt * 10);
    speed = Math.min(0.48, speed + dt * 0.003);
    spawnTimer += dt;

    scoreEl.textContent = score;

    // Jump physics
    if (jumping) {
      hero.position.y += jumpVelocity;
      jumpVelocity -= 0.012;
      if (hero.position.y <= 0) {
        hero.position.y = 0;
        jumping = false;
        jumpVelocity = 0;
      }
    }

    // Run animation
    const swing = Math.sin(elapsed * 14) * 0.35;
    legs[0].rotation.x = swing;
    legs[1].rotation.x = -swing;
    arms[0].rotation.x = -swing;
    arms[1].rotation.x = swing;

    // Move road markings
    for (const line of markings) {
      line.position.z += speed * 60 * dt;
      if (line.position.z > 15) line.position.z -= 120;
    }

    // Move village scenery
    for (const item of scenery) {
      item.position.z += speed * 60 * dt;
      if (item.position.z > 15) item.position.z -= 144;
    }

    // Spawn laddus and obstacles
    if (spawnTimer > 1.1) {
      spawnObjects();
      spawnTimer = 0;
    }

    for (let i = objects.length - 1; i >= 0; i--) {
      const object = objects[i];
      object.group.position.z += speed * 60 * dt;
      object.group.rotation.y += dt * 1.7;

      const dx = Math.abs(object.group.position.x - hero.position.x);
      const dz = Math.abs(object.group.position.z - hero.position.z);

      if (!object.hit && dx < 0.85 && dz < 0.95) {
        if (object.type === 'laddu') {
          object.hit = true;
          ladduCount++;
          score += 100;
          scoreEl.textContent = score;
          laddusEl.textContent = ladduCount;
          scene.remove(object.group);
          objects.splice(i, 1);
          continue;
        } else if (hero.position.y < 0.7) {
          gameOver();
          break;
        }
      }

      if (object.group.position.z > 15) {
        scene.remove(object.group);
        objects.splice(i, 1);
      }
    }
  }

  // Follow the hero smoothly
  camera.position.x += (hero.position.x * 0.45 - camera.position.x) * 0.06;
  camera.lookAt(hero.position.x * 0.25, 1.2, -5);

  renderer.render(scene, camera);
}

window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

animate();
</script>
</body>
</html>

