// Black texture workaround for iOS
// https://discourse.threejs.org/t/textures-in-gltf-sometimes-display-black-but-only-on-ios/30520/28
window.createImageBitmap = undefined;

let mixer;

const clock = new THREE.Clock();

const renderer = new THREE.WebGLRenderer( { antialias: true } );
renderer.setPixelRatio( window.devicePixelRatio );
renderer.setSize( window.innerWidth, window.innerHeight );
renderer.outputEncoding = THREE.sRGBEncoding;
document.body.appendChild( renderer.domElement );

const pmremGenerator = new THREE.PMREMGenerator( renderer );

const scene = new THREE.Scene();
scene.background = new THREE.Color( 0xbfe3dd );
scene.environment = pmremGenerator.fromScene( new RoomEnvironment(), 0.04 ).texture;

const camera = new THREE.PerspectiveCamera( 40, window.innerWidth / window.innerHeight, 0.1, 1000 );
camera.position.set( 5, 2, 8 );

const controls = new OrbitControls( camera, renderer.domElement );
controls.target.set( 0, 0.5, 0 );
controls.update();
controls.enablePan = false;
controls.enableDamping = true;

const dracoLoader = new DRACOLoader();
dracoLoader.setDecoderPath( 'https://raw.githubusercontent.com/mrdoob/three.js/c7d06c02e302ab9c20fe8b33eade4b61c6712654/examples/js/libs/draco/gltf/' );

const loader = new GLTFLoader();
loader.setDRACOLoader( dracoLoader );
loader.load( 'codea://threejs_demo/LittlestTokyo.glb', function ( gltf ) {

	const model = gltf.scene;
	model.position.set( 1, 1, 0 );
	model.scale.set( 0.01, 0.01, 0.01 );
	scene.add( model );

	mixer = new THREE.AnimationMixer( model );
	mixer.clipAction( gltf.animations[ 0 ] ).play();

	animate();
	viewer.mode = FULLSCREEN; // Codea FULLSCREEN

}, undefined, function ( e ) {
	print("Model load error");
} );


function resize(w, h) {
	
	print(w, h);

	camera.aspect = w / h;
	camera.updateProjectionMatrix();

	renderer.setSize( w, h );

};


function animate() {

	requestAnimationFrame( animate );

	const delta = clock.getDelta();

	mixer.update( delta );

	controls.update();

	renderer.render( scene, camera );

}