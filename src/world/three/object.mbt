///| Mesh / Group と Object3D 共通の変換・影の操作。

///|
extern "js" fn ffi_new_mesh_m(
  m : Three,
  g : BufferGeometry,
  mat : Material,
) -> Mesh =
  #| (m, g, mat) => new m.Mesh(g, mat)

///|
pub fn new_mesh(m : Three, g : BufferGeometry, mat : Material) -> Mesh {
  ffi_new_mesh_m(m, g, mat)
}

///|
extern "js" fn ffi_new_group(m : Three) -> Group =
  #| (m) => new m.Group()

///|
pub fn new_group(m : Three) -> Group {
  ffi_new_group(m)
}

///|
extern "js" fn ffi_group_add(g : Group, o : Object3D) -> Unit =
  #| (g, o) => { g.add(o); }

///|
pub fn Group::add(self : Group, o : Object3D) -> Unit {
  ffi_group_add(self, o)
}

///|
extern "js" fn ffi_set_position(
  o : Object3D,
  x : Double,
  y : Double,
  z : Double,
) -> Unit =
  #| (o, x, y, z) => { o.position.set(x, y, z); }

///|
pub fn Object3D::set_position(
  self : Object3D,
  x : Double,
  y : Double,
  z : Double,
) -> Unit {
  ffi_set_position(self, x, y, z)
}

///|
extern "js" fn ffi_set_rotation(
  o : Object3D,
  x : Double,
  y : Double,
  z : Double,
) -> Unit =
  #| (o, x, y, z) => { o.rotation.set(x, y, z); }

///|
pub fn Object3D::set_rotation(
  self : Object3D,
  x : Double,
  y : Double,
  z : Double,
) -> Unit {
  ffi_set_rotation(self, x, y, z)
}

///|
extern "js" fn ffi_set_rotation_y(o : Object3D, y : Double) -> Unit =
  #| (o, y) => { o.rotation.y = y; }

///|
pub fn Object3D::set_rotation_y(self : Object3D, y : Double) -> Unit {
  ffi_set_rotation_y(self, y)
}

///|
extern "js" fn ffi_set_scale(o : Object3D, s : Double) -> Unit =
  #| (o, s) => { o.scale.set(s, s, s); }

///|
pub fn Object3D::set_scale(self : Object3D, s : Double) -> Unit {
  ffi_set_scale(self, s)
}

///|
extern "js" fn ffi_set_cast_shadow(o : Object3D, v : Bool) -> Unit =
  #| (o, v) => { o.castShadow = v; }

///|
pub fn Object3D::set_cast_shadow(self : Object3D, v : Bool) -> Unit {
  ffi_set_cast_shadow(self, v)
}

///|
extern "js" fn ffi_set_receive_shadow(o : Object3D, v : Bool) -> Unit =
  #| (o, v) => { o.receiveShadow = v; }

///|
pub fn Object3D::set_receive_shadow(self : Object3D, v : Bool) -> Unit {
  ffi_set_receive_shadow(self, v)
}
