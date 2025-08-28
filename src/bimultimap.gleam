import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

pub opaque type BiMultiMap(k, v) {
  BiMultiMap(forward: dict.Dict(k, List(v)), backward: dict.Dict(k, List(v)))
}

pub fn new() -> BiMultiMap(k, v) {
  BiMultiMap(forward: dict.new(), backward: dict.new())
}

fn inset_in_option_list(
  relationships: Option(List(t)),
  relationship: t,
) -> List(t) {
  case relationships {
    None -> []
    Some(relationships) -> [relationship, ..relationships]
  }
}

pub fn insert(
  bimap: BiMultiMap(k, v),
  left: k,
  right: k,
  value: v,
) -> BiMultiMap(k, v) {
  BiMultiMap(
    forward: bimap.forward
      |> dict.upsert(left, inset_in_option_list(_, value)),
    backward: bimap.backward
      |> dict.upsert(right, inset_in_option_list(_, value)),
  )
}

pub fn get_forward(bimap: BiMultiMap(k, v), key: k) -> List(v) {
  dict.get(bimap.forward, key) |> result.unwrap([])
}

pub fn get_backward(bimap: BiMultiMap(k, v), key: k) -> List(v) {
  dict.get(bimap.backward, key) |> result.unwrap([])
}

pub fn delete(
  bimap: BiMultiMap(k, v),
  left: k,
  right: k,
  value: v,
) -> BiMultiMap(k, v) {
  BiMultiMap(
    forward: bimap.forward
      |> dict.upsert(left, fn(existing) {
        case existing {
          None -> []
          Some(values) -> list.filter(values, fn(v) { v != value })
        }
      }),
    backward: bimap.backward
      |> dict.upsert(right, fn(existing) {
        case existing {
          None -> []
          Some(values) -> list.filter(values, fn(v) { v != value })
        }
      }),
  )
}
