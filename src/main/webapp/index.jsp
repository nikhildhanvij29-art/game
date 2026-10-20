<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Anime World - 3D Animation</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            overflow: hidden;
            background: #080817;
            color: white;
            font-family: Arial, sans-serif;
        }

        #scene {
            position: fixed;
            inset: 0;
        }

        .hud {
            position: fixed;
            z-index: 2;
            top: 25px;
            left: 25px;
            max-width: 360px;
        }

        h1 {
            color: #77eaff;
            font-size: 34px;
            text-shadow: 0 0 18px #00c8ff;
        }

        p {
            color: #c8c8ed;
            margin-top: 12px;
            line-height: 1.5;
        }

        .controls {
            position: fixed;
            z-index: 2;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 12px;
            width: 95%;
        }

        button {
            padding: 13px 22px;
            border: 1px solid #59e8ff;
            border-radius: 25px;
            color: white;
            background: #101a40dd;
            cursor: pointer;
            font-size: 14px;
        }

        button:hover {
            background: #087baf;
            box-shadow: 0 0 20px #00c8ff;
        }

        #status {
            color: #77eaff;
            margin-top: 15px;
            font-size: 13px;
        }
    </style>
</head>
<body>

<div id="scene"></div>

<div class="hud">
    <h1>ANIME WORLD</h1>
    <p>Enter a neon universe. Explore the 3D world
       and activate the character's energy power.</p>
    <div id="status">SYSTEM READY</div>
</div>

<div class="controls">
    <button onclick="toggleAnimation()">Pause / Play</button>
    <button onclick="activatePower()">Energy Blast</button>
    <button onclick="changeColor()">Change Aura</button>
    <button onclick="resetScene()">Reset</button>
</div>

