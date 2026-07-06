///|
extern "js" fn ffi_new_camera(
  m : Three,
  fov : Double,
  aspect : Double,
  near : Double,
  far : Double,
) -> PerspectiveCamera =
  #| (m, fov, aspect, near, far) => new m.PerspectiveCamera(fov, aspect, near, far)

///|
pub fn new_perspective_camera(
  m : Three,
  fov : Double,
  aspect : Double,
  near : Double,
  far : Double,
) -> PerspectiveCamera {
  ffi_new_camera(m, fov, aspect, near, far)
}

///|
extern "js" fn ffi_camera_set_position(
  c : PerspectiveCamera,
  x : Double,
  y : Double,
  z : Double,
) -> Unit =
  #| (c, x, y, z) => { c.position.set(x, y, z); }

///|
pub fn PerspectiveCamera::set_position(
  self : PerspectiveCamera,
  x : Double,
  y : Double,
  z : Double,
) -> Unit {
  ffi_camera_set_position(self, x, y, z)
}

///|
extern "js" fn ffi_camera_look_at(
  c : PerspectiveCamera,
  x : Double,
  y : Double,
  z : Double,
) -> Unit =
  #| (c, x, y, z) => { c.lookAt(x, y, z); }

///|
pub fn PerspectiveCamera::look_at(
  self : PerspectiveCamera,
  x : Double,
  y : Double,
  z : Double,
) -> Unit {
  ffi_camera_look_at(self, x, y, z)
}

///|
extern "js" fn ffi_camera_set_aspect(
  c : PerspectiveCamera,
  aspect : Double,
) -> Unit =
  #| (c, aspect) => { c.aspect = aspect; c.updateProjectionMatrix(); }

///|
/// リサイズ時にアスペクト比を更新（投影行列も再計算）。
pub fn PerspectiveCamera::set_aspect(
  self : PerspectiveCamera,
  aspect : Double,
) -> Unit {
  ffi_camera_set_aspect(self, aspect)
}
