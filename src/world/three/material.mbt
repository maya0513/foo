///|
extern "js" fn ffi_standard_material(
  m : Three,
  color : Int,
  flat : Bool,
  roughness : Double,
  metalness : Double,
) -> Material =
  #| (m, color, flat, roughness, metalness) =>
  #|   new m.MeshStandardMaterial({ color, flatShading: flat, roughness, metalness })

///|
/// 単色の物理ベースマテリアル。flat=true でローポリのフラットシェーディング。
pub fn new_standard_material(
  m : Three,
  color : Int,
  flat? : Bool = true,
  roughness? : Double = 0.9,
  metalness? : Double = 0.0,
) -> Material {
  ffi_standard_material(m, color, flat, roughness, metalness)
}

///|
extern "js" fn ffi_vertex_color_material(m : Three, flat : Bool) -> Material =
  #| (m, flat) =>
  #|   new m.MeshStandardMaterial({ vertexColors: true, flatShading: flat, roughness: 0.95, metalness: 0.0 })

///|
/// 頂点色を使うマテリアル（地形用）。
pub fn new_vertex_color_material(m : Three, flat? : Bool = true) -> Material {
  ffi_vertex_color_material(m, flat)
}

///|
extern "js" fn ffi_water_material(
  m : Three,
  color : Int,
  opacity : Double,
) -> Material =
  #| (m, color, opacity) =>
  #|   new m.MeshStandardMaterial({ color, transparent: true, opacity, roughness: 0.25, metalness: 0.1 })

///|
/// 半透明の水面マテリアル。
pub fn new_water_material(
  m : Three,
  color : Int,
  opacity? : Double = 0.78,
) -> Material {
  ffi_water_material(m, color, opacity)
}
