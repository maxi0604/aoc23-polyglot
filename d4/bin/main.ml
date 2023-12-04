open Angstrom
open Angstrom.Consume
open Core

(**Parser**)
let word = take 4 >>= (function | "Card" -> return () | _ -> fail "Expected 'card'")
let spaces = take_while (function | ' ' -> true | _ -> false)
let digits = take_while (function | '0'..'9' -> true | _ -> false)
let colon = take 1 >>| (function | ":" -> fun () -> return () | _ -> fun () -> fail "Expected ':'")
let pipe = take 1 >>| (function | "|" -> fun () -> return () | _ -> fun () -> fail "Expected '|'")
let number = digits >>= fun k -> (Stdlib.int_of_string_opt k) |> (function | Some i -> return i | None -> fail "Expected number")

let game_line = (word *> spaces *> number <* colon <* spaces) >>= fun num -> many (number <* spaces) <* pipe <* spaces >>= fun card -> many (number <* spaces) >>= fun draw -> return ((num : int), (card : int list), (draw : int list))

let hits (_, card, draw) = List.count draw (fun x -> (List.mem card x Int.equal))
let score x = function
| x when (x - 1 >= 0) -> Int.pow 2 x
| _ -> 0

let main =
    let lines = In_channel.input_lines In_channel.stdin in
    let parsed = List.map lines ~f:(Angstrom.parse_string ~consume:Prefix game_line) in
    let filtered = List.filter_map parsed Result.ok in
    let hit_list = List.map filtered hits in
    List.fold_left hit_list (fun acc x -> acc + x) hit_list 0;;
