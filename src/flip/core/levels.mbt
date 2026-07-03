///|
/// 収録レベル。盤面は必ず「膠着状態（step の固定点）」から始まり、
/// budget はソルバーが検証した最小説得人数（レベルテストで担保する）。
pub fn levels() -> Array[Level] {
  [
    {
      name: "ひび割れ",
      intro: "固まった反対ブロックも、ひとり寝返れば崩れはじめる。",
      rows: ["bbbb", "brrb", "brrb", "bbbb"],
      budget: 1,
    },
    {
      name: "一枚岩",
      intro: "出るクイは打たれる。説得した人が孤立しない場所を選ぼう。",
      rows: ["bbbbb", "brrrb", "brrrb", "brrrb", "bbbbb"],
      budget: 2,
    },
    {
      name: "板挟み",
      intro: "頑固な反対派（濃い赤）に両脇を固められた人は、多数決では絶対に折れない。",
      rows: ["bbbbb", "brrrb", "bRrRb", "brrrb", "bbbbb"],
      budget: 3,
    },
    {
      name: "同志",
      intro: "反対の海にも固い同志（濃い青）がいる。彼らと組めば少ない説得で済む。",
      rows: ["rrrrrr", "rBrrBr", "bbbbbb"],
      budget: 4,
    },
    {
      name: "議場",
      intro: "総仕上げ。同志とボスが入り乱れる議場をまとめあげろ。",
      rows: ["rrrrrr", "rBrrrr", "rrrrRb", "bbbbbb", "bbbbbb"],
      budget: 6,
    },
  ]
}
