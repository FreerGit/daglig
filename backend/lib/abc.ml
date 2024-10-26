let%expect_test "tt" =
  let abc = 338 in
  print_int abc;
  [%expect {| 338 |}]


let%test _ = 5 = 5