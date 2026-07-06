///| three.js の opaque 型群。three の実体は JS 側にあり、MoonBit からは
/// 不透明なハンドルとして持ち回る。サブタイプ → Object3D は %identity キャスト。
///
/// この層は foo のドメイン（地形・プレイヤー等）を一切知らない汎用バインディング。

///|
/// `import("three")` で得られるモジュール名前空間。全コンストラクタの起点。
#external
pub type Three

///|
pub fn Three::as_any(self : Three) -> @core.Any = "%identity"

///|
/// シーングラフの基底。位置・回転・スケール・影フラグを持つ全ノードの共通型。
#external
pub type Object3D

///|
pub fn Object3D::as_any(self : Object3D) -> @core.Any = "%identity"

///|
#external
pub type Scene

///|
pub fn Scene::as_any(self : Scene) -> @core.Any = "%identity"

///|
pub fn Scene::as_object3d(self : Scene) -> Object3D = "%identity"

///|
#external
pub type PerspectiveCamera

///|
pub fn PerspectiveCamera::as_any(self : PerspectiveCamera) -> @core.Any = "%identity"

///|
pub fn PerspectiveCamera::as_object3d(self : PerspectiveCamera) -> Object3D = "%identity"

///|
#external
pub type WebGLRenderer

///|
pub fn WebGLRenderer::as_any(self : WebGLRenderer) -> @core.Any = "%identity"

///|
#external
pub type BufferGeometry

///|
pub fn BufferGeometry::as_any(self : BufferGeometry) -> @core.Any = "%identity"

///|
#external
pub type Material

///|
pub fn Material::as_any(self : Material) -> @core.Any = "%identity"

///|
#external
pub type Mesh

///|
pub fn Mesh::as_any(self : Mesh) -> @core.Any = "%identity"

///|
pub fn Mesh::as_object3d(self : Mesh) -> Object3D = "%identity"

///|
#external
pub type InstancedMesh

///|
pub fn InstancedMesh::as_any(self : InstancedMesh) -> @core.Any = "%identity"

///|
pub fn InstancedMesh::as_object3d(self : InstancedMesh) -> Object3D = "%identity"

///|
#external
pub type Group

///|
pub fn Group::as_any(self : Group) -> @core.Any = "%identity"

///|
pub fn Group::as_object3d(self : Group) -> Object3D = "%identity"
