///|
extern "js" fn ffi_new_scene(m : Three) -> Scene =
  #| (m) => new m.Scene()

///|
pub fn new_scene(m : Three) -> Scene {
  ffi_new_scene(m)
}

///|
extern "js" fn ffi_scene_add(s : Scene, o : Object3D) -> Unit =
  #| (s, o) => { s.add(o); }

///|
pub fn Scene::add(self : Scene, o : Object3D) -> Unit {
  ffi_scene_add(self, o)
}

///|
extern "js" fn ffi_scene_background(m : Three, s : Scene, color : Int) -> Unit =
  #| (m, s, color) => { s.background = new m.Color(color); }

///|
/// 背景色（空色）を hex で設定。
pub fn Scene::set_background(self : Scene, m : Three, color : Int) -> Unit {
  ffi_scene_background(m, self, color)
}

///|
extern "js" fn ffi_scene_fog(
  m : Three,
  s : Scene,
  color : Int,
  near : Double,
  far : Double,
) -> Unit =
  #| (m, s, color, near, far) => { s.fog = new m.Fog(color, near, far); }

///|
/// 線形フォグ。遠景を空色へ溶かして奥行きと大気感を出す。
pub fn Scene::set_fog(
  self : Scene,
  m : Three,
  color : Int,
  near : Double,
  far : Double,
) -> Unit {
  ffi_scene_fog(m, self, color, near, far)
}
