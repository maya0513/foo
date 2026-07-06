///|
extern "js" fn ffi_new_renderer(m : Three, antialias : Bool) -> WebGLRenderer =
  #| (m, antialias) => {
  #|   const r = new m.WebGLRenderer({ antialias, alpha: false });
  #|   r.outputColorSpace = m.SRGBColorSpace;
  #|   r.shadowMap.enabled = true;
  #|   r.shadowMap.type = m.PCFShadowMap;
  #|   return r;
  #| }

///|
/// アンチエイリアス + ソフトシャドウ有効のレンダラを作る。
pub fn new_renderer(m : Three, antialias? : Bool = true) -> WebGLRenderer {
  ffi_new_renderer(m, antialias)
}

///|
extern "js" fn ffi_renderer_set_size(
  r : WebGLRenderer,
  w : Double,
  h : Double,
) -> Unit =
  #| (r, w, h) => { r.setSize(w, h); }

///|
pub fn WebGLRenderer::set_size(
  self : WebGLRenderer,
  w : Double,
  h : Double,
) -> Unit {
  ffi_renderer_set_size(self, w, h)
}

///|
extern "js" fn ffi_renderer_set_pixel_ratio(
  r : WebGLRenderer,
  ratio : Double,
) -> Unit =
  #| (r, ratio) => { r.setPixelRatio(ratio); }

///|
pub fn WebGLRenderer::set_pixel_ratio(
  self : WebGLRenderer,
  ratio : Double,
) -> Unit {
  ffi_renderer_set_pixel_ratio(self, ratio)
}

///|
extern "js" fn ffi_renderer_dom_element(r : WebGLRenderer) -> @core.Any =
  #| (r) => r.domElement

///|
/// 生成された canvas 要素（DOM へ append する）。
pub fn WebGLRenderer::dom_element(self : WebGLRenderer) -> @core.Any {
  ffi_renderer_dom_element(self)
}

///|
extern "js" fn ffi_renderer_render(
  r : WebGLRenderer,
  s : Scene,
  c : PerspectiveCamera,
) -> Unit =
  #| (r, s, c) => { r.render(s, c); }

///|
pub fn WebGLRenderer::render(
  self : WebGLRenderer,
  s : Scene,
  c : PerspectiveCamera,
) -> Unit {
  ffi_renderer_render(self, s, c)
}

///|
extern "js" fn ffi_renderer_set_loop(r : WebGLRenderer, f : () -> Unit) -> Unit =
  #| (r, f) => { r.setAnimationLoop(f); }

///|
/// requestAnimationFrame ループを登録（1 回登録で毎フレーム f が呼ばれる）。
pub fn WebGLRenderer::set_animation_loop(
  self : WebGLRenderer,
  f : () -> Unit,
) -> Unit {
  ffi_renderer_set_loop(self, f)
}