<script type="module">
    import * as THREE from
      'https://cdn.jsdelivr.net/npm/three@0.170.0/build/three.module.js';

    const container = document.getElementById('scene');

    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x080817);
    scene.fog = new THREE.Fog(0x080817, 12, 35);

    const camera = new THREE.PerspectiveCamera(
        60, window.innerWidth / window.innerHeight, 0.1, 100
    );
    camera.position.set(0, 1.4, 8);
    camera.lookAt(0, 0, 0);

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    container.appendChild(renderer.domElement);

    scene.add(new THREE.HemisphereLight(0x8ccfff, 0x160b38, 2));

    const light = new THREE.PointLight(0x00ccff, 40, 20);
    light.position.set(2, 4, 4);
    scene.add(light);

    const character = new THREE.Group();
    scene.add(character);

    function material(color, glow = 0) {
        return new THREE.MeshStandardMaterial({
            color: color,
            emissive: color,
            emissiveIntensity: glow,
            roughness: 0.45,
            metalness: 0.15
        });
    }

    function sphere(name, x, y, z, sx, sy, sz, color) {
        const mesh = new THREE.Mesh(
            new THREE.SphereGeometry(1, 32, 24),
            material(color)
        );
        mesh.name = name;
        mesh.position.set(x, y, z);
        mesh.scale.set(sx, sy, sz);
        character.add(mesh);
        return mesh;
    }

    // Anime-inspired body and head
    const body = sphere(
        'body', 0, -0.8, 0, 0.65, 0.95, 0.38, 0x242c65
    );

    const neck = sphere(
        'neck', 0, 0.18, 0, 0.18, 0.28, 0.18, 0xffbd9b
    );

    const head = sphere(
        'head', 0, 0.85, 0, 0.58, 0.72, 0.48, 0xffc9a8
    );

    // Hair cap and stylized spikes
    sphere('hair', 0, 1.35, -0.03, 0.61, 0.38, 0.51, 0x17234c);

    for (let i = 0; i < 7; i++) {
        const spike = new THREE.Mesh(
            new THREE.ConeGeometry(0.20, 0.65, 5),
            material(0x182958)
        );
        spike.position.set(-0.45 + i * 0.15, 1.55, 0);
        spike.rotation.z = -0.45 + i * 0.12;
        character.add(spike);
    }

    // Eyes
    sphere('left-eye', -0.22, 0.91, 0.43,
        0.105, 0.15, 0.07, 0x36eaff);
    sphere('right-eye', 0.22, 0.91, 0.43,
        0.105, 0.15, 0.07, 0x36eaff);

    // Arms
    const arms = [];
    for (const side of [-1, 1]) {
        const arm = sphere(
            'arm', side * 0.75, -0.65, 0,
            0.22, 0.67, 0.24, 0xffbd9b
        );
        arm.rotation.z = side * -0.25;
        arms.push(arm);
    }

    // Legs
    sphere('left-leg', -0.30, -1.8, 0,
        0.25, 0.65, 0.28, 0x101d45);
    sphere('right-leg', 0.30, -1.8, 0,
        0.25, 0.65, 0.28, 0x101d45);

    // Glowing aura ring
    const auraMaterial = new THREE.MeshBasicMaterial({
        color: 0x00dfff,
        transparent: true,
        opacity: 0.75,
        side: THREE.DoubleSide
    });

    const aura = new THREE.Mesh(
        new THREE.TorusGeometry(1.15, 0.035, 12, 100),
        auraMaterial
    );
    aura.position.y = -0.1;
    aura.rotation.x = Math.PI / 2;
    character.add(aura);

    // Neon ground grid
    const grid = new THREE.GridHelper(40, 60, 0x146dff, 0x27204e);
    grid.position.y = -2.5;
    scene.add(grid);

    // Floating energy particles
    const count = 700;
    const positions = new Float32Array(count * 3);

    for (let i = 0; i < count; i++) {
        positions[i * 3] = (Math.random() - 0.5) * 24;
        positions[i * 3 + 1] = Math.random() * 12 - 5;
        positions[i * 3 + 2] = (Math.random() - 0.5) * 15;
    }

    const particleGeometry = new THREE.BufferGeometry();
    particleGeometry.setAttribute(
        'position',
        new THREE.BufferAttribute(positions, 3)
    );

    const particles = new THREE.Points(
        particleGeometry,
        new THREE.PointsMaterial({
            color: 0x67dfff,
            size: 0.045,
            transparent: true,
            opacity: 0.8
        })
    );
    scene.add(particles);

    let playing = true;
    let power = 0;
    let auraColor = 0x00dfff;
    let startTime = 0;

    function toggleAnimation() {
        playing = !playing;
        document.getElementById('status').textContent =
            playing ? 'ANIMATION RUNNING' : 'ANIMATION PAUSED';
    }

    function activatePower() {
        power = 1;
        document.getElementById('status').textContent =
            'ENERGY BLAST ACTIVATED!';
    }

    function changeColor() {
        auraColor = auraColor === 0x00dfff
            ? 0xff36dd : 0x00dfff;

        auraMaterial.color.setHex(auraColor);
        light.color.setHex(auraColor);
    }

    function resetScene() {
        character.rotation.set(0, 0, 0);
        character.position.set(0, 0, 0);
        power = 0;
        playing = true;
        document.getElementById('status').textContent =
            'SYSTEM RESET';
    }

    // Make controls accessible to the HTML buttons
    window.toggleAnimation = toggleAnimation;
    window.activatePower = activatePower;
    window.changeColor = changeColor;
    window.resetScene = resetScene;

    function animate(time) {
        requestAnimationFrame(animate);

        const t = time * 0.001;

        if (playing) {
            character.position.y = Math.sin(t * 2) * 0.12;
            character.rotation.y = Math.sin(t * 0.5) * 0.20;
            character.rotation.x = Math.sin(t) * 0.025;

            aura.rotation.z += 0.012;
            aura.scale.setScalar(1 + Math.sin(t * 3) * 0.08);

            arms[0].rotation.z = -0.25 + Math.sin(t * 2) * 0.10;
            arms[1].rotation.z = 0.25 - Math.sin(t * 2) * 0.10;

            particles.rotation.y += 0.0007;
            grid.position.z = (t * 0.4) % 1;
        }

        if (power > 0) {
            power += 0.035;
            const scale = 1 + power * 0.9;
            aura.scale.setScalar(scale);
            auraMaterial.opacity = Math.max(0, 1 - power / 2);

            if (power > 2) {
                power = 0;
                auraMaterial.opacity = 0.75;
                document.getElementById('status').textContent =
                    'SYSTEM READY';
            }
        }

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

