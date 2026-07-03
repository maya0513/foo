///|
/// 収録ステージ。盤面は必ず「膠着状態（step の固定点）」から始まり、
/// budget はソルバーが検証した最小の反転回数、solution はその一例
/// （すべてステージテストで担保する）。
/// 表記: w=白 b=黒 W=固定白 B=固定黒
pub fn levels() -> Array[Level] {
  [
    {
      hint: "黒のどれかを反転して「進める」。白が多いマスは白に変わる。",
      rows: ["wwww", "wbbw", "wbbw", "wwww"],
      budget: 1,
      solution: [(1, 1)],
    },
    {
      hint: "反転した白が孤立しない場所を選ぼう。",
      rows: ["wwwww", "wbbww", "wbbww", "wwwww"],
      budget: 1,
      solution: [(1, 1)],
    },
    {
      hint: "細長い黒は、はしから順に白へ変わっていく。",
      rows: ["wwwww", "bbbbb", "wwwww", "wwwww"],
      budget: 1,
      solution: [(0, 1)],
    },
    {
      hint: "1回の反転では、進めると元に戻ってしまう形もある。",
      rows: ["wbbw", "wbbw", "wbbw", "wwww"],
      budget: 2,
      solution: [(1, 0), (1, 1)],
    },
    {
      hint: "離れた2か所を反転すると、白どうしが支えあう。",
      rows: ["wwwwww", "wbbbbw", "wbbbbw", "wwwwww"],
      budget: 2,
      solution: [(1, 1), (3, 1)],
    },
    {
      hint: "黒の奥に置いた白は、まわりの黒に押し戻されてしまう。",
      rows: ["wwwww", "wbbbw", "wbbbw", "wbbbw", "wwwww"],
      budget: 2,
      solution: [(2, 1), (2, 3)],
    },
    {
      hint: "離れた黒のかたまりには、それぞれ反転が1回ずつ。",
      rows: ["wwwwww", "wbbwbb", "wbbwbb", "wwwwww"],
      budget: 2,
      solution: [(1, 1), (5, 1)],
    },
    {
      hint: "二重枠のマスは固定。変わらないが、まわりの数には入る。",
      rows: ["wwwww", "wbbbw", "wbWbw", "wbbbw", "wwwww"],
      budget: 1,
      solution: [(1, 1)],
    },
    {
      hint: "固定の黒は白にできないが、白にしなくてもクリアになる。",
      rows: ["wwww", "wbbw", "wbBw", "wwww"],
      budget: 1,
      solution: [(1, 1)],
    },
    {
      hint: "固定黒は黒の数を底上げする。離れた場所をねらおう。",
      rows: ["wwwwww", "wBbbbw", "wbbbbw", "wwwwww"],
      budget: 2,
      solution: [(2, 1), (3, 1)],
    },
    {
      hint: "固定黒のとなりのマスは変わりにくい。",
      rows: ["wwwwww", "wbbbbw", "wbBbbw", "wwwwww"],
      budget: 2,
      solution: [(1, 1), (3, 1)],
    },
    {
      hint: "",
      rows: ["wwwwwww", "wbbbbbw", "wbbbbbw", "wwwwwww"],
      budget: 2,
      solution: [(2, 1), (4, 1)],
    },
    {
      hint: "",
      rows: ["wwwww", "wbbbw", "wbbbw", "wbbBw", "wwwww"],
      budget: 3,
      solution: [(1, 1), (3, 1), (2, 2)],
    },
    {
      hint: "ふたつの固定黒にはさまれたマスは、進めるだけでは変わらない。",
      rows: ["wwwww", "wbbbw", "wBbBw", "wbbbw", "wwwww"],
      budget: 3,
      solution: [(2, 1), (2, 2), (2, 3)],
    },
    {
      hint: "すみの固定白を足がかりに。",
      rows: ["Wbbbw", "bbbbw", "wwwww"],
      budget: 3,
      solution: [(1, 0), (2, 0), (3, 0)],
    },
    {
      hint: "",
      rows: ["wwwwww", "wbbbbw", "wbbbbw", "wbbbbw", "wwwwww"],
      budget: 3,
      solution: [(2, 1), (3, 2), (2, 3)],
    },
    {
      hint: "",
      rows: ["wwwwwww", "wbbwbbw", "wbbwbbw", "wwwwwww", "wwbbwww", "wwbbwww"],
      budget: 3,
      solution: [(1, 1), (4, 1), (2, 5)],
    },
    {
      hint: "",
      rows: ["wbbbbw", "wbbbbw", "wbbbbw", "wwwwww"],
      budget: 4,
      solution: [(1, 0), (3, 0), (2, 1), (4, 1)],
    },
    {
      hint: "黒のほうが多い盤面。固定白がたのみだ。",
      rows: ["bbbbb", "bbWbb", "wwwww"],
      budget: 4,
      solution: [(0, 0), (1, 0), (3, 0), (4, 0)],
    },
    {
      hint: "",
      rows: ["bbbbbb", "bWbbWb", "wwwwww"],
      budget: 4,
      solution: [(0, 0), (2, 0), (3, 0), (5, 0)],
    },
    {
      hint: "",
      rows: ["wwwwww", "bbbbbb", "bbbbbb", "wwwwww"],
      budget: 4,
      solution: [(0, 1), (2, 1), (4, 1), (5, 2)],
    },
    {
      hint: "",
      rows: ["wwwwww", "wbbbbw", "wbBBbw", "wbbbbw", "wwwwww"],
      budget: 4,
      solution: [(1, 1), (3, 1), (1, 3), (3, 3)],
    },
    {
      hint: "",
      rows: ["wwwwwww", "wbbbwww", "wbbbwww", "wbbbwww", "wwwwwbb", "wwwwwbb"],
      budget: 4,
      solution: [(2, 1), (2, 3), (5, 4), (6, 5)],
    },
    {
      hint: "",
      rows: ["bbbbb", "bbbbb", "wwwww"],
      budget: 5,
      solution: [(0, 0), (1, 0), (2, 0), (3, 0), (4, 1)],
    },
    {
      hint: "",
      rows: ["wwwwwww", "wbbbbbw", "wbBbBbw", "wbbbbbw", "wwwwwww"],
      budget: 5,
      solution: [(3, 1), (1, 2), (3, 2), (5, 2), (3, 3)],
    },
    {
      hint: "",
      rows: ["wbbbbbw", "wbbbbbw", "wwbbbww", "wwwwwww", "wBwwwww"],
      budget: 5,
      solution: [(1, 0), (2, 0), (3, 0), (4, 0), (3, 2)],
    },
    {
      hint: "",
      rows: ["wwwwwww", "bbbbbbb", "bbbbbbb", "wwwwwww"],
      budget: 5,
      solution: [(0, 1), (1, 1), (3, 1), (5, 1), (6, 2)],
    },
    {
      hint: "",
      rows: ["bbbwww", "bbbwww", "wwwbbb", "wwwbbb"],
      budget: 6,
      solution: [(0, 0), (1, 0), (2, 0), (3, 2), (5, 2), (4, 3)],
    },
    {
      hint: "",
      rows: ["bbbbbb", "bWbbbb", "bbbbBw", "wwwwww", "wwwwww"],
      budget: 6,
      solution: [(0, 0), (2, 0), (4, 0), (3, 1), (5, 1), (0, 2)],
    },
    {
      hint: "",
      rows: ["bbbbbbb", "bbbbbbb", "wwwwwww", "wwwwwww"],
      budget: 6,
      solution: [(1, 0), (2, 0), (4, 0), (5, 0), (0, 1), (6, 1)],
    },
  ]
}
