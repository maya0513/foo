///| InstancedMesh。木・岩を 1 ドローコールで大量描画する。

///|
extern "js" fn ffi_new_instanced(
  m : Three,
  g : BufferGeometry,
  mat : Material,
  count : Int,
) -> InstancedMesh =
  #| (m, g, mat, count) => new m.InstancedMesh(g, mat, count)

///|
pub fn new_instanced_mesh(
  m : Three,
  g : BufferGeometry,
  mat : Material,
  count : Int,
) -> InstancedMesh {
  ffi_new_instanced(m, g, mat, count)
}

///|
extern "js" fn ffi_instance_set(
  m : Three,
  im : InstancedMesh,
  i : Int,
  x : Double,
  y : Double,
  z : Double,
  ry : Double,
  s : Double,
) -> Unit =
  #| (m, im, i, x, y, z, ry, s) => {
  #|   const mat = new m.Matrix4();
  #|   const q = new m.Quaternion().setFromEuler(new m.Euler(0, ry, 0));
  #|   mat.compose(new m.Vector3(x, y, z), q, new m.Vector3(s, s, s));
  #|   im.setMatrixAt(i, mat);
  #| }

///|
/// i 番目のインスタンスの位置・Y 回転・等方スケールを設定。
pub fn InstancedMesh::set_instance(
  self : InstancedMesh,
  m : Three,
  i : Int,
  x : Double,
  y : Double,
  z : Double,
  ry : Double,
  s : Double,
) -> Unit {
  ffi_instance_set(m, self, i, x, y, z, ry, s)
}

///|
extern "js" fn ffi_instance_needs_update(im : InstancedMesh) -> Unit =
  #| (im) => { im.instanceMatrix.needsUpdate = true; if (im.instanceColor) im.instanceColor.needsUpdate = true; }

///|
/// 全インスタンス行列を設定し終えたら呼ぶ。
pub fn InstancedMesh::commit(self : InstancedMesh) -> Unit {
  ffi_instance_needs_update(self)
}

///|
extern "js" fn ffi_instance_set_color(
  im : InstancedMesh,
  i : Int,
  r : Double,
  g : Double,
  b : Double,
) -> Unit =
  #| (im, i, r, g, b) => { im.setColorAt(i, new (im.__three_color_ctor)(r, g, b)); }

///|
extern "js" fn ffi_attach_color_ctor(m : Three, im : InstancedMesh) -> Unit =
  #| (m, im) => { im.__three_color_ctor = m.Color; }

///|
/// インスタンスごとの色バリエーションを有効にするため Color コンストラクタを結ぶ。
pub fn InstancedMesh::enable_instance_color(
  self : InstancedMesh,
  m : Three,
) -> Unit {
  ffi_attach_color_ctor(m, self)
}

///|
/// i 番目インスタンスの色（各 [0,1]）。事前に enable_instance_color が必要。
pub fn InstancedMesh::set_instance_color(
  self : InstancedMesh,
  i : Int,
  r : Double,
  g : Double,
  b : Double,
) -> Unit {
  ffi_instance_set_color(self, i, r, g, b)
}
