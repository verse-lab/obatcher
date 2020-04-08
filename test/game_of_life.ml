let n_times = try int_of_string Sys.argv.(1) with _ -> 2
let board_size = 1024

let rg =
  ref (Array.init board_size (fun _ -> Array.init board_size (fun _ -> Random.int 2)))
let rg' =
  ref (Array.init board_size (fun _ -> Array.init board_size (fun _ -> Random.int 2)))
let buf = Bytes.create board_size

let get g x y =
  try g.(x).(y)
  with _ -> 0

let neighbourhood g x y =
  (get g (x-1) (y-1)) +
  (get g (x-1) (y  )) +
  (get g (x-1) (y+1)) +
  (get g (x  ) (y-1)) +
  (get g (x  ) (y+1)) +
  (get g (x+1) (y-1)) +
  (get g (x+1) (y  )) +
  (get g (x+1) (y+1))

let next_cell g x y =
  let n = neighbourhood g x y in
  match g.(x).(y), n with
  | 1, 0 | 1, 1                      -> 0  (* lonely *)
  | 1, 4 | 1, 5 | 1, 6 | 1, 7 | 1, 8 -> 0  (* overcrowded *)
  | 1, 2 | 1, 3                      -> 1  (* lives *)
  | 0, 3                             -> 1  (* get birth *)
  | _ (* 0, (0|1|2|4|5|6|7|8) *)     -> 0  (* barren *)

let print g =
  for x = 0 to board_size - 1 do
    for y = 0 to board_size - 1 do
      if g.(x).(y) = 0
      then Bytes.set buf y '.'
      else Bytes.set buf y 'o'
    done;
    print_endline (Bytes.unsafe_to_string buf)
  done;
  print_endline ""

let next () =
  let g = !rg in
  let new_g = !rg' in
  for x = 0 to board_size - 1 do
    for y = 0 to board_size - 1 do
      new_g.(x).(y) <- next_cell g x y
    done
  done;
  rg := new_g;
  rg' := g

let rec repeat n =
  match n with
  | 0 -> ()
  | _ -> next (); repeat (n-1)

let ()=
  print !rg;
  repeat n_times;
  print !rg
