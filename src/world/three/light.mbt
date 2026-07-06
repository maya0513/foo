///| ライト。生成物は Object3D として返し、位置・影の設定は共通操作で行う。

///|
extern "js" fn ffi_hemisphere_light(
  m : Three,
  sky : Int,
  ground : Int,
  intensity : Double,
) -> Object3D =
  #| (m, sky, ground, intensity) => new m.HemisphereLight(sky, ground, intensity)

///|
/// 空と地面の 2 色による柔らかい環境光。
pub fn new_hemisphere_light(
  m : Three,
  sky : Int,
  ground : Int,
  intensity? : Double = 0.9,
) -> Object3D {
  ffi_hemisphere_light(m, sky, ground, intensity)
}

///|
extern "js" fn ffi_directional_light(
  m : Three,
  color : Int,
  intensity : Double,
  map_size : Int,
  extent : Double,
) -> Object3D =
  #| (m, color, intensity, mapSize, extent) => {
  #|   const l = new m.DirectionalLight(color, intensity);
  #|   l.castShadow = true;
  #|   l.shadow.mapSize.set(mapSize, mapSize);
  #|   l.shadow.camera.near = 1;
  #|   l.shadow.camera.far = 600;
  #|   l.shadow.camera.left = -extent;
  #|   l.shadow.camera.right = extent;
  #|   l.shadow.camera.top = extent;
  #|   l.shadow.camera.bottom = -extent;
  #|   l.shadow.bias = -0.0005;
  #|   l.shadow.normalBias = 0.6;
  #|   return l;
  #| }

///|
/// 太陽光（影を落とす平行光源）。extent は影カメラの片側半径。
pub fn new_directional_light(
  m : Three,
  color : Int,
  intensity? : Double = 2.1,
  map_size? : Int = 2048,
  extent? : Double = 140.0,
) -> Object3D {
  ffi_directional_light(m, color, intensity, map_size, extent)
}
