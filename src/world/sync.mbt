///| 毎フレーム、core の GameState を three のトランスフォームへ写す。
/// core が真実、three は表示キャッシュ。ここでは three 側を一切「読まない」。

///|
/// プレイヤーの位置・向きとカメラの位置・注視を反映する。
fn apply_frame(stage : Stage, game : @core.GameState) -> Unit {
  let p = game.player
  stage.player.as_object3d().set_position(p.x, p.y, p.z)
  // モデルは背面を見せたいので yaw をそのまま使う
  stage.player.as_object3d().set_rotation_y(p.yaw)
  let c = game.camera
  stage.camera.set_position(c.x, c.y, c.z)
  stage.camera.look_at(c.tx, c.ty, c.tz)
}

///|
/// リサイズ時にレンダラとカメラのアスペクトを合わせる。
fn resize_stage(stage : Stage, width : Double, height : Double) -> Unit {
  stage.camera.set_aspect(width / height)
  stage.renderer.set_size(width, height)
}
