///| 幾何（BufferGeometry）の生成。地形は core が作った頂点配列から手組みし、
/// 木・岩・プレイヤーはプリミティブを使う。

///|
extern "js" fn ffi_new_buffer_geometry(m : Three) -> BufferGeometry =
  #| (m) => new m.BufferGeometry()

///|
extern "js" fn ffi_set_position_attr(
  m : Three,
  g : BufferGeometry,
  data : Array[Double],
) -> Unit =
  #| (m, g, data) => { g.setAttribute('position', new m.BufferAttribute(new Float32Array(data), 3)); }

///|
extern "js" fn ffi_set_color_attr(
  m : Three,
  g : BufferGeometry,
  data : Array[Double],
) -> Unit =
  #| (m, g, data) => { g.setAttribute('color', new m.BufferAttribute(new Float32Array(data), 3)); }

///|
extern "js" fn ffi_set_index(g : BufferGeometry, data : Array[Int]) -> Unit =
  #| (g, data) => { g.setIndex(data); }

///|
extern "js" fn ffi_compute_normals(g : BufferGeometry) -> Unit =
  #| (g) => { g.computeVertexNormals(); }

///|
/// core の頂点位置・色・インデックス配列から、法線付きの地形ジオメトリを組む。
/// Array[Double]/Array[Int] は JS 配列としてそのまま渡り Float32Array 化される。
pub fn build_terrain_geometry(
  m : Three,
  positions : Array[Double],
  colors : Array[Double],
  indices : Array[Int],
) -> BufferGeometry {
  let g = ffi_new_buffer_geometry(m)
  ffi_set_position_attr(m, g, positions)
  ffi_set_color_attr(m, g, colors)
  ffi_set_index(g, indices)
  ffi_compute_normals(g)
  g
}

///|
extern "js" fn ffi_new_cone(
  m : Three,
  radius : Double,
  height : Double,
  seg : Int,
) -> BufferGeometry =
  #| (m, radius, height, seg) => new m.ConeGeometry(radius, height, seg)

///|
pub fn new_cone(
  m : Three,
  radius : Double,
  height : Double,
  seg? : Int = 7,
) -> BufferGeometry {
  ffi_new_cone(m, radius, height, seg)
}

///|
extern "js" fn ffi_new_cylinder(
  m : Three,
  r_top : Double,
  r_bottom : Double,
  height : Double,
  seg : Int,
) -> BufferGeometry =
  #| (m, rt, rb, h, seg) => new m.CylinderGeometry(rt, rb, h, seg)

///|
pub fn new_cylinder(
  m : Three,
  r_top : Double,
  r_bottom : Double,
  height : Double,
  seg? : Int = 8,
) -> BufferGeometry {
  ffi_new_cylinder(m, r_top, r_bottom, height, seg)
}

///|
extern "js" fn ffi_new_sphere(
  m : Three,
  radius : Double,
  wseg : Int,
  hseg : Int,
) -> BufferGeometry =
  #| (m, radius, wseg, hseg) => new m.SphereGeometry(radius, wseg, hseg)

///|
pub fn new_sphere(
  m : Three,
  radius : Double,
  wseg? : Int = 10,
  hseg? : Int = 8,
) -> BufferGeometry {
  ffi_new_sphere(m, radius, wseg, hseg)
}

///|
extern "js" fn ffi_new_icosahedron(
  m : Three,
  radius : Double,
  detail : Int,
) -> BufferGeometry =
  #| (m, radius, detail) => new m.IcosahedronGeometry(radius, detail)

///|
pub fn new_icosahedron(
  m : Three,
  radius : Double,
  detail? : Int = 0,
) -> BufferGeometry {
  ffi_new_icosahedron(m, radius, detail)
}

///|
extern "js" fn ffi_new_plane(
  m : Three,
  w : Double,
  h : Double,
) -> BufferGeometry =
  #| (m, w, h) => new m.PlaneGeometry(w, h)

///|
pub fn new_plane(m : Three, w : Double, h : Double) -> BufferGeometry {
  ffi_new_plane(m, w, h)
}
