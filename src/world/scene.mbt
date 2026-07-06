///| core のワールドデータ（地形頂点・散布）を three のオブジェクトへ変換して
/// シーングラフを構築する。ここは表示キャッシュの一度きりの組み立てで、
/// 毎フレームの反映は sync.mbt が受け持つ。

///|
/// 生成した three ハンドル一式。ループがこれを掴んで描画・追従する。
priv struct Stage {
  scene : @three.Scene
  camera : @three.PerspectiveCamera
  renderer : @three.WebGLRenderer
  player : @three.Group
}

///|
let sky_color : Int = 0x9ed8ff

///|
/// シーン全体を組む。
fn build_stage(
  m : @three.Three,
  spec : @core.Spec,
  game : @core.GameState,
  width : Double,
  height : Double,
) -> Stage {
  let scene = @three.new_scene(m)
  scene.set_background(m, sky_color)
  scene.set_fog(m, sky_color, 55.0, 210.0)

  // --- ライト（夕方前の柔らかい光）---
  let hemi = @three.new_hemisphere_light(m, 0xcfe8ff, 0x6b7f52, intensity=0.85)
  scene.add(hemi)
  let sun = @three.new_directional_light(m, 0xfff2d9, intensity=2.2)
  sun.set_position(90.0, 120.0, 40.0)
  scene.add(sun)

  // --- 地形 ---
  let geo = @three.build_terrain_geometry(
    m,
    @core.terrain_positions(spec),
    @core.terrain_colors(spec),
    @core.terrain_indices(spec),
  )
  let terrain_mat = @three.new_vertex_color_material(m)
  let terrain = @three.new_mesh(m, geo, terrain_mat)
  terrain.as_object3d().set_receive_shadow(true)
  scene.add(terrain.as_object3d())

  // --- 水面 ---
  let water_size = spec.half_size * 2.6
  let water_geo = @three.new_plane(m, water_size, water_size)
  let water_mat = @three.new_water_material(m, 0x4aa3df, opacity=0.8)
  let water = @three.new_mesh(m, water_geo, water_mat)
  water.as_object3d().set_rotation(-1.5707963267948966, 0.0, 0.0)
  water.as_object3d().set_position(0.0, spec.water_level - 0.15, 0.0)
  scene.add(water.as_object3d())

  // --- 木・岩 ---
  build_trees(m, spec, scene)
  build_rocks(m, spec, scene)

  // --- プレイヤー ---
  let player = build_player(m)
  scene.add(player.as_object3d())

  // --- カメラ ---
  let camera = @three.new_perspective_camera(
    m,
    58.0,
    width / height,
    0.1,
    700.0,
  )
  let c = game.camera
  camera.set_position(c.x, c.y, c.z)
  camera.look_at(c.tx, c.ty, c.tz)
  { scene, camera, renderer: @three.new_renderer(m), player }
}

///|
/// 木の群生を 2 層の葉（コーン）＋幹（シリンダー）の InstancedMesh で描く。
fn build_trees(
  m : @three.Three,
  spec : @core.Spec,
  scene : @three.Scene,
) -> Unit {
  let trees = @core.scatter_trees(spec)
  let n = trees.length()
  if n == 0 {
    return
  }
  // プレイヤー(1.7m)に対して見上げる高さ（樹高 8〜14m）にする。
  // ミニチュア感を避けるため、標準視点で梢が視界の上に抜けるスケール。
  let trunk_geo = @three.new_cylinder(m, 0.24, 0.38, 3.2, seg=6)
  let trunk_mat = @three.new_standard_material(m, 0x6b4a2f, roughness=0.95)
  let trunk = @three.new_instanced_mesh(m, trunk_geo, trunk_mat, n)
  let lower_geo = @three.new_cone(m, 2.6, 5.0, seg=7)
  let upper_geo = @three.new_cone(m, 1.8, 4.2, seg=7)
  let leaf_mat = @three.new_standard_material(m, 0xffffff)
  let lower = @three.new_instanced_mesh(m, lower_geo, leaf_mat, n)
  let upper = @three.new_instanced_mesh(m, upper_geo, leaf_mat, n)
  lower.enable_instance_color(m)
  upper.enable_instance_color(m)
  let greens = [(0.24, 0.47, 0.26), (0.32, 0.55, 0.3), (0.4, 0.6, 0.34)]
  for i = 0; i < n; i = i + 1 {
    let t = trees[i]
    let s = t.scale
    trunk.set_instance(m, i, t.x, t.y + 1.6 * s, t.z, t.rot, s)
    lower.set_instance(m, i, t.x, t.y + (2.9 + 2.5) * s, t.z, t.rot, s)
    upper.set_instance(m, i, t.x, t.y + (5.3 + 2.1) * s, t.z, t.rot, s)
    let (r, g, b) = greens[t.variant % 3]
    lower.set_instance_color(i, r, g, b)
    upper.set_instance_color(i, r * 1.08, g * 1.08, b * 1.08)
  }
  trunk.commit()
  lower.commit()
  upper.commit()
  trunk.as_object3d().set_cast_shadow(true)
  lower.as_object3d().set_cast_shadow(true)
  upper.as_object3d().set_cast_shadow(true)
  scene.add(trunk.as_object3d())
  scene.add(lower.as_object3d())
  scene.add(upper.as_object3d())
}

///|
/// 岩を icosahedron の InstancedMesh で散らす。
fn build_rocks(
  m : @three.Three,
  spec : @core.Spec,
  scene : @three.Scene,
) -> Unit {
  let rocks = @core.scatter_rocks(spec)
  let n = rocks.length()
  if n == 0 {
    return
  }
  let geo = @three.new_icosahedron(m, 1.0, detail=0)
  let mat = @three.new_standard_material(m, 0x8b8781, roughness=1.0)
  let im = @three.new_instanced_mesh(m, geo, mat, n)
  for i = 0; i < n; i = i + 1 {
    let rk = rocks[i]
    // プレイヤーの腰〜背丈ほどの岩になるよう底を少し沈めて置く
    im.set_instance(m, i, rk.x, rk.y + rk.scale * 0.35, rk.z, rk.rot, rk.scale)
  }
  im.commit()
  im.as_object3d().set_cast_shadow(true)
  im.as_object3d().set_receive_shadow(true)
  scene.add(im.as_object3d())
}

///|
/// プレイヤー：暖色の胴（シリンダー）＋頭（球）を Group にまとめる。
/// フィールドと木・岩を相対的に大きく見せるため、身長は約 1.1m と小柄にする。
fn build_player(m : @three.Three) -> @three.Group {
  let s = 0.63
  let g = @three.new_group(m)
  let body_geo = @three.new_cylinder(m, 0.32 * s, 0.42 * s, 1.15 * s, seg=10)
  let body_mat = @three.new_standard_material(m, 0xf2a65e, roughness=0.7)
  let body = @three.new_mesh(m, body_geo, body_mat)
  body.as_object3d().set_position(0.0, 0.62 * s, 0.0)
  body.as_object3d().set_cast_shadow(true)
  g.add(body.as_object3d())
  let head_geo = @three.new_sphere(m, 0.32 * s)
  let head_mat = @three.new_standard_material(m, 0xffe0b8, roughness=0.6)
  let head = @three.new_mesh(m, head_geo, head_mat)
  head.as_object3d().set_position(0.0, 1.42 * s, 0.0)
  head.as_object3d().set_cast_shadow(true)
  g.add(head.as_object3d())
  g
}
